import SwiftUI

struct CategoryIconPickerSection: View {
    @Binding var selectedIcon: String
    let selectedColor: Color

    var body: some View {
        AppFormSection(title: "Icon") {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 60), spacing: AppSpacing.sm),
                ],
                spacing: AppSpacing.sm
            ) {
                ForEach(CategoryIconOption.allCases) { icon in
                    Button {
                        selectedIcon = icon.rawValue
                    } label: {
                        AppSelectableTile(
                            isSelected: selectedIcon == icon.rawValue,
                            tint: selectedColor
                        ) {
                            Image(systemName: icon.rawValue)
                                .font(.title3)
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(icon.rawValue)
                }
            }
            .padding(AppSpacing.contentPadding)
            .appPanelStyle()
        }
    }
}
