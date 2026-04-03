import SwiftData
import SwiftUI
import WidgetKit

struct WeeklySpendEntry: TimelineEntry {
    let date: Date
    let total: Double
    let expenseCount: Int
}

struct WeeklySpendProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeeklySpendEntry {
        WeeklySpendEntry(
            date: Date(),
            total: 105,
            expenseCount: 3
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (WeeklySpendEntry) -> Void
    ) {
        completion(loadEntry())
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<WeeklySpendEntry>) -> Void
    ) {
        let entry = loadEntry()

        let nextUpdate = Calendar.current.date(
            byAdding: .minute,
            value: 30,
            to: Date()
        ) ?? Date().addingTimeInterval(1800)

        let timeline = Timeline(
            entries: [entry],
            policy: .after(nextUpdate)
        )

        completion(timeline)
    }

    private func loadEntry() -> WeeklySpendEntry {
        do {
            let container = try AppModelContainer.make()
            let context = ModelContext(container)
            let summary = try ExpenseStatistics.weeklySpend(in: context)

            return WeeklySpendEntry(
                date: Date(),
                total: summary.total,
                expenseCount: summary.expenseCount
            )
        } catch {
            return WeeklySpendEntry(
                date: Date(),
                total: 0,
                expenseCount: 0
            )
        }
    }
}

struct WeeklySpendWidgetView: View {
    var entry: WeeklySpendProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)

                Text("This Week")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Text(entry.total, format: .currency(code: "EUR"))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.75)
                .lineLimit(1)

            Text(expenseSubtitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
        .containerBackground(.background, for: .widget)
    }

    private var expenseSubtitle: String {
        if entry.expenseCount == 1 {
            return "1 expense"
        } else {
            return "\(entry.expenseCount) expenses"
        }
    }
}

struct WeeklySpendWidget: Widget {
    let kind: String = "WeeklySpendWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: WeeklySpendProvider()
        ) { entry in
            WeeklySpendWidgetView(entry: entry)
        }
        .configurationDisplayName("Weekly Spend")
        .description("See how much you spent this week.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    WeeklySpendWidget()
} timeline: {
    WeeklySpendEntry(
        date: .now,
        total: 105,
        expenseCount: 3
    )
}
