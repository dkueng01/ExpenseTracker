import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "list.bullet.rectangle")
                }
            
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }

            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2.fill")
                }
        }
    }
}
