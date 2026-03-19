import SwiftUI
import SwiftData

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

    private let quickAmounts: [Double] = [5, 10, 20, 50]

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

                saveBar
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                restoreSelectedCategory()
                isAmountFieldFocused = true
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
                ForEach(categories) { category in
                    Button {
                        selectedCategoryID = category.id
                        isAmountFieldFocused = false
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: category.systemImage)
                                .font(.body.weight(.semibold))

                            Text(category.name)
                                .font(.body.weight(.semibold))
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedCategoryID == category.id
                                ? category.color
                                : Color(.secondarySystemBackground)
                        )
                        .foregroundStyle(
                            selectedCategoryID == category.id
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
                                selectedCategoryID == category.id
                                    ? category.color
                                    : Color(.separator).opacity(0.25),
                                lineWidth: 1
                            )
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

    private var saveBar: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                saveExpense()
            } label: {
                HStack {
                    Text("Save Expense")
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
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 10)
        }
        .background(.regularMaterial)
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
        let currentAmount = parsedAmount ?? 0
        let newAmount = currentAmount == 0 ? value : currentAmount + value
        amountText = formattedAmountString(for: newAmount)
    }

    private func formattedAmountString(for value: Double) -> String {
        if value == floor(value) {
            return String(Int(value))
        } else {
            return String(format: "%.2f", value)
        }
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
