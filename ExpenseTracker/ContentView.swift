import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @State private var isShowingAddExpense = false
    @State private var selectedExpense: Expense?

    private var todayTotal: Double {
        expenses
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    private var monthTotal: Double {
        guard let monthInterval = Calendar.current.dateInterval(
            of: .month,
            for: Date()
        ) else {
            return 0
        }

        return expenses
            .filter { monthInterval.contains($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    private var summaryColumns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [GridItem(.flexible())]
        } else {
            return [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ]
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        overviewSection
                        recentExpensesSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
                .scrollIndicators(.hidden)
                .background(Color(.systemGroupedBackground))

                addButton
            }
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isShowingAddExpense) {
                AddExpenseView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedExpense) { expense in
                EditExpenseView(expense: expense)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.title3.bold())

            LazyVGrid(columns: summaryColumns, spacing: 12) {
                SummaryCardView(
                    title: "Today",
                    amount: todayTotal,
                    color: .blue,
                    systemImage: "sun.max.fill"
                )

                SummaryCardView(
                    title: "This Month",
                    amount: monthTotal,
                    color: .green,
                    systemImage: "calendar"
                )
            }
        }
    }

    private var recentExpensesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Expenses")
                .font(.title3.bold())

            if expenses.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.blue)

                    Text("No expenses yet")
                        .font(.headline)

                    Text("Tap the add button to create your first expense.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .padding(.horizontal, 20)
                .background(Color(.secondarySystemBackground))
                .clipShape(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(expenses) { expense in
                        Button {
                            selectedExpense = expense
                        } label: {
                            ExpenseRowView(expense: expense)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens this expense for editing")
                    }
                }
            }
        }
    }

    private var addButton: some View {
        Button {
            isShowingAddExpense = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: .blue.opacity(0.25), radius: 10, y: 6)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .accessibilityLabel("Add expense")
        .accessibilityHint("Opens the form to create a new expense")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}
