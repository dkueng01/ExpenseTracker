import SwiftUI

struct AppSheetScaffold<Content: View, Footer: View>: View {
    let title: String
    let cancelTitle: String
    let onCancel: () -> Void

    @ViewBuilder let content: Content
    @ViewBuilder let footer: Footer

    init(
        title: String,
        cancelTitle: String = "Cancel",
        onCancel: @escaping () -> Void,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.title = title
        self.cancelTitle = cancelTitle
        self.onCancel = onCancel
        self.content = content()
        self.footer = footer()
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.sectionSpacing
                ) {
                    content
                }
                .padding(.horizontal, AppSpacing.pageHorizontal)
                .padding(.top, AppSpacing.xxxl)
                .padding(.bottom, AppSpacing.xxxl)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            AppBottomBar {
                footer
            }
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
    }

    private var header: some View {
        VStack(spacing: AppSpacing.md) {
            Capsule()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 48, height: 6)
                .padding(.top, AppSpacing.sm)

            HStack {
                Button(cancelTitle, action: onCancel)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(AppColors.primaryText)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(AppColors.cardBackground)
                    .clipShape(Capsule())

                Spacer()

                Text(title)
                    .font(.appSheetTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                Spacer()

                Color.clear
                    .frame(width: 96, height: 44)
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }
}

#Preview {
    AppSheetScaffold(
        title: "New Expense",
        onCancel: {}
    ) {
        AppFormSection(title: "Amount") {
            Text("€ 0.00")
                .font(.appAmountValue)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.elevatedBackground)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppRadius.card,
                        style: .continuous
                    )
                )
        }

        AppFormSection(title: "Category") {
            Text("Category tiles go here")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.elevatedBackground)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppRadius.card,
                        style: .continuous
                    )
                )
        }
    } footer: {
        AppPrimaryButton(title: "Save Expense", isEnabled: false) {}
    }
}
