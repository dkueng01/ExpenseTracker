import SwiftUI

struct SummaryCardView: View {
    let title: String
    let amount: Double
    let color: Color
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 42, height: 42)

                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Text(amount, format: .currency(code: "EUR"))
                    .font(.title3.bold())
                    .monospacedDigit()
                    .minimumScaleFactor(0.85)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.separator).opacity(0.10), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
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
    .background(Color(.systemGroupedBackground))
}
