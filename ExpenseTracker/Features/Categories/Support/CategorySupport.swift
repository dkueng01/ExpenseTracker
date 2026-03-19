import SwiftUI

enum CategorySupport {
    static let defaultIcon = CategoryIconOption.tag.rawValue
    static let defaultColorName = CategoryColorOption.blue.rawValue

    static func trimmedName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func isDuplicateName(
        _ name: String,
        currentCategoryID: UUID?,
        in categories: [ExpenseCategory]
    ) -> Bool {
        let trimmed = trimmedName(name)

        return categories.contains { existingCategory in
            existingCategory.id != currentCategoryID
                && trimmedName(existingCategory.name)
                    .localizedCaseInsensitiveCompare(trimmed) == .orderedSame
        }
    }

    static func selectedColor(for colorName: String) -> Color {
        CategoryColorOption(rawValue: colorName)?.color ?? .blue
    }

    static func usageSubtitle(for category: ExpenseCategory) -> String {
        let count = category.expenses.count

        if count == 1 {
            return "Used by 1 expense"
        } else {
            return "Used by \(count) expenses"
        }
    }

    static func fallbackCategory(
        in categories: [ExpenseCategory]
    ) -> ExpenseCategory? {
        categories.first(where: { $0.isFallback }) ?? categories.first
    }

    static func deleteMessage(
        for category: ExpenseCategory?,
        fallbackCategory: ExpenseCategory?
    ) -> String {
        guard let category else { return "" }

        let expenseCount = category.expenses.count

        if expenseCount == 0 {
            return "This category will be removed."
        }

        let fallbackName = fallbackCategory?.name ?? "the fallback category"

        if expenseCount == 1 {
            return "This category will be removed and its 1 expense "
                + "will be moved to \(fallbackName)."
        } else {
            return "This category will be removed and its \(expenseCount) "
                + "expenses will be moved to \(fallbackName)."
        }
    }
}
