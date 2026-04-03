import SwiftUI

struct InsightStatCard: View {
    let title: String
    let amount: Double
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            AppIconBadge(
                systemImage: systemImage,
                color: color,
                size: 40,
                style: .roundedRect
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppColors.secondaryText)

                Text(amount, format: .currency(code: "EUR"))
                    .font(.title3.bold())
                    .monospacedDigit()
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .padding(AppSpacing.cardPadding)
        .appCardStyle()
    }
}

#Preview {
    VStack(spacing: 12) {
        InsightStatCard(
            title: "This Week",
            amount: 52,
            systemImage: "calendar",
            color: .blue
        )

        InsightStatCard(
            title: "All Time",
            amount: 1250,
            systemImage: "clock.fill",
            color: .purple
        )
    }
    .padding()
    .background(AppColors.screenBackground)
}
