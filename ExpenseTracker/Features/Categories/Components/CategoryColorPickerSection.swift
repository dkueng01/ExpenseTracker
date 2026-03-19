import SwiftUI

struct CategoryColorPickerSection: View {
    @Binding var selectedColorName: String

    var body: some View {
        AppFormSection(title: "Color") {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 60), spacing: AppSpacing.sm),
                ],
                spacing: AppSpacing.sm
            ) {
                ForEach(CategoryColorOption.allCases) { option in
                    Button {
                        selectedColorName = option.rawValue
                    } label: {
                        colorTile(for: option)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.contentPadding)
            .appPanelStyle()
        }
    }

    private func colorTile(for option: CategoryColorOption) -> some View {
        let isSelected = selectedColorName == option.rawValue

        return ZStack {
            Circle()
                .fill(option.color)
                .frame(width: 34, height: 34)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 52)
        .background(AppColors.inputBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppRadius.md,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: AppRadius.md,
                style: .continuous
            )
            .stroke(
                isSelected ? option.color : AppColors.controlBorder,
                lineWidth: 1
            )
        }
    }
}
