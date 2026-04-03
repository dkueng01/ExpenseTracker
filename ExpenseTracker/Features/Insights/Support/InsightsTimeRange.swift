import Foundation

enum InsightsTimeRange: String, CaseIterable, Identifiable {
    case week
    case month
    case year
    case allTime
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week:
            return "Week"
        case .month:
            return "Month"
        case .year:
            return "Year"
        case .allTime:
            return "All"
        case .custom:
            return "Custom"
        }
    }
}
