import SwiftUI

// MARK: - History Row

struct HistoryRowView: View {
    let item: AppItem
    let onRetry: () -> Void
    let onOpen:  () -> Void
    let onRemove: () -> Void

    @State private var isHovering = false
    @State private var appear = false

    var body: some View {
        HStack(spacing: 12) {
            // App icon
            Image(nsImage: item.icon)
                .resizable()
                .interpolation(.high)
                .frame(width: 38, height: 38)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)

            // Name + status
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 5) {
                    statusDot
                    Text(item.status.displayText)
                        .font(.system(size: 11.5))
                        .foregroundColor(statusColor)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Action buttons
            HStack(spacing: 6) {
                if case .failed = item.status {
                    actionButton(label: "重试", icon: "arrow.clockwise", action: onRetry)
                }
                if case .success = item.status {
                    actionButton(label: "打开", icon: "arrow.up.forward.app", primary: true, action: onOpen)
                }
                if case .fixing = item.status {
                    ProgressView()
                        .scaleEffect(0.65)
                        .frame(width: 28, height: 28)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isHovering ? Color.primary.opacity(0.045) : Color.clear)
        )
        .overlay(alignment: .trailing) {
            // Delete button on hover
            if isHovering && item.status.isTerminal {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isHovering)
        .onHover { isHovering = $0 }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 12)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                appear = true
            }
        }
    }

    // MARK: - Sub-views

    private var statusDot: some View {
        Group {
            switch item.status {
            case .fixing:
                ProgressView()
                    .scaleEffect(0.5)
                    .frame(width: 8, height: 8)
            case .success:
                Circle().fill(Color.green).frame(width: 7, height: 7)
            case .failed:
                Circle().fill(Color.red).frame(width: 7, height: 7)
            case .pending:
                Circle().fill(Color.secondary.opacity(0.5)).frame(width: 7, height: 7)
            }
        }
    }

    private var statusColor: Color {
        switch item.status {
        case .success:     return .green
        case .failed:      return .red
        case .fixing:      return .accentColor
        case .pending:     return .secondary
        }
    }

    private func actionButton(
        label: String,
        icon: String,
        primary: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                Text(label)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(primary ? Color.accentColor : Color.secondary.opacity(0.18))
            )
            .foregroundColor(primary ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}
