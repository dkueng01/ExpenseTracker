import SwiftUI

struct InsightsRangePicker: View {
    @Binding var selectedRange: InsightsTimeRange

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(InsightsTimeRange.allCases) { range in
                    Button {
                        selectedRange = range
                    } label: {
                        Text(range.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(
                                selectedRange == range
                                    ? Color.white
                                    : AppColors.primaryText
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                selectedRange == range
                                    ? AppColors.primaryTint
                                    : AppColors.cardBackground
                            )
                            .clipShape(Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(
                                        selectedRange == range
                                            ? AppColors.primaryTint
                                            : AppColors.controlBorder,
                                        lineWidth: 1
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.pageHorizontal)
        }
    }
}

#Preview {
    InsightsRangePicker(selectedRange: .constant(.year))
        .padding(.vertical)
        .background(AppColors.screenBackground)
}
