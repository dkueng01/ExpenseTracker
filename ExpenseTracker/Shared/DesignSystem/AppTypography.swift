import SwiftUI

extension Font {
    static let appPageTitle = Font.system(size: 34, weight: .bold)
    static let appSheetTitle = Font.title2.weight(.semibold)

    static let appSectionTitle = Font.title3.weight(.bold)
    static let appCardTitle = Font.headline
    static let appBody = Font.body
    static let appBodyStrong = Font.body.weight(.semibold)
    static let appCaption = Font.caption

    static let appButton = Font.headline

    static let appAmountSymbol = Font.system(
        size: 30,
        weight: .bold,
        design: .rounded
    )

    static let appAmountValue = Font.system(
        size: 42,
        weight: .bold,
        design: .rounded
    )
}
