import SceneKit
import UIKit

enum BistroMaterials {
    static let floorLight = material(red: 0.74, green: 0.63, blue: 0.48)
    static let floorDark = material(red: 0.58, green: 0.47, blue: 0.34)
    static let wall = material(red: 0.80, green: 0.70, blue: 0.58)
    static let staff = material(red: 0.16, green: 0.43, blue: 0.73)
    static let customer = material(red: 0.86, green: 0.38, blue: 0.24)
    static let marker = material(red: 0.98, green: 0.88, blue: 0.58)
    static let table = material(red: 0.45, green: 0.25, blue: 0.13)
    static let chair = material(red: 0.67, green: 0.42, blue: 0.22)
    static let stove = material(red: 0.18, green: 0.20, blue: 0.22)
    static let counter = material(red: 0.34, green: 0.45, blue: 0.43)
    static let entrance = material(red: 0.18, green: 0.47, blue: 0.36)
    static let selected = material(red: 1.00, green: 0.82, blue: 0.25)

    static func material(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        material.roughness.contents = 0.85
        return material
    }
}
