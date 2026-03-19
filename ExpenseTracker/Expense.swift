import Foundation
import SwiftData

@Model
final class Expense {
    var amount: Double
    var note: String
    var date: Date
    var category: ExpenseCategory?

    init(
        amount: Double,
        category: ExpenseCategory? = nil,
        note: String = "",
        date: Date = .now
    ) {
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
    }
}
