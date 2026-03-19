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
                List {
                    Section {
                        overviewSection
                            .listRowInsets(
                                EdgeInsets(
                                    top: 8,
                                    leading: 20,
                                    bottom: 8,
                                    trailing: 20
                                )
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } header: {
                        EmptyView()
                    }

                    Section("Recent Expenses") {
                        recentExpensesCard
                            .listRowInsets(
                                EdgeInsets(
                                    top: 4,
                                    leading: 20,
                                    bottom: 12,
                                    trailing: 20
                                )
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Expenses")
                .navigationBarTitleDisplayMode(.large)
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

                addButton
            }
            .background(Color(.systemGroupedBackground))
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

    private var recentExpensesCard: some View {
        Group {
            if expenses.isEmpty {
                emptyStateContent
                    .padding(.horizontal, 20)
                    .padding(.vertical, 28)
            } else {
                VStack(spacing: 0) {
                    ForEach(expenses.indices, id: \.self) { index in
                        let expense = expenses[index]

                        Button {
                            selectedExpense = expense
                        } label: {
                            ExpenseRowView(
                                expense: expense,
                                showsBackground: false
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens this expense for editing")

                        if index < expenses.count - 1 {
                            Divider()
                                .padding(.horizontal, 14)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.separator).opacity(0.10), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
    }

    private var emptyStateContent: some View {
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
        .modelContainer(
            for: [Expense.self, ExpenseCategory.self],
            inMemory: true
        )
}
