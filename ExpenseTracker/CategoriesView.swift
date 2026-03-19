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
            ZStack(alignment: .bottomTrailing) {
                List {
                    Section {
                        categoriesCard
                            .listRowInsets(
                                EdgeInsets(
                                    top: 4,
                                    leading: 20,
                                    bottom: 8,
                                    trailing: 20
                                )
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)

                        footerText
                            .listRowInsets(
                                EdgeInsets(
                                    top: 0,
                                    leading: 20,
                                    bottom: 12,
                                    trailing: 20
                                )
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Categories")
                .navigationBarTitleDisplayMode(.large)
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

                addButton
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var categoriesCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(categories.enumerated()), id: \.element.id) {
                index,
                category in
                row(
                    for: category,
                    showsDivider: index < categories.count - 1
                )
            }
        }
        .background(Color(.systemBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.separator).opacity(0.10), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
    }

    private var footerText: some View {
        Text(
            "The fallback category cannot be deleted. Expenses from "
                + "deleted categories are moved there."
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
    }

    private func row(
        for category: ExpenseCategory,
        showsDivider: Bool
    ) -> some View {
        VStack(spacing: 0) {
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
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
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

            if showsDivider {
                Divider()
                    .padding(.horizontal, 14)
            }
        }
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

    private var addButton: some View {
        Button {
            isShowingAddCategory = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: .blue.opacity(0.25), radius: 10, y: 6)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .accessibilityLabel("Add category")
        .accessibilityHint("Opens the form to create a new category")
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
