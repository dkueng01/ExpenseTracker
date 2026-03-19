import SwiftUI

struct CategoryRowView: View {
    let category: ExpenseCategory
    var showsDivider = false

    var body: some View {
        VStack(spacing: 0) {
            rowContent

            if showsDivider {
                Divider()
                    .padding(.horizontal, AppSpacing.md)
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: AppSpacing.md) {
            AppIconBadge(
                systemImage: category.systemImage,
                color: category.color,
                size: 44,
                style: .circle
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.appCardTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text(CategorySupport.usageSubtitle(for: category))
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            if category.isFallback {
                Text("Fallback")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.elevatedBackground)
                    .clipShape(Capsule())
            }
        }
        .padding(AppSpacing.md)
    }
}

#Preview {
    let category = ExpenseCategory(
        name: "Food",
        systemImage: "fork.knife",
        colorName: "orange",
        sortOrder: 0
    )

    CategoryRowView(category: category, showsDivider: true)
        .padding()
        .background(AppColors.screenBackground)
}
