import SwiftUI

struct AppDestructiveButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            Text(title)
                .font(.appButton)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
        }
        .buttonStyle(.borderless)
    }
}

#Preview {
    AppDestructiveButton(title: "Delete Expense") {}
        .padding()
}
