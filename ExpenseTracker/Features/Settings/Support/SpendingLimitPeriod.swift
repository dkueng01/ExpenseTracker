import Foundation

enum SpendingLimitPeriod: String, CaseIterable, Identifiable {
    case daily
    case weekly
    case monthly

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        }
    }
}
