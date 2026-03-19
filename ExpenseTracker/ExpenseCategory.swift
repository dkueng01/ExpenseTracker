import SwiftUI
import SwiftData

@Model
final class ExpenseCategory {
    @Attribute(.unique) var id: UUID
    var name: String
    var systemImage: String
    var colorName: String
    var sortOrder: Int
    var isFallback: Bool

    @Relationship(deleteRule: .nullify, inverse: \Expense.category)
    var expenses: [Expense] = []

    init(
        id: UUID = UUID(),
        name: String,
        systemImage: String,
        colorName: String,
        sortOrder: Int,
        isFallback: Bool = false
    ) {
        self.id = id
        self.name = name
        self.systemImage = systemImage
        self.colorName = colorName
        self.sortOrder = sortOrder
        self.isFallback = isFallback
    }

    var color: Color {
        CategoryColorOption(rawValue: colorName)?.color ?? .gray
    }
}
