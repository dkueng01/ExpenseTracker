import Foundation

enum SharedSettings {
    static let appGroupID = AppModelContainer.appGroupID

    static var userDefaults: UserDefaults {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            fatalError("Could not create shared UserDefaults.")
        }
        return defaults
    }
}
