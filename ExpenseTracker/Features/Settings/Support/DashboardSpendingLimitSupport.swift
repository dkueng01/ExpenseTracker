import Foundation

enum DashboardSpendingLimitSupport {
    static func spentAmount(
        for period: SpendingLimitPeriod,
        in expenses: [Expense]
    ) -> Double {
        let calendar = Calendar.current
        let now = Date()

        switch period {
        case .daily:
            return expenses
                .filter { calendar.isDate($0.date, inSameDayAs: now) }
                .reduce(0) { $0 + $1.amount }

        case .weekly:
            guard let interval = calendar.dateInterval(
                of: .weekOfYear,
                for: now
            ) else {
                return 0
            }

            return expenses
                .filter { interval.contains($0.date) }
                .reduce(0) { $0 + $1.amount }

        case .monthly:
            guard let interval = calendar.dateInterval(of: .month, for: now)
            else {
                return 0
            }

            return expenses
                .filter { interval.contains($0.date) }
                .reduce(0) { $0 + $1.amount }
        }
    }

    static func periodTitle(for period: SpendingLimitPeriod) -> String {
        switch period {
        case .daily:
            return "Daily Limit"
        case .weekly:
            return "Weekly Limit"
        case .monthly:
            return "Monthly Limit"
        }
    }

    static func progressValue(spent: Double, limit: Double) -> Double {
        guard limit > 0 else { return 0 }
        return spent / limit
    }
}
