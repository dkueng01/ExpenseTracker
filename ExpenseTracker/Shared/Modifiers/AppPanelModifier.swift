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
    }
}

extension View {
    func appPanelStyle() -> some View {
        modifier(AppPanelModifier())
    }
}
