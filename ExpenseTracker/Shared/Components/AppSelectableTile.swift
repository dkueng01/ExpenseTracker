import SwiftUI

struct AppSelectableTile<Content: View>: View {
    let isSelected: Bool
    let tint: Color

    @ViewBuilder let content: Content

    init(
        isSelected: Bool,
        tint: Color = AppColors.primaryTint,
        @ViewBuilder content: () -> Content
    ) {
        self.isSelected = isSelected
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.md)
            .background(
                isSelected ? tint : AppColors.elevatedBackground
            )
            .foregroundStyle(
                isSelected ? Color.white : AppColors.primaryText
            )
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
                    isSelected ? tint : AppColors.controlBorder,
                    lineWidth: 1
                )
            }
    }
}

#Preview {
    VStack(spacing: 12) {
        AppSelectableTile(isSelected: true, tint: .orange) {
            HStack {
                Image(systemName: "fork.knife")
                Text("Food")
                Spacer()
            }
            .font(.body.weight(.semibold))
        }

        AppSelectableTile(isSelected: false) {
            HStack {
                Image(systemName: "car.fill")
                Text("Transport")
                Spacer()
            }
            .font(.body.weight(.semibold))
        }
    }
    .padding()
    .background(AppColors.screenBackground)
}
