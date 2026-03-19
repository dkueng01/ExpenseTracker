import SwiftUI

struct AppBottomBar<Content: View>: View {
    @ViewBuilder let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            content
                .padding(.horizontal, AppSpacing.pageHorizontal)
                .padding(.top, AppSpacing.bottomBarTop)
                .padding(.bottom, AppSpacing.bottomBarBottom)
        }
        .background(.regularMaterial)
    }
}

#Preview {
    VStack {
        Spacer()

        AppBottomBar {
            AppPrimaryButton(title: "Save Expense") {}
        }
    }
    .background(AppColors.screenBackground)
}
