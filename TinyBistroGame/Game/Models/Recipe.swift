import Foundation

struct Recipe: Identifiable, Hashable, Sendable {
    let id: String
    var name: String
    var duration: TimeInterval

    static let houseSoup = Recipe(id: "house-soup", name: "House Soup", duration: 5)
}
