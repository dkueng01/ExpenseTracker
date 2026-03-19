import SwiftUI

struct AppSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.appSectionTitle)
            .foregroundStyle(AppColors.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AppSectionHeader(title: "Overview")
        .padding()
}
