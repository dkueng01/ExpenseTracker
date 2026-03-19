import SwiftUI

enum AppIconBadgeStyle {
    case circle
    case roundedRect
}

struct AppIconBadge: View {
    let systemImage: String
    let color: Color
    var size: CGFloat = 44
    var style: AppIconBadgeStyle = .circle

    var body: some View {
        ZStack {
            backgroundShape

            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var backgroundShape: some View {
        switch style {
        case .circle:
            Circle()
                .fill(color.opacity(0.14))

        case .roundedRect:
            RoundedRectangle(
                cornerRadius: AppRadius.sm,
                style: .continuous
            )
            .fill(color.opacity(0.14))
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AppIconBadge(systemImage: "fork.knife", color: .orange)

        AppIconBadge(
            systemImage: "calendar",
            color: .green,
            size: 42,
            style: .roundedRect
        )
    }
    .padding()
    .background(AppColors.screenBackground)
}
