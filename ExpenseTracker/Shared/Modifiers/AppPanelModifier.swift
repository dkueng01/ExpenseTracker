import SwiftUI

struct AppPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.elevatedBackground)
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
                color: Color.black.opacity(0.02),
                radius: 6,
                x: 0,
                y: 2
            )
    }
}

extension View {
    func appPanelStyle() -> some View {
        modifier(AppPanelModifier())
    }
}
