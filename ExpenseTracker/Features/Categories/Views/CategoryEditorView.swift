import SwiftData
import SwiftUI

struct CategoryEditorView: View {
    private let category: ExpenseCategory?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ExpenseCategory.sortOrder) private var categories:
        [ExpenseCategory]

    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColorName: String
    @State private var isShowingDeleteConfirmation = false

    @FocusState private var isNameFieldFocused: Bool

    init(category: ExpenseCategory? = nil) {
        self.category = category
        _name = State(initialValue: category?.name ?? "")
        _selectedIcon = State(
            initialValue: category?.systemImage ?? CategorySupport.defaultIcon
        )
        _selectedColorName = State(
            initialValue: category?.colorName
                ?? CategorySupport.defaultColorName
        )
    }
    
    private var fallbackCategory: ExpenseCategory? {
        CategorySupport.fallbackCategory(in: categories)
    }

    private var canDeleteCategory: Bool {
        guard let category else { return false }

        return CategorySupport.canDelete(
            category: category,
            fallbackCategory: fallbackCategory
        )
    }

    private var deleteMessage: String {
        CategorySupport.deleteMessage(
            for: category,
            fallbackCategory: fallbackCategory
        )
    }

    private var isEditing: Bool {
        category != nil
    }

    private var trimmedName: String {
        CategorySupport.trimmedName(name)
    }

    private var isDuplicateName: Bool {
        CategorySupport.isDuplicateName(
            name,
            currentCategoryID: category?.id,
            in: categories
        )
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && !isDuplicateName
    }

    private var selectedColor: Color {
        CategorySupport.selectedColor(for: selectedColorName)
    }

    private var saveButtonTitle: String {
        isEditing ? "Save Changes" : "Save Category"
    }

    private var sheetTitle: String {
        isEditing ? "Edit Category" : "New Category"
    }

    private var cancelTitle: String {
        isEditing ? "Close" : "Cancel"
    }

    var body: some View {
        AppSheetScaffold(
            title: sheetTitle,
            cancelTitle: cancelTitle,
            onCancel: { dismiss() }
        ) {
            CategoryPreviewSection(
                name: name,
                selectedIcon: selectedIcon,
                selectedColor: selectedColor
            )

            CategoryNameSection(
                name: $name,
                isDuplicateName: isDuplicateName,
                nameFieldFocus: $isNameFieldFocused
            )

            CategoryIconPickerSection(
                selectedIcon: $selectedIcon,
                selectedColor: selectedColor
            )

            CategoryColorPickerSection(
                selectedColorName: $selectedColorName
            )

            if category?.isFallback == true {
                fallbackInfoSection
            }
        } footer: {
            VStack(spacing: AppSpacing.sm) {
                AppPrimaryButton(
                    title: saveButtonTitle,
                    isEnabled: canSave
                ) {
                    saveCategory()
                }

                if isEditing && canDeleteCategory {
                    AppDestructiveButton(title: "Delete Category") {
                        isShowingDeleteConfirmation = true
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                isNameFieldFocused = true
            }
        }.alert("Delete category?", isPresented: $isShowingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteCategory()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text(deleteMessage)
        }
    }

    private var fallbackInfoSection: some View {
        AppFormSection(title: "Info") {
            Text(
                "This is the fallback category. It cannot be deleted because "
                    + "the app uses it when other categories are removed."
            )
            .font(.subheadline)
            .foregroundStyle(AppColors.secondaryText)
            .padding(AppSpacing.contentPadding)
            .appPanelStyle()
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
    
    private func deleteCategory() {
        guard let category else { return }
        guard let fallbackCategory else { return }

        CategorySupport.deleteCategory(
            category,
            fallbackCategory: fallbackCategory,
            in: modelContext
        )

        dismiss()
    }
}
