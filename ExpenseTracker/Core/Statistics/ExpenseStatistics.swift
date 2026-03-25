import Foundation
import SwiftData

struct WeeklySpendSummary {
    let total: Double
    let expenseCount: Int
}

enum ExpenseStatistics {
    static func weeklySpend(in context: ModelContext) throws
        -> WeeklySpendSummary {
        let descriptor = FetchDescriptor<Expense>()
        let expenses = try context.fetch(descriptor)

        let calendar = Calendar.current
        let now = Date()

        guard let weekInterval = calendar.dateInterval(
            of: .weekOfYear,
            for: now
        ) else {
            return WeeklySpendSummary(total: 0, expenseCount: 0)
        }

        let weeklyExpenses = expenses.filter { weekInterval.contains($0.date) }

        let total = weeklyExpenses.reduce(0) { partialResult, expense in
            partialResult + expense.amount
        }

        return WeeklySpendSummary(
            total: total,
            expenseCount: weeklyExpenses.count
        )
    }
}
