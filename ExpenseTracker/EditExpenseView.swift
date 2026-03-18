import SwiftUI
import SwiftData

struct EditExpenseView: View {
    let expense: Expense

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var amountText: String
    @State private var selectedCategory: ExpenseCategory
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
        _selectedCategory = State(
            initialValue: ExpenseCategory.from(expense.category)
        )
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

    private var canSave: Bool {
        guard let parsedAmount else { return false }
        return parsedAmount > 0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        amountSection
                        categorySection
                        detailsSection
                    }
                    .padding(20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isAmountFieldFocused = false
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .background(Color(.systemGroupedBackground))

                bottomBar
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
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
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount")
                .font(.headline)

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("€")
                        .font(
                            .system(
                                size: 30,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.secondary)

                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(
                            .system(
                                size: 42,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .focused($isAmountFieldFocused)
                        .accessibilityLabel("Amount")
                }

                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 72), spacing: 12),
                    ],
                    spacing: 12
                ) {
                    ForEach(quickAmounts, id: \.self) { value in
                        Button {
                            addQuickAmount(value)
                        } label: {
                            Text(value, format: .currency(code: "EUR"))
                                .font(.body.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.10))
                                .foregroundStyle(.blue)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 12,
                                        style: .continuous
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(18)
            .background(Color(.secondarySystemBackground))
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ],
                spacing: 12
            ) {
                ForEach(ExpenseCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                        isAmountFieldFocused = false
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: category.systemImage)
                                .font(.body.weight(.semibold))

                            Text(category.rawValue)
                                .font(.body.weight(.semibold))
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedCategory == category
                                ? category.color
                                : Color(.secondarySystemBackground)
                        )
                        .foregroundStyle(
                            selectedCategory == category
                                ? .white
                                : .primary
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 14,
                                style: .continuous
                            )
                        )
                        .overlay {
                            RoundedRectangle(
                                cornerRadius: 14,
                                style: .continuous
                            )
                            .stroke(
                                selectedCategory == category
                                    ? category.color
                                    : Color(.separator).opacity(0.25),
                                lineWidth: 1
                            )
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(category.rawValue)
                    .accessibilityAddTraits(
                        selectedCategory == category ? [.isSelected] : []
                    )
                }
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.snappy) {
                    isShowingMoreOptions.toggle()
                }
            } label: {
                HStack {
                    Text("More options")
                        .font(.headline)

                    Spacer()

                    Image(
                        systemName: isShowingMoreOptions
                            ? "chevron.up"
                            : "chevron.down"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                }
                .padding(18)
                .background(Color(.secondarySystemBackground))
                .clipShape(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            }
            .buttonStyle(.plain)

            if isShowingMoreOptions {
                VStack(spacing: 16) {
                    TextField("Note (optional)", text: $note)
                        .textInputAutocapitalization(.sentences)
                        .padding(14)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                        )

                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                }
                .padding(18)
                .background(Color(.secondarySystemBackground))
                .clipShape(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            Divider()

            Button {
                saveChanges()
            } label: {
                HStack {
                    Text("Save Changes")
                        .font(.headline)

                    Spacer()

                    if let parsedAmount {
                        Text(parsedAmount, format: .currency(code: "EUR"))
                            .font(.headline)
                            .monospacedDigit()
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(canSave ? Color.blue : Color.gray.opacity(0.4))
                .clipShape(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
            }
            .disabled(!canSave)

            Button(role: .destructive) {
                isShowingDeleteConfirmation = true
            } label: {
                Text("Delete Expense")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .background(.regularMaterial)
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

        expense.amount = parsedAmount
        expense.category = selectedCategory.rawValue
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
            category: "Food",
            note: "Lunch",
            date: .now
        )
    )
    .modelContainer(for: Expense.self, inMemory: true)
}
