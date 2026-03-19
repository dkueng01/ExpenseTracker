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

    private let quickAmounts: [Double] = [5, 10, 20, 50]

    init(expense: Expense) {
        self.expense = expense
        _amountText = State(
            initialValue: Self.formattedAmountString(for: expense.amount)
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
        let cleanedAmount = amountText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        return Double(cleanedAmount)
    }

    private var fallbackCategory: ExpenseCategory? {
        categories.first(where: { $0.isFallback }) ?? categories.first
    }

    private var selectedCategory: ExpenseCategory? {
        if let selectedCategoryID {
            return categories.first(where: { $0.id == selectedCategoryID })
                ?? fallbackCategory
        }

        return fallbackCategory
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
            amountSection
            categorySection
            detailsSection
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

    private var amountSection: some View {
        AppFormSection(title: "Amount") {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                HStack(
                    alignment: .firstTextBaseline,
                    spacing: AppSpacing.xs
                ) {
                    Text("€")
                        .font(.appAmountSymbol)
                        .foregroundStyle(AppColors.secondaryText)

                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(.appAmountValue)
                        .focused($isAmountFieldFocused)
                        .accessibilityLabel("Amount")
                }

                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 72), spacing: AppSpacing.sm),
                    ],
                    spacing: AppSpacing.sm
                ) {
                    ForEach(quickAmounts, id: \.self) { value in
                        quickAmountButton(for: value)
                    }
                }
            }
            .padding(AppSpacing.contentPadding)
            .appPanelStyle()
        }
    }

    private var categorySection: some View {
        AppFormSection(title: "Category") {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppSpacing.sm),
                    GridItem(.flexible(), spacing: AppSpacing.sm),
                ],
                spacing: AppSpacing.sm
            ) {
                ForEach(categories) { category in
                    Button {
                        selectedCategoryID = category.id
                        isAmountFieldFocused = false
                    } label: {
                        AppSelectableTile(
                            isSelected: selectedCategoryID == category.id,
                            tint: category.color
                        ) {
                            HStack(spacing: 10) {
                                Image(systemName: category.systemImage)

                                Text(category.name)
                                    .lineLimit(1)

                                Spacer()
                            }
                            .font(.appBodyStrong)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(category.name)
                    .accessibilityAddTraits(
                        selectedCategoryID == category.id ? [.isSelected] : []
                    )
                }
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Button {
                isAmountFieldFocused = false

                withAnimation(.snappy) {
                    isShowingMoreOptions.toggle()
                }
            } label: {
                HStack {
                    Text("More options")
                        .font(.appSectionTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Spacer()

                    Image(
                        systemName: isShowingMoreOptions
                            ? "chevron.up"
                            : "chevron.down"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.secondaryText)
                }
                .padding(AppSpacing.contentPadding)
                .appPanelStyle()
            }
            .buttonStyle(.plain)

            if isShowingMoreOptions {
                VStack(spacing: AppSpacing.lg) {
                    TextField("Note (optional)", text: $note)
                        .textInputAutocapitalization(.sentences)
                        .appInputFieldStyle()

                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                }
                .padding(AppSpacing.contentPadding)
                .appPanelStyle()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private func quickAmountButton(for value: Double) -> some View {
        Button {
            addQuickAmount(value)
        } label: {
            Text(value, format: .currency(code: "EUR"))
                .font(.appBodyStrong)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColors.primaryTint.opacity(0.10))
                .foregroundStyle(AppColors.primaryTint)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppRadius.sm,
                        style: .continuous
                    )
                )
        }
        .buttonStyle(.plain)
    }

    private func addQuickAmount(_ value: Double) {
        let currentAmount = parsedAmount ?? 0
        let newAmount = currentAmount == 0 ? value : currentAmount + value
        amountText = Self.formattedAmountString(for: newAmount)
    }

    private static func formattedAmountString(for value: Double) -> String {
        if value == floor(value) {
            return String(Int(value))
        } else {
            return String(format: "%.2f", value)
        }
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
