import SceneKit
import UIKit

enum NodeFactory {
    private struct Constants {
        static let timeoutEffectNodeName = "customer-timeout-effect"
        static let timeoutEffectY: Float = 1.35
        static let timeoutEffectInitialScale: Float = 0.2
        static let timeoutPlaneWidth: CGFloat = 0.95
        static let timeoutPlaneHeight: CGFloat = 0.44
        static let timeoutImageSize = CGSize(width: 220, height: 104)
        static let timeoutHaloRect = CGRect(x: 28, y: 10, width: 164, height: 84)
        static let timeoutShadowBlur: CGFloat = 14
        static let timeoutTextShadowBlur: CGFloat = 7
        static let timeoutEmojiFrame = CGRect(x: 24, y: 16, width: 76, height: 72)
        static let timeoutPenaltyFrame = CGRect(x: 94, y: 10, width: 102, height: 82)
        static let timeoutEmojiFontSize: CGFloat = 58
        static let timeoutPenaltyFontSize: CGFloat = 60
        static let timeoutPenaltyStrokeWidth: CGFloat = -4
        static let timeoutHaloColor = UIColor(red: 1, green: 0.08, blue: 0.02, alpha: 0.30)
        static let timeoutShadowColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.85)
        static let timeoutPenaltyColor = UIColor(red: 1, green: 0.02, blue: 0.02, alpha: 1)
    }

    static func tileNode(position: GridPosition, isDark: Bool, world: BistroWorld) -> SCNNode {
        let geometry = SCNBox(width: 0.96, height: 0.05, length: 0.96, chamferRadius: 0.025)
        geometry.materials = [isDark ? BistroMaterials.floorDark : BistroMaterials.floorLight]

        let node = SCNNode(geometry: geometry)
        node.name = SceneNodeName.tile(position)
        node.position = SceneCoordinates.worldPosition(for: position, in: world, y: 0)
        return node
    }

    static func furnitureNode(_ furniture: Furniture, world: BistroWorld) -> SCNNode {
        let root = SCNNode()
        root.name = SceneNodeName.furniture(furniture.id)
        root.position = SceneCoordinates.worldPosition(for: furniture.position, in: world, y: 0.06)

        switch furniture.kind {
        case .entrance:
            let mat = SCNBox(width: 0.82, height: 0.04, length: 0.82, chamferRadius: 0.04)
            mat.materials = [BistroMaterials.entrance]
            root.addChildNode(SCNNode(geometry: mat))

        case .table:
            let top = SCNCylinder(radius: 0.36, height: 0.16)
            top.materials = [BistroMaterials.table]
            let topNode = SCNNode(geometry: top)
            topNode.position.y = 0.42
            root.addChildNode(topNode)

            let leg = SCNCylinder(radius: 0.08, height: 0.42)
            leg.materials = [BistroMaterials.table]
            let legNode = SCNNode(geometry: leg)
            legNode.position.y = 0.20
            root.addChildNode(legNode)

        case .chair:
            let seat = SCNBox(width: 0.46, height: 0.12, length: 0.46, chamferRadius: 0.03)
            seat.materials = [BistroMaterials.chair]
            let seatNode = SCNNode(geometry: seat)
            seatNode.position.y = 0.25
            root.addChildNode(seatNode)

            let back = SCNBox(width: 0.46, height: 0.48, length: 0.10, chamferRadius: 0.02)
            back.materials = [BistroMaterials.chair]
            let backNode = SCNNode(geometry: back)
            backNode.position = SCNVector3(0, 0.52, 0.22)
            root.addChildNode(backNode)

        case .stove:
            let body = SCNBox(width: 0.76, height: 0.48, length: 0.72, chamferRadius: 0.04)
            body.materials = [BistroMaterials.stove]
            let bodyNode = SCNNode(geometry: body)
            bodyNode.position.y = 0.26
            root.addChildNode(bodyNode)

            let burner = SCNTorus(ringRadius: 0.18, pipeRadius: 0.02)
            burner.materials = [BistroMaterials.marker]
            let burnerNode = SCNNode(geometry: burner)
            burnerNode.eulerAngles.x = Float.pi / 2
            burnerNode.position.y = 0.53
            root.addChildNode(burnerNode)

        case .counter:
            let body = SCNBox(width: 0.82, height: 0.54, length: 0.72, chamferRadius: 0.04)
            body.materials = [BistroMaterials.counter]
            let bodyNode = SCNNode(geometry: body)
            bodyNode.position.y = 0.30
            root.addChildNode(bodyNode)
        }

        return root
    }

    static func entityNode(_ entity: Entity, world: BistroWorld) -> SCNNode {
        let root = SCNNode()
        root.name = SceneNodeName.entity(entity.id)
        root.position = SceneCoordinates.worldPosition(for: entity.position, in: world, y: 0.12)

        let body = SCNCapsule(capRadius: 0.20, height: 0.78)
        body.materials = [entity.role == .staff ? BistroMaterials.staff : BistroMaterials.customer]
        let bodyNode = SCNNode(geometry: body)
        bodyNode.position.y = 0.46
        root.addChildNode(bodyNode)

        let marker = SCNSphere(radius: 0.11)
        marker.materials = [BistroMaterials.marker]
        let markerNode = SCNNode(geometry: marker)
        markerNode.position.y = 0.95
        root.addChildNode(markerNode)

        return root
    }

    static func selectionNode(position: GridPosition, world: BistroWorld) -> SCNNode {
        let geometry = SCNBox(width: 1.02, height: 0.035, length: 1.02, chamferRadius: 0.02)
        geometry.materials = [BistroMaterials.selected]

        let node = SCNNode(geometry: geometry)
        node.name = "selection"
        node.opacity = 0.42
        node.position = SceneCoordinates.worldPosition(for: position, in: world, y: 0.09)
        return node
    }

    static func timeoutEffectNode() -> SCNNode {
        let root = SCNNode()
        root.name = Constants.timeoutEffectNodeName
        root.position = SCNVector3(0, Constants.timeoutEffectY, 0)
        root.scale = SCNVector3(
            Constants.timeoutEffectInitialScale,
            Constants.timeoutEffectInitialScale,
            Constants.timeoutEffectInitialScale
        )
        root.constraints = [SCNBillboardConstraint()]

        let geometry = SCNPlane(width: Constants.timeoutPlaneWidth, height: Constants.timeoutPlaneHeight)
        geometry.materials = [timeoutEffectMaterial()]
        root.geometry = geometry

        return root
    }

    private static func timeoutEffectMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = timeoutEffectImage()
        material.emission.contents = timeoutEffectImage()
        material.lightingModel = .constant
        material.isDoubleSided = true
        return material
    }

    private static func timeoutEffectImage() -> UIImage {
        let size = Constants.timeoutImageSize
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let cgContext = context.cgContext

            cgContext.setShadow(
                offset: .zero,
                blur: Constants.timeoutShadowBlur,
                color: Constants.timeoutShadowColor.cgColor
            )

            let haloPath = UIBezierPath(ovalIn: Constants.timeoutHaloRect)
            Constants.timeoutHaloColor.setFill()
            haloPath.fill()

            cgContext.setShadow(
                offset: .zero,
                blur: Constants.timeoutTextShadowBlur,
                color: UIColor.black.withAlphaComponent(0.75).cgColor
            )

            let emojiAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: Constants.timeoutEmojiFontSize),
                .paragraphStyle: centeredParagraphStyle
            ]
            ("😡" as NSString).draw(
                in: Constants.timeoutEmojiFrame,
                withAttributes: emojiAttributes
            )

            let penaltyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: Constants.timeoutPenaltyFontSize, weight: .black),
                .foregroundColor: Constants.timeoutPenaltyColor,
                .strokeColor: UIColor.white,
                .strokeWidth: Constants.timeoutPenaltyStrokeWidth,
                .paragraphStyle: centeredParagraphStyle
            ]
            ("--" as NSString).draw(
                in: Constants.timeoutPenaltyFrame,
                withAttributes: penaltyAttributes
            )
        }
    }

    private static var centeredParagraphStyle: NSParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        return paragraph
    }
}
