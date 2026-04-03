import Foundation

struct CategorySpend: Identifiable {
    let id: UUID
    let name: String
    let systemImage: String
    let color: String
    let amount: Double
    let percentage: Double
}

enum InsightsCalculator {
    static func filteredExpenses(
        from expenses: [Expense],
        range: InsightsTimeRange,
        customStartDate: Date,
        customEndDate: Date
    ) -> [Expense] {
        let calendar = Calendar.current
        let now = Date()

        switch range {
        case .week:
            guard let interval = calendar.dateInterval(
                of: .weekOfYear,
                for: now
            ) else {
                return []
            }

            return expenses.filter { interval.contains($0.date) }

        case .month:
            guard let interval = calendar.dateInterval(of: .month, for: now)
            else {
                return []
            }

            return expenses.filter { interval.contains($0.date) }

        case .year:
            guard let interval = calendar.dateInterval(of: .year, for: now)
            else {
                return []
            }

            return expenses.filter { interval.contains($0.date) }

        case .allTime:
            return expenses

        case .custom:
            let startOfDay = calendar.startOfDay(for: customStartDate)
            guard let endOfDay = calendar.date(
                byAdding: DateComponents(day: 1, second: -1),
                to: calendar.startOfDay(for: customEndDate)
            ) else {
                return []
            }

            return expenses.filter {
                $0.date >= startOfDay && $0.date <= endOfDay
            }
        }
    }

    static func totalSpend(from expenses: [Expense]) -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    static func topCategories(
        from expenses: [Expense],
        limit: Int? = nil
    ) -> [CategorySpend] {
        let validExpenses = expenses.compactMap { expense -> (
            id: UUID,
            name: String,
            systemImage: String,
            colorName: String,
            amount: Double
        )? in
            guard let category = expense.category else { return nil }

            return (
                id: category.id,
                name: category.name,
                systemImage: category.systemImage,
                colorName: category.colorName,
                amount: expense.amount
            )
        }

        let grouped = Dictionary(grouping: validExpenses, by: \.id)
        let totalSpend = validExpenses.reduce(0) { $0 + $1.amount }

        let result = grouped.compactMap { _, items -> CategorySpend? in
            guard let first = items.first else { return nil }

            let amount = items.reduce(0) { $0 + $1.amount }
            let percentage = totalSpend > 0 ? amount / totalSpend : 0

            return CategorySpend(
                id: first.id,
                name: first.name,
                systemImage: first.systemImage,
                color: first.colorName,
                amount: amount,
                percentage: percentage
            )
        }
        .sorted { $0.amount > $1.amount }

        if let limit {
            return Array(result.prefix(limit))
        } else {
            return result
        }
    }

    static func dateRangeDescription(
        for range: InsightsTimeRange,
        customStartDate: Date,
        customEndDate: Date
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        switch range {
        case .week:
            return "This week"

        case .month:
            return "This month"

        case .year:
            return "This year"

        case .allTime:
            return "All recorded expenses"

        case .custom:
            let start = formatter.string(from: customStartDate)
            let end = formatter.string(from: customEndDate)
            return "\(start) – \(end)"
        }
    }
}
