import SwiftUI

struct SpendingLimitCardView: View {
    let title: String
    let spent: Double
    let limit: Double

    private var progress: Double {
        DashboardSpendingLimitSupport.progressValue(
            spent: spent,
            limit: limit
        )
    }

    private var isOverLimit: Bool {
        spent > limit && limit > 0
    }

    private var accentColor: Color {
        isOverLimit ? .red : AppColors.primaryTint
    }

    private var progressValue: Double {
        min(progress, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppColors.primaryText)

                    Text(statusText)
                        .font(.subheadline)
                        .foregroundStyle(
                            isOverLimit ? Color.red : AppColors.secondaryText
                        )
                }

                Spacer()

                Image(systemName: isOverLimit ? "exclamationmark.circle.fill" : "target")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(accentColor)
            }

            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppColors.inputBackground)

                        Capsule()
                            .fill(accentColor)
                            .frame(
                                width: max(
                                    10,
                                    geometry.size.width * progressValue
                                )
                            )
                    }
                }
                .frame(height: 10)

                HStack {
                    Text("Spent")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)

                    Spacer()

                    Text(spent, format: .currency(code: "EUR"))
                        .font(.caption.weight(.semibold))
                        .monospacedDigit()

                    Text("of")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)

                    Text(limit, format: .currency(code: "EUR"))
                        .font(.caption.weight(.semibold))
                        .monospacedDigit()
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .appCardStyle()
    }

    private var statusText: String {
        if limit <= 0 {
            return "No valid limit set"
        }

        if isOverLimit {
            let overAmount = spent - limit
            return "Over by \(overAmount.formatted(.currency(code: "EUR")))"
        } else {
            let remaining = limit - spent
            return "\(remaining.formatted(.currency(code: "EUR"))) remaining"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SpendingLimitCardView(
            title: "Monthly Limit",
            spent: 120,
            limit: 300
        )

        SpendingLimitCardView(
            title: "Monthly Limit",
            spent: 340,
            limit: 300
        )
    }
    .padding()
    .background(AppColors.screenBackground)
}
