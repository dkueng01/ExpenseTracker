import SwiftData
import SwiftUI

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ExpenseCategory.sortOrder) private var categories:
        [ExpenseCategory]

    @State private var isShowingAddCategory = false
    @State private var categoryToEdit: ExpenseCategory?
    @State private var categoryToDelete: ExpenseCategory?

    private var fallbackCategory: ExpenseCategory? {
        CategorySupport.fallbackCategory(in: categories)
    }

    private var deleteMessage: String {
        CategorySupport.deleteMessage(
            for: categoryToDelete,
            fallbackCategory: fallbackCategory
        )
    }

    var body: some View {
        AppScreen(title: "Categories") {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                categoriesCard
                footerText
            }
        } floatingAction: {
            AppFloatingActionButton(
                systemImage: "plus",
                accessibilityLabel: "Add category",
                accessibilityHint: "Opens the form to create a new category"
            ) {
                isShowingAddCategory = true
            }
        }
        .sheet(isPresented: $isShowingAddCategory) {
            CategoryEditorView()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(item: $categoryToEdit) { category in
            CategoryEditorView(category: category)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .alert(
            "Delete category?",
            isPresented: Binding(
                get: { categoryToDelete != nil },
                set: { isPresented in
                    if !isPresented {
                        categoryToDelete = nil
                    }
                }
            )
        ) {
            Button("Delete", role: .destructive) {
                deleteSelectedCategory()
            }

            Button("Cancel", role: .cancel) {
                categoryToDelete = nil
            }
        } message: {
            Text(deleteMessage)
        }
    }

    private var categoriesCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(categories.enumerated()), id: \.element.id) {
                index,
                category in
                CategoryRowView(
                    category: category,
                    showsDivider: index < categories.count - 1
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    categoryToEdit = category
                }
                .contextMenu {
                    Button {
                        categoryToEdit = category
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    if !category.isFallback {
                        Button(role: .destructive) {
                            categoryToDelete = category
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .appCardStyle()
    }

    private var footerText: some View {
        Text(
            "The fallback category cannot be deleted. Expenses from "
                + "deleted categories are moved there."
        )
        .font(.footnote)
        .foregroundStyle(AppColors.secondaryText)
    }

    private func deleteSelectedCategory() {
        guard let category = categoryToDelete else { return }
        guard let fallbackCategory else { return }

        CategorySupport.deleteCategory(
            category,
            fallbackCategory: fallbackCategory,
            in: modelContext
        )
        
        try? modelContext.save()
        AppWidgetReloader.reloadAll()
        categoryToDelete = nil
    }
}

#Preview {
    CategoriesView()
        .modelContainer(
            for: [Expense.self, ExpenseCategory.self],
            inMemory: true
        )
}
