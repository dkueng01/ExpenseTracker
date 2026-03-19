import SwiftUI

struct CategoryPreviewSection: View {
    let name: String
    let selectedIcon: String
    let selectedColor: Color

    private var displayName: String {
        let trimmed = CategorySupport.trimmedName(name)
        return trimmed.isEmpty ? "Category name" : trimmed
    }

    var body: some View {
        AppFormSection(title: "Preview") {
            HStack(spacing: AppSpacing.md) {
                AppIconBadge(
                    systemImage: selectedIcon,
                    color: selectedColor,
                    size: 52,
                    style: .circle
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.appCardTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Text("How this category will appear")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer()
            }
            .padding(AppSpacing.contentPadding)
            .appPanelStyle()
        }
    }
}
