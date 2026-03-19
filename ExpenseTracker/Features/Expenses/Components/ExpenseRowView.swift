import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense
    var showsBackground = true

    private var categoryName: String {
        expense.category?.name ?? "Uncategorized"
    }

    private var categoryImage: String {
        expense.category?.systemImage ?? "square.grid.2x2.fill"
    }

    private var categoryColor: Color {
        expense.category?.color ?? .gray
    }

    var body: some View {
        if showsBackground {
            rowContent
                .appCardStyle()
        } else {
            rowContent
        }
    }

    private var rowContent: some View {
        HStack(spacing: AppSpacing.md) {
            AppIconBadge(
                systemImage: categoryImage,
                color: categoryColor,
                size: 44,
                style: .circle
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(categoryName)
                    .font(.appCardTitle)
                    .foregroundStyle(AppColors.primaryText)

                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                } else {
                    Text(expense.date, format: .dateTime.day().month().year())
                        .font(.appCaption)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }

            Spacer(minLength: AppSpacing.sm)

            VStack(alignment: .trailing, spacing: 4) {
                Text(expense.amount, format: .currency(code: "EUR"))
                    .font(.headline.weight(.semibold))
                    .monospacedDigit()

                if !expense.note.isEmpty {
                    Text(expense.date, format: .dateTime.day().month().year())
                        .font(.appCaption)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        let amount = expense.amount.formatted(.currency(code: "EUR"))
        let date = expense.date.formatted(date: .long, time: .omitted)

        if expense.note.isEmpty {
            return "\(categoryName), \(amount), \(date)"
        } else {
            return "\(categoryName), \(amount), \(expense.note), \(date)"
        }
    }
}

#Preview {
    ExpenseRowView(
        expense: Expense(
            amount: 20,
            category: nil,
            note: "",
            date: .now
        )
    )
    .padding()
    .background(AppColors.screenBackground)
}
