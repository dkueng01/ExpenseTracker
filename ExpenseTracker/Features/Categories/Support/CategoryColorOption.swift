import SwiftUI

enum CategoryColorOption: String, CaseIterable, Identifiable {
    case orange
    case blue
    case pink
    case purple
    case red
    case green
    case gray
    case teal
    case indigo
    case brown

    var id: String {
        rawValue
    }

    var color: Color {
        switch self {
        case .orange:
            return .orange
        case .blue:
            return .blue
        case .pink:
            return .pink
        case .purple:
            return .purple
        case .red:
            return .red
        case .green:
            return .green
        case .gray:
            return .gray
        case .teal:
            return .teal
        case .indigo:
            return .indigo
        case .brown:
            return .brown
        }
    }
}
