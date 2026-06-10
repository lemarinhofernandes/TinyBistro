import SceneKit
import UIKit

enum SceneBillboardFactory {
    static func billboardNode(
        name: String,
        width: CGFloat,
        height: CGFloat,
        y: Float = 0,
        image: UIImage
    ) -> SCNNode {
        let node = SCNNode()
        node.name = name
        node.position.y = y
        node.constraints = [SCNBillboardConstraint()]
        node.geometry = billboardPlane(width: width, height: height, image: image)
        return node
    }

    static func billboardPlane(width: CGFloat, height: CGFloat, image: UIImage) -> SCNPlane {
        let plane = SCNPlane(width: width, height: height)
        plane.materials = [imageMaterial(image)]
        return plane
    }

    static func imageMaterial(_ image: UIImage) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = image
        material.emission.contents = image
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.writesToDepthBuffer = false
        return material
    }

    static func renderImage(size: CGSize, draw: (CGContext) -> Void) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            draw(context.cgContext)
        }
    }
}
