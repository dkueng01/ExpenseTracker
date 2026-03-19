import SwiftUI

enum AppInputSurfaceStyle {
    case elevated
    case inset

    var backgroundColor: Color {
        switch self {
        case .elevated:
            return AppColors.elevatedBackground
        case .inset:
            return AppColors.inputBackground
        }
    }
}

struct AppInputFieldModifier: ViewModifier {
    let style: AppInputSurfaceStyle

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.md)
            .background(style.backgroundColor)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppRadius.sm,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: AppRadius.sm,
                    style: .continuous
                )
                .stroke(AppColors.controlBorder, lineWidth: 1)
            }
    }
}

extension View {
    func appInputFieldStyle(_ style: AppInputSurfaceStyle = .inset)
        -> some View {
        modifier(AppInputFieldModifier(style: style))
    }
}
