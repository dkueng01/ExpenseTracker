import SwiftData
import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ExpenseCategory.sortOrder) private var categories:
        [ExpenseCategory]

    @AppStorage("lastUsedCategoryID") private var lastUsedCategoryID = ""

    @State private var amountText = ""
    @State private var selectedCategoryID: UUID?
    @State private var note = ""
    @State private var date = Date()
    @State private var isShowingMoreOptions = false

    @FocusState private var isAmountFieldFocused: Bool

    private var parsedAmount: Double? {
        ExpenseFormSupport.parseAmount(from: amountText)
    }

    private var fallbackCategory: ExpenseCategory? {
        ExpenseFormSupport.fallbackCategory(in: categories)
    }

    private var selectedCategory: ExpenseCategory? {
        ExpenseFormSupport.selectedCategory(
            for: selectedCategoryID,
            in: categories
        )
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
            title: "New Expense",
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
            AppPrimaryButton(
                title: "Save Expense",
                trailingText: saveAmountText,
                isEnabled: canSave
            ) {
                saveExpense()
            }
        }
        .onAppear {
            restoreSelectedCategory()

            DispatchQueue.main.async {
                isAmountFieldFocused = true
            }
        }
    }

    private func restoreSelectedCategory() {
        if let storedID = UUID(uuidString: lastUsedCategoryID),
            categories.contains(where: { $0.id == storedID })
        {
            selectedCategoryID = storedID
        } else {
            selectedCategoryID = fallbackCategory?.id
        }
    }

    private func addQuickAmount(_ value: Double) {
        amountText = ExpenseFormSupport.addingQuickAmount(
            value,
            to: amountText
        )
    }

    private func saveExpense() {
        guard let parsedAmount else { return }
        guard let selectedCategory else { return }

        let expense = Expense(
            amount: parsedAmount,
            category: selectedCategory,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date
        )

        modelContext.insert(expense)
        lastUsedCategoryID = selectedCategory.id.uuidString
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(
            for: [Expense.self, ExpenseCategory.self],
            inMemory: true
        )
}
