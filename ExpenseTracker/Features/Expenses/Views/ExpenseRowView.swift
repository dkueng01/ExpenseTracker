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
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.14))
                    .frame(width: 44, height: 44)

                Image(systemName: categoryImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(categoryColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(categoryName)
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
        .background {
            if showsBackground {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.systemBackground))
            }
        }
        .overlay {
            if showsBackground {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(.separator).opacity(0.12), lineWidth: 1)
            }
        }
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
    .background(Color(.systemGroupedBackground))
}
