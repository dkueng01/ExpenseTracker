import SwiftUI

struct AppFloatingActionButton: View {
    let systemImage: String
    let accessibilityLabel: String
    var accessibilityHint: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(
                    LinearGradient(
                        colors: [
                            AppColors.primaryTint,
                            AppColors.primaryTint.opacity(0.85),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(
                    color: AppShadows.floatingButtonColor,
                    radius: AppShadows.floatingButtonRadius,
                    x: 0,
                    y: AppShadows.floatingButtonYOffset
                )
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "")
    }
}

#Preview {
    AppFloatingActionButton(
        systemImage: "plus",
        accessibilityLabel: "Add expense",
        accessibilityHint: "Opens the form to create a new expense"
    ) {}
    .padding()
    .background(AppColors.screenBackground)
}
