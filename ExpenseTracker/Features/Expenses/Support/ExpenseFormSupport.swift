import Foundation

enum ExpenseFormSupport {
    static let quickAmounts: [Double] = [5, 10, 20, 50]

    static func parseAmount(from text: String) -> Double? {
        let cleanedAmount = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        return Double(cleanedAmount)
    }

    static func formattedAmountString(for value: Double) -> String {
        if value == floor(value) {
            return String(Int(value))
        } else {
            return String(format: "%.2f", value)
        }
    }

    static func addingQuickAmount(
        _ value: Double,
        to amountText: String
    ) -> String {
        let currentAmount = parseAmount(from: amountText) ?? 0
        let newAmount = currentAmount == 0 ? value : currentAmount + value
        return formattedAmountString(for: newAmount)
    }

    static func fallbackCategory(
        in categories: [ExpenseCategory]
    ) -> ExpenseCategory? {
        categories.first(where: { $0.isFallback }) ?? categories.first
    }

    static func selectedCategory(
        for selectedCategoryID: UUID?,
        in categories: [ExpenseCategory]
    ) -> ExpenseCategory? {
        if let selectedCategoryID {
            return categories.first(where: { $0.id == selectedCategoryID })
                ?? fallbackCategory(in: categories)
        }

        return fallbackCategory(in: categories)
    }
}
