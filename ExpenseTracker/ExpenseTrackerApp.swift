import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Expense.self, ExpenseCategory.self])
    }
}

private struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        MainTabView()
            .task {
                CategorySeeder.seedIfNeeded(in: modelContext)
            }
    }
}
