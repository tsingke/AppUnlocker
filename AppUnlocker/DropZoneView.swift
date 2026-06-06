import SwiftUI
import UniformTypeIdentifiers

// MARK: - Drop Zone

struct DropZoneView: View {
    @ObservedObject var viewModel: AppUnlockerViewModel
    @State private var dashPhase: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var lockRotation: Double = 0

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(viewModel.isHovering
                      ? Color.accentColor.opacity(0.08)
                      : Color.primary.opacity(0.03))
                .animation(.easeInOut(duration: 0.2), value: viewModel.isHovering)

            // Dashed border
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(style: StrokeStyle(
                    lineWidth: 2,
                    dash: [8, 6],
                    dashPhase: dashPhase
                ))
                .foregroundColor(viewModel.isHovering
                                 ? Color.accentColor
                                 : Color.primary.opacity(0.25))
                .animation(.easeInOut(duration: 0.2), value: viewModel.isHovering)
                .onAppear {
                    withAnimation(.linear(duration: 24).repeatForever(autoreverses: false)) {
                        dashPhase = -280
                    }
                }

            // Content
            VStack(spacing: 18) {
                // Icon
                ZStack {
                    Circle()
                        .fill(viewModel.isHovering
                              ? Color.accentColor.opacity(0.15)
                              : Color.secondary.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulseScale)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                pulseScale = 1.06
                            }
                        }

                    Image(systemName: viewModel.isHovering ? "lock.open.fill" : "lock.fill")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundColor(viewModel.isHovering ? .accentColor : .secondary)
                        .rotationEffect(.degrees(lockRotation))
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.isHovering)
                }

                VStack(spacing: 8) {
                    Text(viewModel.isHovering ? "松开以修复" : "拖入应用程序")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(viewModel.isHovering ? .accentColor : .primary)
                        .animation(.easeInOut(duration: 0.15), value: viewModel.isHovering)

                    Text(viewModel.isHovering
                         ? "将自动移除隔离属性"
                         : "或点击下方按钮选择 .app 文件")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.15), value: viewModel.isHovering)
                }
            }
            .padding(32)
        }
        .frame(height: 210)
        // Drop target
        .onDrop(of: [.fileURL], isTargeted: $viewModel.isHovering) { providers in
            resolveProviders(providers)
            return true
        }
    }

    // MARK: - Drop resolution

    private func resolveProviders(_ providers: [NSItemProvider]) {
        var urls: [URL] = []
        let group = DispatchGroup()

        for provider in providers {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { item, _ in
                defer { group.leave() }
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    urls.append(url)
                } else if let url = item as? URL {
                    urls.append(url)
                }
            }
        }

        group.notify(queue: .main) {
            viewModel.handleDroppedURLs(urls)
        }
    }
}
