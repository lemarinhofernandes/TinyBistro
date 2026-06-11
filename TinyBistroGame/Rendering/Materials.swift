import SceneKit
import UIKit

enum BistroMaterials {
    static let floorLight = material(hex: 0xFFF3D9, roughness: 0.82, emission: 0xFFF3D9, emissionIntensity: 0.04)
    static let floorDark = material(hex: 0xF59E42, roughness: 0.72, metalness: 0.05, emission: 0xF59E42, emissionIntensity: 0.04)
    static let wall = material(hex: 0xFFF3D9, roughness: 0.72, emission: 0xFFF3D9, emissionIntensity: 0.1)
    static let manager = material(hex: 0x8E44EC, roughness: 0.36, metalness: 0.2, emission: 0x8E44EC, emissionIntensity: 0.11)
    static let staff = material(hex: 0x2E86DE, roughness: 0.42, metalness: 0.18, emission: 0x2E86DE, emissionIntensity: 0.06)
    static let customer = material(hex: 0xE24A3B, roughness: 0.48, metalness: 0.08, emission: 0xE24A3B, emissionIntensity: 0.05)
    static let marker = material(hex: 0xFFE66D, roughness: 0.28, metalness: 0.34, emission: 0xFFE66D, emissionIntensity: 0.32)
    static let table = material(hex: 0xF59E42, roughness: 0.46, metalness: 0.12, emission: 0x8C5A3C, emissionIntensity: 0.08)
    static let chair = material(hex: 0xE24A3B, roughness: 0.48, metalness: 0.16, emission: 0xE24A3B, emissionIntensity: 0.06)
    static let stove = material(hex: 0x1E1E1E, roughness: 0.36, metalness: 0.48, emission: 0x5C6A72, emissionIntensity: 0.06)
    static let counter = material(hex: 0x7FE9A8, alpha: 0.92, roughness: 0.18, metalness: 0.06, emission: 0x7FE9A8, emissionIntensity: 0.16)
    static let entrance = material(hex: 0x2E86DE, roughness: 0.42, metalness: 0.22, emission: 0x2E86DE, emissionIntensity: 0.08)
    static let selected = material(hex: 0xFFE66D, roughness: 0.24, metalness: 0.28, emission: 0xFFE66D, emissionIntensity: 0.38)

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
