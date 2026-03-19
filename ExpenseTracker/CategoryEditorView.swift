import SwiftUI
import SwiftData

struct CategoryEditorView: View {
    private let category: ExpenseCategory?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ExpenseCategory.sortOrder) private var categories:
        [ExpenseCategory]

    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColorName: String

    @FocusState private var isNameFieldFocused: Bool

    init(category: ExpenseCategory? = nil) {
        self.category = category
        _name = State(initialValue: category?.name ?? "")
        _selectedIcon = State(
            initialValue: category?.systemImage ?? CategoryIconOption.tag.rawValue
        )
        _selectedColorName = State(
            initialValue: category?.colorName ?? CategoryColorOption.blue.rawValue
        )
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isDuplicateName: Bool {
        categories.contains { existingCategory in
            existingCategory.id != category?.id
                && existingCategory.name
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .localizedCaseInsensitiveCompare(trimmedName)
                    == .orderedSame
        }
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && !isDuplicateName
    }

    private var selectedColor: Color {
        CategoryColorOption(rawValue: selectedColorName)?.color ?? .blue
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Preview") {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(selectedColor.opacity(0.14))
                                .frame(width: 44, height: 44)

                            Image(systemName: selectedIcon)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(selectedColor)
                        }

                        Text(trimmedName.isEmpty ? "Category name" : trimmedName)
                            .font(.headline)
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    TextField("Category name", text: $name)
                        .focused($isNameFieldFocused)
                } header: {
                    Text("Name")
                } footer: {
                    if isDuplicateName {
                        Text("A category with this name already exists.")
                    }
                }

                Section("Icon") {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 52), spacing: 12),
                        ],
                        spacing: 12
                    ) {
                        ForEach(CategoryIconOption.allCases) { icon in
                            Button {
                                selectedIcon = icon.rawValue
                            } label: {
                                Image(systemName: icon.rawValue)
                                    .font(.title3)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .padding(.vertical, 6)
                                    .background(
                                        selectedIcon == icon.rawValue
                                            ? selectedColor.opacity(0.14)
                                            : Color(.secondarySystemBackground)
                                    )
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 12,
                                            style: .continuous
                                        )
                                    )
                                    .overlay {
                                        RoundedRectangle(
                                            cornerRadius: 12,
                                            style: .continuous
                                        )
                                        .stroke(
                                            selectedIcon == icon.rawValue
                                                ? selectedColor
                                                : Color(.separator)
                                                    .opacity(0.2),
                                            lineWidth: 1
                                        )
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Color") {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 52), spacing: 12),
                        ],
                        spacing: 12
                    ) {
                        ForEach(CategoryColorOption.allCases) { option in
                            Button {
                                selectedColorName = option.rawValue
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(option.color)
                                        .frame(width: 34, height: 34)

                                    if selectedColorName == option.rawValue {
                                        Image(systemName: "checkmark")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .padding(.vertical, 6)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 12,
                                        style: .continuous
                                    )
                                )
                                .overlay {
                                    RoundedRectangle(
                                        cornerRadius: 12,
                                        style: .continuous
                                    )
                                    .stroke(
                                        selectedColorName == option.rawValue
                                            ? option.color
                                            : Color(.separator).opacity(0.2),
                                        lineWidth: 1
                                    )
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                if category?.isFallback == true {
                    Section {
                        Text(
                            "This is the fallback category. It cannot be "
                                + "deleted because the app uses it when other "
                                + "categories are removed."
                        )
                    }
                }
            }
            .navigationTitle(category == nil ? "New Category" : "Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                isNameFieldFocused = true
            }
        }
    }

    private func saveCategory() {
        guard canSave else { return }

        if let category {
            category.name = trimmedName
            category.systemImage = selectedIcon
            category.colorName = selectedColorName
        } else {
            let nextSortOrder = (categories.map(\.sortOrder).max() ?? -1) + 1

            let newCategory = ExpenseCategory(
                name: trimmedName,
                systemImage: selectedIcon,
                colorName: selectedColorName,
                sortOrder: nextSortOrder
            )

            modelContext.insert(newCategory)
        }

        dismiss()
    }
}

#Preview {
    CategoryEditorView()
        .modelContainer(
            for: [Expense.self, ExpenseCategory.self],
            inMemory: true
        )
}
