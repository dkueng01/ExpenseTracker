import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @AppStorage(SettingsStorage.isSpendingLimitEnabledKey)
    private var isSpendingLimitEnabled = false

    @AppStorage(SettingsStorage.spendingLimitAmountKey)
    private var spendingLimitAmount = 0.0

    @AppStorage(SettingsStorage.spendingLimitPeriodKey)
    private var spendingLimitPeriodRawValue =
        SpendingLimitPeriod.monthly.rawValue

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

    private var spendingLimitPeriod: SpendingLimitPeriod {
        SpendingLimitPeriod(rawValue: spendingLimitPeriodRawValue) ?? .monthly
    }

    private var currentLimitSpentAmount: Double {
        DashboardSpendingLimitSupport.spentAmount(
            for: spendingLimitPeriod,
            in: expenses
        )
    }

    private var shouldShowLimitCard: Bool {
        isSpendingLimitEnabled && spendingLimitAmount > 0
    }

    private var summaryColumns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [GridItem(.flexible())]
        } else {
            return [
                GridItem(.flexible(), spacing: AppSpacing.sm),
                GridItem(.flexible(), spacing: AppSpacing.sm),
            ]
        }
    }

    var body: some View {
        AppScreen(title: "Expenses") {
            overviewSection

            if shouldShowLimitCard {
                spendingLimitSection
            }

            recentExpensesSection
        } floatingAction: {
            AppFloatingActionButton(
                systemImage: "plus",
                accessibilityLabel: "Add expense",
                accessibilityHint: "Opens the form to create a new expense"
            ) {
                isShowingAddExpense = true
            }
        }
        .sheet(isPresented: $isShowingAddExpense) {
            AddExpenseView()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(item: $selectedExpense) { expense in
            EditExpenseView(expense: expense)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader(title: "Overview")

            LazyVGrid(columns: summaryColumns, spacing: AppSpacing.sm) {
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

    private var spendingLimitSection: some View {
        SpendingLimitCardView(
            title: DashboardSpendingLimitSupport.periodTitle(
                for: spendingLimitPeriod
            ),
            spent: currentLimitSpentAmount,
            limit: spendingLimitAmount
        )
    }

    private var recentExpensesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader(title: "Recent Expenses")

            Group {
                if expenses.isEmpty {
                    emptyStateContent
                        .padding(.horizontal, AppSpacing.xxl)
                        .padding(.vertical, 28)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(expenses.enumerated()), id: \.element.id) {
                            index,
                            expense in
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
                            .contextMenu {
                                Button {
                                    selectedExpense = expense
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }

                                Button(role: .destructive) {
                                    deleteExpense(expense)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }

                            if index < expenses.count - 1 {
                                Divider()
                                    .padding(.horizontal, AppSpacing.md)
                            }
                        }
                    }
                }
            }
            .appCardStyle()
        }
    }

    private var emptyStateContent: some View {
        VStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(AppColors.primaryTint)

            Text("No expenses yet")
                .font(.headline)

            Text("Tap the add button to create your first expense.")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func deleteExpense(_ expense: Expense) {
        modelContext.delete(expense)
        try? modelContext.save()
        AppWidgetReloader.reloadAll()
    }
}

#Preview {
    DashboardView()
        .modelContainer(
            for: [Expense.self, ExpenseCategory.self],
            inMemory: true
        )
}
