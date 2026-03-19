import SwiftUI

struct ExpenseDetailsSection: View {
    @Binding var note: String
    @Binding var date: Date
    @Binding var isShowingMoreOptions: Bool

    var onToggle: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Button {
                onToggle?()

                withAnimation(.snappy) {
                    isShowingMoreOptions.toggle()
                }
            } label: {
                HStack {
                    Text("More options")
                        .font(.appSectionTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Spacer()

                    Image(
                        systemName: isShowingMoreOptions
                            ? "chevron.up"
                            : "chevron.down"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.secondaryText)
                }
                .padding(AppSpacing.contentPadding)
                .appPanelStyle()
            }
            .buttonStyle(.plain)

            if isShowingMoreOptions {
                VStack(spacing: AppSpacing.lg) {
                    TextField("Note (optional)", text: $note)
                        .textInputAutocapitalization(.sentences)
                        .appInputFieldStyle()

                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                }
                .padding(AppSpacing.contentPadding)
                .appPanelStyle()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
