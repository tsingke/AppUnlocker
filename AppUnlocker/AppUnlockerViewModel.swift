import Foundation
import AppKit
import Combine
import UniformTypeIdentifiers

// MARK: - ViewModel

@MainActor
final class AppUnlockerViewModel: ObservableObject {

    @Published var items: [AppItem] = []
    @Published var isHovering: Bool = false

    // MARK: - Drop handling

    func handleDroppedURLs(_ urls: [URL]) {
        let appURLs = urls.filter { isAppBundle($0) }
        guard !appURLs.isEmpty else { return }

        for url in appURLs {
            let item = AppItem(url: url)
            // Avoid duplicates by path
            guard !items.contains(where: { $0.path == url }) else { continue }
            items.insert(item, at: 0)
            Task { await fix(item) }
        }
    }

    // MARK: - File picker

    func openFilePicker() {
        let panel = NSOpenPanel()
        panel.title              = "选择要修复的应用程序"
        panel.prompt             = "修复"
        panel.message            = "选择一个或多个 .app 应用程序"
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories    = true
        panel.canChooseFiles          = false
        panel.treatsFilePackagesAsDirectories = false
        // Only show .app bundles
        if #available(macOS 11.0, *) {
            panel.allowedContentTypes = [UTType.applicationBundle]
        }

        guard panel.runModal() == .OK else { return }
        handleDroppedURLs(panel.urls)
    }

    // MARK: - Fix

    func fix(_ item: AppItem) async {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].status = .fixing

        let path  = item.path
        let result = await Task.detached(priority: .userInitiated) {
            Self.removeQuarantine(path: path)
        }.value

        guard let i = items.firstIndex(where: { $0.id == item.id }) else { return }
        switch result {
        case .success:
            items[i].status  = .success
            items[i].fixedAt = Date()
        case .failure(let err):
            items[i].status  = .failed(err.localizedDescription)
        }
    }

    func retryFix(_ item: AppItem) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx].status = .pending
        }
        Task { await fix(item) }
    }

    func openApp(_ item: AppItem) {
        let cfg = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: item.path, configuration: cfg) { _, err in
            if let err { print("[AppUnlocker] Open failed: \(err)") }
        }
    }

    func remove(_ item: AppItem) {
        items.removeAll { $0.id == item.id }
    }

    func clearAll() {
        items.removeAll()
    }

    // MARK: - Private: quarantine removal

    /// Attempts removal without elevation first; falls back to osascript admin.
    nonisolated private static func removeQuarantine(path: URL) -> Result<Void, Error> {
        // Step 1 — try directly (works when user owns the app)
        if let ok = runXattr(path: path), ok { return .success(()) }

        // Step 2 — ask for admin password via osascript
        return runXattrAdmin(path: path)
    }

    @discardableResult
    nonisolated private static func runXattr(path: URL) -> Bool? {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")
        proc.arguments     = ["-r", "-d", "com.apple.quarantine", path.path]
        proc.standardOutput = Pipe()
        proc.standardError  = Pipe()
        do {
            try proc.run()
            proc.waitUntilExit()
            return proc.terminationStatus == 0
        } catch {
            return nil
        }
    }

    nonisolated private static func runXattrAdmin(path: URL) -> Result<Void, Error> {
        // Shell-escape the path for AppleScript
        let escaped = path.path
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        do shell script "xattr -r -d com.apple.quarantine \"\(escaped)\"" with administrator privileges
        """

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments     = ["-e", script]
        let errPipe = Pipe()
        proc.standardError  = errPipe
        proc.standardOutput = Pipe()

        do {
            try proc.run()
            proc.waitUntilExit()
            if proc.terminationStatus == 0 { return .success(()) }
            let data = errPipe.fileHandleForReading.readDataToEndOfFile()
            let msg  = String(data: data, encoding: .utf8)?
                          .trimmingCharacters(in: .whitespacesAndNewlines)
                       ?? "未知错误 (code \(proc.terminationStatus))"
            // User cancelled → -128
            let friendly = msg.contains("-128") ? "已取消管理员授权" : msg
            return .failure(AppError.shellFailed(friendly))
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Helpers

    private func isAppBundle(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir),
              isDir.boolValue else { return false }
        return url.pathExtension == "app"
    }
}

// MARK: - Custom Error

enum AppError: LocalizedError {
    case shellFailed(String)
    var errorDescription: String? {
        switch self { case .shellFailed(let m): return m }
    }
}
