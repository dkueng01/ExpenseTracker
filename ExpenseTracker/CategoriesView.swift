import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ExpenseCategory.sortOrder) private var categories:
        [ExpenseCategory]

    @State private var isShowingAddCategory = false
    @State private var categoryToEdit: ExpenseCategory?
    @State private var categoryToDelete: ExpenseCategory?

    private var fallbackCategory: ExpenseCategory? {
        categories.first(where: { $0.isFallback }) ?? categories.first
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(categories) { category in
                        Button {
                            categoryToEdit = category
                        } label: {
                            row(for: category)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                categoryToEdit = category
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)

                            if !category.isFallback {
                                Button(role: .destructive) {
                                    categoryToDelete = category
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                } footer: {
                    Text(
                        "The fallback category cannot be deleted. "
                            + "Expenses from deleted categories are moved there."
                    )
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add category")
                }
            }
            .sheet(isPresented: $isShowingAddCategory) {
                CategoryEditorView()
                    .presentationDetents([.large])
            }
            .sheet(item: $categoryToEdit) { category in
                CategoryEditorView(category: category)
                    .presentationDetents([.large])
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
    }

    private func row(for category: ExpenseCategory) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.14))
                    .frame(width: 44, height: 44)

                Image(systemName: category.systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(category.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)

                Text(subtitle(for: category))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if category.isFallback {
                Text("Fallback")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }

    private func subtitle(for category: ExpenseCategory) -> String {
        let count = category.expenses.count

        if count == 1 {
            return "Used by 1 expense"
        } else {
            return "Used by \(count) expenses"
        }
    }

    private var deleteMessage: String {
        guard let categoryToDelete else { return "" }

        let expenseCount = categoryToDelete.expenses.count

        if expenseCount == 0 {
            return "This category will be removed."
        }

        let fallbackName = fallbackCategory?.name ?? "the fallback category"

        if expenseCount == 1 {
            return "This category will be removed and its 1 expense "
                + "will be moved to \(fallbackName)."
        } else {
            return "This category will be removed and its \(expenseCount) "
                + "expenses will be moved to \(fallbackName)."
        }
    }

    private func deleteSelectedCategory() {
        guard let category = categoryToDelete else { return }
        guard !category.isFallback else { return }
        guard let fallbackCategory else { return }
        guard fallbackCategory.id != category.id else { return }

        for expense in category.expenses {
            expense.category = fallbackCategory
        }

        modelContext.delete(category)
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
