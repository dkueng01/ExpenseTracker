import Foundation

enum CategoryIconOption: String, CaseIterable, Identifiable {
    case forkKnife = "fork.knife"
    case car = "car.fill"
    case bag = "bag.fill"
    case bills = "doc.text.fill"
    case health = "cross.case.fill"
    case fun = "gamecontroller.fill"
    case other = "square.grid.2x2.fill"
    case cart = "cart.fill"
    case house = "house.fill"
    case cup = "cup.and.saucer.fill"
    case gift = "gift.fill"
    case airplane = "airplane"
    case bus = "bus.fill"
    case fuel = "fuelpump.fill"
    case film = "film.fill"
    case music = "music.note"
    case paw = "pawprint.fill"
    case shirt = "tshirt.fill"
    case book = "book.fill"
    case tag = "tag.fill"

    var id: String {
        rawValue
    }
}
