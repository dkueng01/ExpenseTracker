import SwiftUI

struct ExpenseCategoryPickerSection: View {
    let categories: [ExpenseCategory]

    @Binding var selectedCategoryID: UUID?

    var onCategorySelected: (() -> Void)? = nil

    var body: some View {
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
                        onCategorySelected?()
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
}
