import SwiftUI

struct AppPrimaryButton: View {
    let title: String
    var trailingText: String? = nil
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.appButton)

                Spacer()

                if let trailingText {
                    Text(trailingText)
                        .font(.appButton)
                        .monospacedDigit()
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.contentPadding)
            .padding(.vertical, AppSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                isEnabled
                    ? AppColors.primaryTint
                    : AppColors.disabledButton
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppRadius.button,
                    style: .continuous
                )
            )
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        AppPrimaryButton(title: "Save Expense") {}

        AppPrimaryButton(
            title: "Save Expense",
            trailingText: "€ 23,50"
        ) {}

        AppPrimaryButton(
            title: "Save Expense",
            trailingText: "€ 23,50",
            isEnabled: false
        ) {}
    }
    .padding()
}
