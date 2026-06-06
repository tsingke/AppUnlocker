import Foundation
import AppKit

// MARK: - AppItem Model

struct AppItem: Identifiable, Equatable {
    let id: UUID
    let name: String
    let path: URL
    let icon: NSImage
    var status: FixStatus
    var addedAt: Date
    var fixedAt: Date?

    init(url: URL) {
        self.id = UUID()
        self.path = url
        self.name = url.deletingPathExtension().lastPathComponent
        self.icon = NSWorkspace.shared.icon(forFile: url.path)
        self.status = .pending
        self.addedAt = Date()
    }

    enum FixStatus: Equatable {
        case pending
        case fixing
        case success
        case failed(String)

        var displayText: String {
            switch self {
            case .pending:  return "等待处理"
            case .fixing:   return "正在移除隔离属性…"
            case .success:  return "修复成功，可以正常打开"
            case .failed(let msg):
                let trimmed = msg.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? "修复失败" : trimmed
            }
        }

        var isTerminal: Bool {
            switch self {
            case .success, .failed: return true
            default: return false
            }
        }

        static func == (lhs: FixStatus, rhs: FixStatus) -> Bool {
            switch (lhs, rhs) {
            case (.pending, .pending),
                 (.fixing,  .fixing),
                 (.success, .success):
                return true
            case (.failed(let a), .failed(let b)):
                return a == b
            default:
                return false
            }
        }
    }

    static func == (lhs: AppItem, rhs: AppItem) -> Bool {
        lhs.id == rhs.id
    }
}
