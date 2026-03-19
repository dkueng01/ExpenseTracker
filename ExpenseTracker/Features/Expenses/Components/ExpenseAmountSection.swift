import SwiftUI

struct ExpenseAmountSection: View {
    @Binding var amountText: String

    let quickAmounts: [Double]
    let amountFieldFocus: FocusState<Bool>.Binding
    let onQuickAmountTap: (Double) -> Void

    var body: some View {
        AppFormSection(title: "Amount") {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                HStack(
                    alignment: .firstTextBaseline,
                    spacing: AppSpacing.xs
                ) {
                    Text("€")
                        .font(.appAmountSymbol)
                        .foregroundStyle(AppColors.secondaryText)

                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(.appAmountValue)
                        .focused(amountFieldFocus)
                        .accessibilityLabel("Amount")
                }

                LazyVGrid(
                    columns: [
                        GridItem(
                            .adaptive(minimum: 72),
                            spacing: AppSpacing.sm
                        ),
                    ],
                    spacing: AppSpacing.sm
                ) {
                    ForEach(quickAmounts, id: \.self) { value in
                        Button {
                            onQuickAmountTap(value)
                        } label: {
                            Text(value, format: .currency(code: "EUR"))
                                .font(.appBodyStrong)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.sm)
                                .background(
                                    AppColors.primaryTint.opacity(0.10)
                                )
                                .foregroundStyle(AppColors.primaryTint)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: AppRadius.sm,
                                        style: .continuous
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(AppSpacing.contentPadding)
            .appPanelStyle()
        }
    }
}
