import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @StateObject private var viewModel = AppUnlockerViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .windowBackgroundColor).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Title bar region ──
                titleBar

                // ── Main scrollable body ──
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Drop zone
                        DropZoneView(viewModel: viewModel)
                            .padding(.horizontal, 24)

                        // "Select App" button
                        selectButton

                        // History section
                        if !viewModel.items.isEmpty {
                            historySection
                        } else {
                            emptyHint
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 18)
                }
            }
        }
        .frame(width: 540)
    }

    // MARK: - Title bar

    private var titleBar: some View {
        HStack(spacing: 10) {
            // Native traffic lights already visible — just reserve space so title stays centred
            Color.clear
                .frame(width: 68, height: 1)
                .padding(.leading, 14)

            Spacer()

            // App name
            HStack(spacing: 6) {
                Image(systemName: "lock.open.rotation")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.accentColor)
                Text("AppUnlocker")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.primary)

            Spacer()

            // Clear all button
            if !viewModel.items.isEmpty {
                Button(action: { withAnimation { viewModel.clearAll() } }) {
                    Text("清除全部")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 14)
                .transition(.opacity)
            } else {
                Color.clear.frame(width: 60, height: 1)
                    .padding(.trailing, 14)
            }
        }
        .frame(height: 44)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: - Select button

    private var selectButton: some View {
        Button(action: viewModel.openFilePicker) {
            HStack(spacing: 8) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 14, weight: .medium))
                Text("选择应用程序")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.accentColor)
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.accentColor.opacity(0.5), lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.accentColor.opacity(0.06))
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - History section

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Text("修复记录")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Spacer()

                Text("\(viewModel.items.count) 个应用")
                    .font(.system(size: 11.5))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)

            // Cards
            VStack(spacing: 2) {
                ForEach(viewModel.items) { item in
                    HistoryRowView(
                        item: item,
                        onRetry:  { viewModel.retryFix(item) },
                        onOpen:   { viewModel.openApp(item) },
                        onRemove: { withAnimation { viewModel.remove(item) } }
                    )
                    .padding(.horizontal, 12)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.primary.opacity(0.035))
            )
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Empty hint

    private var emptyHint: some View {
        VStack(spacing: 8) {
            Text("修复成功的应用将显示在这里")
                .font(.system(size: 12.5))
                .foregroundColor(.secondary.opacity(0.6))

            HStack(spacing: 6) {
                tagChip("com.apple.quarantine")
                Image(systemName: "arrow.right")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.5))
                tagChip("已移除", color: .green)
            }
        }
        .padding(.top, 8)
    }

    private func tagChip(_ text: String, color: Color = .secondary) -> some View {
        Text(text)
            .font(.system(size: 10.5, design: .monospaced))
            .foregroundColor(color.opacity(0.7))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(color.opacity(0.1))
            )
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
