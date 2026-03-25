import Foundation
import SwiftData

enum AppModelContainer {
    static let appGroupID = "group.kcs.ExpenseTracker"

    static func make() throws -> ModelContainer {
        let schema = Schema([
            Expense.self,
            ExpenseCategory.self,
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    private static var storeURL: URL {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            fatalError("Could not resolve App Group container URL.")
        }

        return containerURL.appendingPathComponent("ExpenseTracker.store")
    }
}
