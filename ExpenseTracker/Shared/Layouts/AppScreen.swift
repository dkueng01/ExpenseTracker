import SwiftUI

struct AppScreen<Content: View, FloatingAction: View>: View {
    let title: String
    @ViewBuilder let content: Content
    @ViewBuilder let floatingAction: FloatingAction

    init(
        title: String,
        @ViewBuilder content: () -> Content
    ) where FloatingAction == EmptyView {
        self.title = title
        self.content = content()
        self.floatingAction = EmptyView()
    }

    init(
        title: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder floatingAction: () -> FloatingAction
    ) {
        self.title = title
        self.content = content()
        self.floatingAction = floatingAction()
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.sectionSpacing
                ) {
                    Text(title)
                        .font(.appPageTitle)
                        .foregroundStyle(AppColors.primaryText)

                    content
                }
                .padding(.horizontal, AppSpacing.pageHorizontal)
                .padding(.top, AppSpacing.xxxl)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background(AppColors.screenBackground)

            floatingAction
                .padding(.trailing, AppSpacing.pageHorizontal)
                .padding(.bottom, AppSpacing.pageHorizontal)
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
    }
}

#Preview {
    AppScreen(title: "Expenses") {
        VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
            AppSectionHeader(title: "Overview")

            Text("Example content")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .appCardStyle()
        }
    } floatingAction: {
        Circle()
            .fill(.blue)
            .frame(width: 56, height: 56)
    }
}
