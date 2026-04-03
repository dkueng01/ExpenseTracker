import SwiftData
import SwiftUI

struct InsightsView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @State private var selectedRange: InsightsTimeRange = .year
    @State private var customStartDate: Date = Calendar.current.date(
        byAdding: .month,
        value: -1,
        to: Date()
    ) ?? Date()
    @State private var customEndDate: Date = Date()

    private var filteredExpenses: [Expense] {
        InsightsCalculator.filteredExpenses(
            from: expenses,
            range: selectedRange,
            customStartDate: customStartDate,
            customEndDate: normalizedCustomEndDate
        )
    }

    private var totalSpend: Double {
        InsightsCalculator.totalSpend(from: filteredExpenses)
    }

    private var topCategories: [CategorySpend] {
        InsightsCalculator.topCategories(from: filteredExpenses, limit: 5)
    }

    private var rangeDescription: String {
        InsightsCalculator.dateRangeDescription(
            for: selectedRange,
            customStartDate: customStartDate,
            customEndDate: normalizedCustomEndDate
        )
    }

    private var normalizedCustomEndDate: Date {
        if customEndDate < customStartDate {
            return customStartDate
        } else {
            return customEndDate
        }
    }

    var body: some View {
        AppScreen(title: "Insights") {
            rangeSection
            totalSection
            topCategoriesSection
        }
    }

    private var rangeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader(title: "Time Range")

            InsightsRangePicker(selectedRange: $selectedRange)
                .padding(.horizontal, -AppSpacing.pageHorizontal)

            if selectedRange == .custom {
                VStack(spacing: AppSpacing.md) {
                    DatePicker(
                        "From",
                        selection: $customStartDate,
                        displayedComponents: [.date]
                    )

                    DatePicker(
                        "To",
                        selection: $customEndDate,
                        in: customStartDate...,
                        displayedComponents: [.date]
                    )
                }
                .padding(AppSpacing.contentPadding)
                .appCardStyle()
            }
        }
    }

    private var totalSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader(title: "Total Spend")

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(rangeDescription)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)

                Text(totalSpend, format: .currency(code: "EUR"))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)

                Text(expenseCountText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppColors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.cardPadding)
            .appCardStyle()
        }
    }

    private var topCategoriesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader(title: "Top Categories")

            Group {
                if topCategories.isEmpty {
                    emptyState
                        .padding(.horizontal, AppSpacing.xxl)
                        .padding(.vertical, 28)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(topCategories.enumerated()), id: \.element.id) {
                            index,
                            item in
                            CategorySpendRowView(item: item)

                            if index < topCategories.count - 1 {
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

    private var expenseCountText: String {
        let count = filteredExpenses.count

        if count == 1 {
            return "1 expense"
        } else {
            return "\(count) expenses"
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.pie")
                .font(.system(size: 34))
                .foregroundStyle(AppColors.primaryTint)

            Text("No insights for this range")
                .font(.headline)

            Text("Try another time range or add expenses in this period.")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    InsightsView()
        .modelContainer(
            for: [Expense.self, ExpenseCategory.self],
            inMemory: true
        )
}
