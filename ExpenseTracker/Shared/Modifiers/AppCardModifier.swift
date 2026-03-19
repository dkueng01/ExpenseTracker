import SwiftUI

struct AppCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.cardBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppRadius.card,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: AppRadius.card,
                    style: .continuous
                )
                .stroke(AppColors.cardBorder, lineWidth: 1)
            }
            .shadow(
                color: AppShadows.cardColor,
                radius: AppShadows.cardRadius,
                x: 0,
                y: AppShadows.cardYOffset
            )
    }
}

extension View {
    func appCardStyle() -> some View {
        modifier(AppCardModifier())
    }
}
