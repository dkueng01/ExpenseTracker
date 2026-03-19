import SwiftUI

struct AppIconBadge: View {
    let systemImage: String
    let color: Color
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.14))

            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 16) {
        AppIconBadge(systemImage: "fork.knife", color: .orange)
        AppIconBadge(systemImage: "calendar", color: .green, size: 52)
    }
    .padding()
}
