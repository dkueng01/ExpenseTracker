import SwiftUI

struct AppFormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader(title: title)
            content
        }
    }
}

#Preview {
    AppFormSection(title: "Name") {
        TextField("Category name", text: .constant(""))
            .appInputFieldStyle()
    }
    .padding()
    .background(AppColors.screenBackground)
}
