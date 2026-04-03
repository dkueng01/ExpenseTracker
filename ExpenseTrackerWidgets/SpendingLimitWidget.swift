import SwiftData
import SwiftUI
import WidgetKit

struct SpendingLimitEntry: TimelineEntry {
    let date: Date
    let isEnabled: Bool
    let periodTitle: String
    let spent: Double
    let limit: Double
}

struct SpendingLimitProvider: TimelineProvider {
    func placeholder(in context: Context) -> SpendingLimitEntry {
        SpendingLimitEntry(
            date: Date(),
            isEnabled: true,
            periodTitle: "Monthly Limit",
            spent: 180,
            limit: 300
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (SpendingLimitEntry) -> Void
    ) {
        completion(loadEntry())
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<SpendingLimitEntry>) -> Void
    ) {
        let entry = loadEntry()

        let nextUpdate = Calendar.current.date(
            byAdding: .minute,
            value: 30,
            to: Date()
        ) ?? Date().addingTimeInterval(1800)

        completion(
            Timeline(entries: [entry], policy: .after(nextUpdate))
        )
    }

    private func loadEntry() -> SpendingLimitEntry {
        let defaults = SharedSettings.userDefaults

        let isEnabled = defaults.bool(
            forKey: SettingsStorage.isSpendingLimitEnabledKey
        )

        let limit = defaults.double(
            forKey: SettingsStorage.spendingLimitAmountKey
        )

        let rawPeriod = defaults.string(
            forKey: SettingsStorage.spendingLimitPeriodKey
        ) ?? SpendingLimitPeriod.monthly.rawValue

        let period = SpendingLimitPeriod(rawValue: rawPeriod) ?? .monthly

        guard isEnabled, limit > 0 else {
            return SpendingLimitEntry(
                date: Date(),
                isEnabled: false,
                periodTitle: DashboardSpendingLimitSupport.periodTitle(
                    for: period
                ),
                spent: 0,
                limit: 0
            )
        }

        do {
            let container = try AppModelContainer.make()
            let context = ModelContext(container)

            let descriptor = FetchDescriptor<Expense>()
            let expenses = try context.fetch(descriptor)

            let spent = DashboardSpendingLimitSupport.spentAmount(
                for: period,
                in: expenses
            )

            return SpendingLimitEntry(
                date: Date(),
                isEnabled: true,
                periodTitle: DashboardSpendingLimitSupport.periodTitle(
                    for: period
                ),
                spent: spent,
                limit: limit
            )
        } catch {
            return SpendingLimitEntry(
                date: Date(),
                isEnabled: true,
                periodTitle: DashboardSpendingLimitSupport.periodTitle(
                    for: period
                ),
                spent: 0,
                limit: limit
            )
        }
    }
}

struct SpendingLimitWidgetView: View {
    var entry: SpendingLimitProvider.Entry

    private var isOverLimit: Bool {
        entry.limit > 0 && entry.spent > entry.limit
    }

    private var accentColor: Color {
        isOverLimit ? .red : .blue
    }

    private var progress: Double {
        guard entry.limit > 0 else { return 0 }
        return min(entry.spent / entry.limit, 1)
    }

    var body: some View {
        Group {
            if entry.isEnabled {
                content
            } else {
                disabledContent
            }
        }
        .containerBackground(.background, for: .widget)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: isOverLimit ? "exclamationmark.circle.fill" : "target")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accentColor)

                Text(entry.periodTitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Text(entry.spent, format: .currency(code: "EUR"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.75)
                .lineLimit(1)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.18))

                    Capsule()
                        .fill(accentColor)
                        .frame(
                            width: max(8, geometry.size.width * progress)
                        )
                }
            }
            .frame(height: 8)

            Text(statusText)
                .font(.caption)
                .foregroundStyle(isOverLimit ? .red : .secondary)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
    }

    private var disabledContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)

                Text("Spending Limit")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Text("Not enabled")
                .font(.headline)

            Text("Enable a spending limit in Settings.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
    }

    private var statusText: String {
        if isOverLimit {
            let over = entry.spent - entry.limit
            return "Over by \(over.formatted(.currency(code: "EUR")))"
        } else {
            return "\(entry.spent.formatted(.currency(code: "EUR"))) of \(entry.limit.formatted(.currency(code: "EUR")))"
        }
    }
}

struct SpendingLimitWidget: Widget {
    let kind: String = "SpendingLimitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: SpendingLimitProvider()
        ) { entry in
            SpendingLimitWidgetView(entry: entry)
        }
        .configurationDisplayName("Spending Limit")
        .description("Track your current spending against your limit.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemSmall) {
    SpendingLimitWidget()
} timeline: {
    SpendingLimitEntry(
        date: .now,
        isEnabled: true,
        periodTitle: "Monthly Limit",
        spent: 180,
        limit: 300
    )
}
