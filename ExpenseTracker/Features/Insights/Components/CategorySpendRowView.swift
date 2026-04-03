import SwiftUI

struct CategorySpendRowView: View {
    let item: CategorySpend

    private var categoryColor: Color {
        CategoryColorOption(rawValue: item.color)?.color ?? .gray
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                AppIconBadge(
                    systemImage: item.systemImage,
                    color: categoryColor,
                    size: 40,
                    style: .circle
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.appCardTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Text(item.percentage, format: .percent.precision(.fractionLength(0)))
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer()

                Text(item.amount, format: .currency(code: "EUR"))
                    .font(.headline.weight(.semibold))
                    .monospacedDigit()
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.inputBackground)

                    Capsule()
                        .fill(categoryColor)
                        .frame(
                            width: max(8, geometry.size.width * item.percentage)
                        )
                }
            }
            .frame(height: 8)
        }
        .padding(AppSpacing.md)
    }
}

#Preview {
    let item = CategorySpend(
        id: UUID(),
        name: "Food",
        systemImage: "fork.knife",
        color: "orange",
        amount: 120,
        percentage: 0.42
    )

    CategorySpendRowView(item: item)
        .padding()
        .background(AppColors.screenBackground)
}
