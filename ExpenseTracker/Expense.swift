import Foundation
import SwiftData

@Model
final class Expense {
    var amount: Double
    var category: String
    var note: String
    var date: Date

    init(
        amount: Double,
        category: String,
        note: String = "",
        date: Date = .now
    ) {
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
    }
}
