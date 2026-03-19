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
            initialValue: category?.systemImage
                ?? CategoryIconOption.tag.rawValue
        )
        _selectedColorName = State(
            initialValue: category?.colorName
                ?? CategoryColorOption.blue.rawValue
        )
    }

    private var isEditing: Bool {
        category != nil
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
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        previewSection
                        nameSection
                        iconSection
                        colorSection

                        if category?.isFallback == true {
                            fallbackInfoSection
                        }
                    }
                    .padding(20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isNameFieldFocused = false
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .background(Color(.systemGroupedBackground))

                saveBar
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "Edit Category" : "New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isEditing ? "Close" : "Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isNameFieldFocused = true
            }
        }
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(selectedColor.opacity(0.14))
                        .frame(width: 52, height: 52)

                    Image(systemName: selectedIcon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(selectedColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(trimmedName.isEmpty ? "Category name" : trimmedName)
                        .font(.headline)

                    Text("How this category will appear")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(18)
            .background(Color(.secondarySystemBackground))
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Name")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                TextField("Category name", text: $name)
                    .focused($isNameFieldFocused)
                    .textInputAutocapitalization(.words)
                    .padding(14)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                    )

                if isDuplicateName {
                    Text("A category with this name already exists.")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding(18)
            .background(Color(.secondarySystemBackground))
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icon")
                .font(.headline)

            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 60), spacing: 12),
                ],
                spacing: 12
            ) {
                ForEach(CategoryIconOption.allCases) { icon in
                    Button {
                        selectedIcon = icon.rawValue
                    } label: {
                        Image(systemName: icon.rawValue)
                            .font(.title3)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(
                                selectedIcon == icon.rawValue
                                    ? selectedColor.opacity(0.14)
                                    : Color(.tertiarySystemBackground)
                            )
                            .foregroundStyle(
                                selectedIcon == icon.rawValue
                                    ? selectedColor
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
                                    selectedIcon == icon.rawValue
                                        ? selectedColor
                                        : Color(.separator).opacity(0.25),
                                    lineWidth: 1
                                )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(18)
            .background(Color(.secondarySystemBackground))
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color")
                .font(.headline)

            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 60), spacing: 12),
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
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Color(.tertiarySystemBackground))
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
                                selectedColorName == option.rawValue
                                    ? option.color
                                    : Color(.separator).opacity(0.25),
                                lineWidth: 1
                            )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(18)
            .background(Color(.secondarySystemBackground))
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
        }
    }

    private var fallbackInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Info")
                .font(.headline)

            Text(
                "This is the fallback category. It cannot be deleted because "
                    + "the app uses it when other categories are removed."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(18)
            .background(Color(.secondarySystemBackground))
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
        }
    }

    private var saveBar: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                saveCategory()
            } label: {
                Text(isEditing ? "Save Changes" : "Save Category")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(canSave ? Color.blue : Color.gray.opacity(0.4))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                    )
            }
            .disabled(!canSave)
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 10)
        }
        .background(.regularMaterial)
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
