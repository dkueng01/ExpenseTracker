import SwiftUI

struct SummaryCardView: View {
    let title: String
    let amount: Double
    let color: Color
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            AppIconBadge(
                systemImage: systemImage,
                color: color,
                size: 42,
                style: .roundedRect
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppColors.secondaryText)

                Text(amount, format: .currency(code: "EUR"))
                    .font(.title3.bold())
                    .monospacedDigit()
                    .minimumScaleFactor(0.85)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .padding(AppSpacing.cardPadding)
        .appCardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) total")
        .accessibilityValue(Text(amount, format: .currency(code: "EUR")))
    }
}

#Preview {
    VStack(spacing: 12) {
        SummaryCardView(
            title: "Today",
            amount: 20,
            color: .blue,
            systemImage: "sun.max.fill"
        )

        SummaryCardView(
            title: "This Month",
            amount: 120,
            color: .green,
            systemImage: "calendar"
        )
    }
    .padding()
    .background(AppColors.screenBackground)
}
