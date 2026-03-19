import SwiftData
import SwiftUI

struct EditExpenseView: View {
    let expense: Expense

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ExpenseCategory.sortOrder) private var categories:
        [ExpenseCategory]

    @State private var amountText: String
    @State private var selectedCategoryID: UUID?
    @State private var note: String
    @State private var date: Date
    @State private var isShowingMoreOptions: Bool
    @State private var isShowingDeleteConfirmation = false

    @FocusState private var isAmountFieldFocused: Bool

    init(expense: Expense) {
        self.expense = expense
        _amountText = State(
            initialValue: ExpenseFormSupport.formattedAmountString(
                for: expense.amount
            )
        )
        _selectedCategoryID = State(initialValue: expense.category?.id)
        _note = State(initialValue: expense.note)
        _date = State(initialValue: expense.date)
        _isShowingMoreOptions = State(
            initialValue: !expense.note.isEmpty
                || !Calendar.current.isDateInToday(expense.date)
        )
    }

    private var parsedAmount: Double? {
        ExpenseFormSupport.parseAmount(from: amountText)
    }

    private var selectedCategory: ExpenseCategory? {
        ExpenseFormSupport.selectedCategory(
            for: selectedCategoryID,
            in: categories
        )
    }

    private var fallbackCategory: ExpenseCategory? {
        ExpenseFormSupport.fallbackCategory(in: categories)
    }

    private var canSave: Bool {
        guard let parsedAmount else { return false }
        return parsedAmount > 0 && selectedCategory != nil
    }

    private var saveAmountText: String? {
        parsedAmount?.formatted(.currency(code: "EUR"))
    }

    var body: some View {
        AppSheetScaffold(
            title: "Edit Expense",
            cancelTitle: "Close",
            onCancel: { dismiss() }
        ) {
            ExpenseAmountSection(
                amountText: $amountText,
                quickAmounts: ExpenseFormSupport.quickAmounts,
                amountFieldFocus: $isAmountFieldFocused,
                onQuickAmountTap: addQuickAmount
            )

            ExpenseCategoryPickerSection(
                categories: categories,
                selectedCategoryID: $selectedCategoryID
            ) {
                isAmountFieldFocused = false
            }

            ExpenseDetailsSection(
                note: $note,
                date: $date,
                isShowingMoreOptions: $isShowingMoreOptions
            ) {
                isAmountFieldFocused = false
            }
        } footer: {
            VStack(spacing: AppSpacing.sm) {
                AppPrimaryButton(
                    title: "Save Changes",
                    trailingText: saveAmountText,
                    isEnabled: canSave
                ) {
                    saveChanges()
                }

                AppDestructiveButton(title: "Delete Expense") {
                    isShowingDeleteConfirmation = true
                }
            }
        }
        .onAppear {
            if selectedCategoryID == nil {
                selectedCategoryID = fallbackCategory?.id
            }
        }
        .alert("Delete expense?", isPresented: $isShowingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteExpense()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func addQuickAmount(_ value: Double) {
        amountText = ExpenseFormSupport.addingQuickAmount(
            value,
            to: amountText
        )
    }

    private func saveChanges() {
        guard let parsedAmount else { return }
        guard let selectedCategory else { return }

        expense.amount = parsedAmount
        expense.category = selectedCategory
        expense.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        expense.date = date

        dismiss()
    }

    private func deleteExpense() {
        modelContext.delete(expense)
        dismiss()
    }
}

#Preview {
    EditExpenseView(
        expense: Expense(
            amount: 18.50,
            category: nil,
            note: "Lunch",
            date: .now
        )
    )
    .modelContainer(
        for: [Expense.self, ExpenseCategory.self],
        inMemory: true
    )
}
