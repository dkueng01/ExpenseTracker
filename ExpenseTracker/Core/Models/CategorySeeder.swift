import SwiftData

enum CategorySeeder {
    static func seedIfNeeded(in modelContext: ModelContext) {
        let descriptor = FetchDescriptor<ExpenseCategory>()
        let categories = (try? modelContext.fetch(descriptor)) ?? []

        if categories.isEmpty {
            defaultCategories().forEach { modelContext.insert($0) }
            try? modelContext.save()
            return
        }

        if !categories.contains(where: { $0.isFallback }) {
            let nextSortOrder = (categories.map(\.sortOrder).max() ?? -1) + 1

            let fallbackCategory = ExpenseCategory(
                name: "Other",
                systemImage: CategoryIconOption.other.rawValue,
                colorName: CategoryColorOption.gray.rawValue,
                sortOrder: nextSortOrder,
                isFallback: true
            )

            modelContext.insert(fallbackCategory)
            try? modelContext.save()
        }
    }

    private static func defaultCategories() -> [ExpenseCategory] {
        [
            ExpenseCategory(
                name: "Food",
                systemImage: CategoryIconOption.forkKnife.rawValue,
                colorName: CategoryColorOption.orange.rawValue,
                sortOrder: 0
            ),
            ExpenseCategory(
                name: "Transport",
                systemImage: CategoryIconOption.car.rawValue,
                colorName: CategoryColorOption.blue.rawValue,
                sortOrder: 1
            ),
            ExpenseCategory(
                name: "Shopping",
                systemImage: CategoryIconOption.bag.rawValue,
                colorName: CategoryColorOption.pink.rawValue,
                sortOrder: 2
            ),
            ExpenseCategory(
                name: "Bills",
                systemImage: CategoryIconOption.bills.rawValue,
                colorName: CategoryColorOption.purple.rawValue,
                sortOrder: 3
            ),
            ExpenseCategory(
                name: "Health",
                systemImage: CategoryIconOption.health.rawValue,
                colorName: CategoryColorOption.red.rawValue,
                sortOrder: 4
            ),
            ExpenseCategory(
                name: "Fun",
                systemImage: CategoryIconOption.fun.rawValue,
                colorName: CategoryColorOption.green.rawValue,
                sortOrder: 5
            ),
            ExpenseCategory(
                name: "Other",
                systemImage: CategoryIconOption.other.rawValue,
                colorName: CategoryColorOption.gray.rawValue,
                sortOrder: 6,
                isFallback: true
            ),
        ]
    }
}
