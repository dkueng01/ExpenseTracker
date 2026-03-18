import SwiftUI

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case bills = "Bills"
    case health = "Health"
    case fun = "Fun"
    case other = "Other"

    var id: String {
        rawValue
    }

    static var defaultCategory: ExpenseCategory {
        .food
    }

    static func from(_ name: String) -> ExpenseCategory {
        ExpenseCategory(rawValue: name) ?? .other
    }

    var systemImage: String {
        switch self {
        case .food:
            return "fork.knife"
        case .transport:
            return "car.fill"
        case .shopping:
            return "bag.fill"
        case .bills:
            return "doc.text.fill"
        case .health:
            return "cross.case.fill"
        case .fun:
            return "gamecontroller.fill"
        case .other:
            return "square.grid.2x2.fill"
        }
    }

    var color: Color {
        switch self {
        case .food:
            return .orange
        case .transport:
            return .blue
        case .shopping:
            return .pink
        case .bills:
            return .purple
        case .health:
            return .red
        case .fun:
            return .green
        case .other:
            return .gray
        }
    }
}
