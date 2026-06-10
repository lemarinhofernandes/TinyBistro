import SceneKit
import UIKit

enum BistroMaterials {
    static let floorLight = material(hex: 0xF3E7D0, roughness: 0.9)
    static let floorDark = material(hex: 0xC8A77C, roughness: 0.86)
    static let wall = material(hex: 0xFBF7F1, roughness: 0.82, emission: 0xF3E7D0, emissionIntensity: 0.08)
    static let staff = material(hex: 0x34495E, roughness: 0.7, metalness: 0.08)
    static let customer = material(hex: 0xE24A3B, roughness: 0.78)
    static let marker = material(hex: 0xD6A14A, roughness: 0.44, metalness: 0.28, emission: 0xC47E3A, emissionIntensity: 0.12)
    static let table = material(hex: 0x8C5A3C, roughness: 0.58, metalness: 0.03, emission: 0x5D3827, emissionIntensity: 0.04)
    static let chair = material(hex: 0xC47E3A, roughness: 0.62, metalness: 0.12)
    static let stove = material(hex: 0x2C2C2C, roughness: 0.48, metalness: 0.32)
    static let counter = material(hex: 0x9EC6A6, alpha: 0.9, roughness: 0.24, metalness: 0.02, emission: 0x9EC6A6, emissionIntensity: 0.08)
    static let entrance = material(hex: 0x34495E, roughness: 0.54, metalness: 0.1)
    static let selected = material(hex: 0xF0B84D, roughness: 0.35, metalness: 0.2, emission: 0xF0B84D, emissionIntensity: 0.2)

    static func material(
        hex: UInt,
        alpha: CGFloat = 1,
        roughness: CGFloat = 0.85,
        metalness: CGFloat = 0,
        emission: UInt? = nil,
        emissionIntensity: CGFloat = 0
    ) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(hex: hex, alpha: alpha)
        material.roughness.contents = roughness
        material.metalness.contents = metalness

        if let emission {
            material.emission.contents = UIColor(hex: emission)
            material.emission.intensity = emissionIntensity
        }

        material.isDoubleSided = false
        return material
    }
}

private extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
