import SwiftData
import SwiftUI

struct ExpenseEditorView: View {
    enum Mode {
        case create
        case edit(Expense)

        var title: String {
            switch self {
            case .create:
                return "New Expense"
            case .edit:
                return "Edit Expense"
            }
        }

        var cancelTitle: String {
            switch self {
            case .create:
                return "Cancel"
            case .edit:
                return "Close"
            }
        }

        var saveButtonTitle: String {
            switch self {
            case .create:
                return "Save Expense"
            case .edit:
                return "Save Changes"
            }
        }

        var expense: Expense? {
            switch self {
            case .create:
                return nil
            case .edit(let expense):
                return expense
            }
        }

        var isEditing: Bool {
            expense != nil
        }
    }

    let mode: Mode

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ExpenseCategory.sortOrder) private var categories:
        [ExpenseCategory]

    @AppStorage("lastUsedCategoryID") private var lastUsedCategoryID = ""

    @State private var amountText: String
    @State private var selectedCategoryID: UUID?
    @State private var note: String
    @State private var date: Date
    @State private var isShowingMoreOptions: Bool
    @State private var isShowingDeleteConfirmation = false

    @FocusState private var isAmountFieldFocused: Bool

    init(mode: Mode) {
        self.mode = mode

        if let expense = mode.expense {
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
        } else {
            _amountText = State(initialValue: "")
            _selectedCategoryID = State(initialValue: nil)
            _note = State(initialValue: "")
            _date = State(initialValue: Date())
            _isShowingMoreOptions = State(initialValue: false)
        }
    }

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
            title: mode.title,
            cancelTitle: mode.cancelTitle,
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
            footerContent
        }
        .onAppear {
            configureInitialState()

            DispatchQueue.main.async {
                isAmountFieldFocused = true
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

    @ViewBuilder
    private var footerContent: some View {
        if mode.isEditing {
            VStack(spacing: AppSpacing.sm) {
                AppPrimaryButton(
                    title: mode.saveButtonTitle,
                    trailingText: saveAmountText,
                    isEnabled: canSave
                ) {
                    save()
                }

                AppDestructiveButton(title: "Delete Expense") {
                    isShowingDeleteConfirmation = true
                }
            }
        } else {
            AppPrimaryButton(
                title: mode.saveButtonTitle,
                trailingText: saveAmountText,
                isEnabled: canSave
            ) {
                save()
            }
        }
    }

    private func configureInitialState() {
        switch mode {
        case .create:
            restoreSelectedCategory()

        case .edit:
            if selectedCategoryID == nil {
                selectedCategoryID = fallbackCategory?.id
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

    private func save() {
        guard let parsedAmount else { return }
        guard let selectedCategory else { return }

        switch mode {
        case .create:
            let expense = Expense(
                amount: parsedAmount,
                category: selectedCategory,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                date: date
            )

            modelContext.insert(expense)
            lastUsedCategoryID = selectedCategory.id.uuidString

        case .edit(let expense):
            expense.amount = parsedAmount
            expense.category = selectedCategory
            expense.note = note.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            expense.date = date
        }

        dismiss()
    }

    private func deleteExpense() {
        guard case .edit(let expense) = mode else { return }
        modelContext.delete(expense)
        dismiss()
    }
}

#Preview("Create") {
    ExpenseEditorView(mode: .create)
        .modelContainer(
            for: [Expense.self, ExpenseCategory.self],
            inMemory: true
        )
}

#Preview("Edit") {
    ExpenseEditorView(
        mode: .edit(
            Expense(
                amount: 18.50,
                category: nil,
                note: "Lunch",
                date: .now
            )
        )
    )
    .modelContainer(
        for: [Expense.self, ExpenseCategory.self],
        inMemory: true
    )
}
