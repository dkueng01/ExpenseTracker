import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense

    private var category: ExpenseCategory {
        ExpenseCategory.from(expense.category)
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.14))
                    .frame(width: 44, height: 44)

                Image(systemName: category.systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(category.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category)
                    .font(.headline)

                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text(expense.date, format: .dateTime.day().month().year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 4) {
                Text(expense.amount, format: .currency(code: "EUR"))
                    .font(.headline.weight(.semibold))
                    .monospacedDigit()

                if !expense.note.isEmpty {
                    Text(expense.date, format: .dateTime.day().month().year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(.separator).opacity(0.12), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        let amount = expense.amount.formatted(.currency(code: "EUR"))
        let date = expense.date.formatted(date: .long, time: .omitted)

        if expense.note.isEmpty {
            return "\(expense.category), \(amount), \(date)"
        } else {
            return "\(expense.category), \(amount), \(expense.note), \(date)"
        }
    }
}

#Preview {
    ExpenseRowView(
        expense: Expense(
            amount: 20,
            category: "Food",
            note: "",
            date: .now
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
