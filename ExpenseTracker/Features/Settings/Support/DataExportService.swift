import Foundation

struct ExportExpense: Codable {
    let amount: Double
    let note: String
    let date: Date
    let categoryName: String?
}

struct ExportCategory: Codable {
    let id: UUID
    let name: String
    let systemImage: String
    let colorName: String
    let sortOrder: Int
    let isFallback: Bool
}

struct ExportPayload: Codable {
    let exportedAt: Date
    let expenses: [ExportExpense]
    let categories: [ExportCategory]
}

enum DataExportService {
    static func makeExportData(
        expenses: [Expense],
        categories: [ExpenseCategory]
    ) throws -> Data {
        let payload = ExportPayload(
            exportedAt: Date(),
            expenses: expenses.map {
                ExportExpense(
                    amount: $0.amount,
                    note: $0.note,
                    date: $0.date,
                    categoryName: $0.category?.name
                )
            },
            categories: categories.map {
                ExportCategory(
                    id: $0.id,
                    name: $0.name,
                    systemImage: $0.systemImage,
                    colorName: $0.colorName,
                    sortOrder: $0.sortOrder,
                    isFallback: $0.isFallback
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        return try encoder.encode(payload)
    }
}
