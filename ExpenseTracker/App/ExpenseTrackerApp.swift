import SwiftData
import SwiftUI

@main
struct ExpenseTrackerApp: App {
    private let sharedModelContainer: ModelContainer = {
        do {
            return try AppModelContainer.make()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
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
