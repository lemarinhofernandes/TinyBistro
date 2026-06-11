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

        static let happyEffectNodeName = "customer-happy-effect"
        static let happyEffectY: Float = 1.35
        static let happyEffectInitialScale: Float = 0.2
        static let happyPlaneWidth: CGFloat = 0.95
        static let happyPlaneHeight: CGFloat = 0.44
        static let happyImageSize = CGSize(width: 220, height: 104)
        static let happyHaloRect = CGRect(x: 28, y: 10, width: 164, height: 84)
        static let happyEmojiFrame = CGRect(x: 24, y: 16, width: 76, height: 72)
        static let happyBonusFrame = CGRect(x: 94, y: 10, width: 102, height: 82)
        static let happyEmojiFontSize: CGFloat = 58
        static let happyBonusFontSize: CGFloat = 60
        static let happyBonusStrokeWidth: CGFloat = -4
        static let happyGreen = UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 1)
        static let happyHaloColor = UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 0.34)
        static let happyShadowColor = UIColor(red: 0.03, green: 0.62, blue: 0.25, alpha: 0.88)

        static let staffClockNodeName = "staff-clock"
        static let staffClockY: Float = 1.45
        static let staffClockPlaneSize: CGFloat = 0.46
        static let staffClockImageSize = CGSize(width: 128, height: 128)
        static let staffClockLineWidth: CGFloat = 8
        static let staffClockHandWidth: CGFloat = 9
        static let staffClockMarkLength: CGFloat = 15
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
        root.position = SceneCoordinates.worldPosition(for: entity, in: world, y: 0.12)

        let body = SCNCapsule(capRadius: 0.20, height: 0.78)
        body.materials = [entityMaterial(for: entity.role)]
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

    private static func entityMaterial(for role: EntityRole) -> SCNMaterial {
        switch role {
        case .manager:
            return BistroMaterials.manager
        case .staff, .chef, .waiter:
            return BistroMaterials.staff
        case .customer:
            return BistroMaterials.customer
        }
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
        let root = SceneBillboardFactory.billboardNode(
            name: Constants.timeoutEffectNodeName,
            width: Constants.timeoutPlaneWidth,
            height: Constants.timeoutPlaneHeight,
            y: Constants.timeoutEffectY,
            image: timeoutEffectImage()
        )

        root.scale = SCNVector3(
            Constants.timeoutEffectInitialScale,
            Constants.timeoutEffectInitialScale,
            Constants.timeoutEffectInitialScale
        )
        return root
    }

    static func happyEffectNode() -> SCNNode {
        let root = SceneBillboardFactory.billboardNode(
            name: Constants.happyEffectNodeName,
            width: Constants.happyPlaneWidth,
            height: Constants.happyPlaneHeight,
            y: Constants.happyEffectY,
            image: happyEffectImage()
        )

        root.scale = SCNVector3(
            Constants.happyEffectInitialScale,
            Constants.happyEffectInitialScale,
            Constants.happyEffectInitialScale
        )
        return root
    }

    static func staffClockNode(progress: Double) -> SCNNode {
        SceneBillboardFactory.billboardNode(
            name: Constants.staffClockNodeName,
            width: Constants.staffClockPlaneSize,
            height: Constants.staffClockPlaneSize,
            y: Constants.staffClockY,
            image: staffClockImage(progress: progress)
        )
    }

    static func staffClockMaterial(progress: Double) -> SCNMaterial {
        SceneBillboardFactory.imageMaterial(staffClockImage(progress: progress))
    }

    private static func timeoutEffectImage() -> UIImage {
        SceneBillboardFactory.renderImage(size: Constants.timeoutImageSize) { cgContext in
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

    private static func happyEffectImage() -> UIImage {
        SceneBillboardFactory.renderImage(size: Constants.happyImageSize) { cgContext in
            cgContext.setShadow(
                offset: .zero,
                blur: Constants.timeoutShadowBlur,
                color: Constants.happyShadowColor.cgColor
            )

            let haloPath = UIBezierPath(ovalIn: Constants.happyHaloRect)
            Constants.happyHaloColor.setFill()
            haloPath.fill()

            cgContext.setShadow(
                offset: .zero,
                blur: Constants.timeoutTextShadowBlur,
                color: UIColor.black.withAlphaComponent(0.65).cgColor
            )

            let emojiAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: Constants.happyEmojiFontSize),
                .paragraphStyle: centeredParagraphStyle
            ]
            ("😀" as NSString).draw(
                in: Constants.happyEmojiFrame,
                withAttributes: emojiAttributes
            )

            let bonusAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: Constants.happyBonusFontSize, weight: .black),
                .foregroundColor: Constants.happyGreen,
                .strokeColor: UIColor.white,
                .strokeWidth: Constants.happyBonusStrokeWidth,
                .paragraphStyle: centeredParagraphStyle
            ]
            ("++" as NSString).draw(
                in: Constants.happyBonusFrame,
                withAttributes: bonusAttributes
            )
        }
    }

    private static func staffClockImage(progress: Double) -> UIImage {
        let clampedProgress = GeometryUtils.clamp(progress, min: 0, max: 1)
        return SceneBillboardFactory.renderImage(size: Constants.staffClockImageSize) { cgContext in
            let size = Constants.staffClockImageSize
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius: CGFloat = 48
            let clockRect = CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )

            cgContext.setShadow(offset: .zero, blur: 10, color: UIColor.black.withAlphaComponent(0.62).cgColor)
            UIColor(red: 0.96, green: 0.87, blue: 0.72, alpha: 0.96).setFill()
            UIBezierPath(ovalIn: clockRect).fill()

            UIColor.white.setStroke()
            let outline = UIBezierPath(ovalIn: clockRect)
            outline.lineWidth = Constants.staffClockLineWidth
            outline.stroke()

            UIColor(red: 0.18, green: 0.22, blue: 0.25, alpha: 0.96).setStroke()
            let inner = UIBezierPath(ovalIn: clockRect.insetBy(dx: 6, dy: 6))
            inner.lineWidth = 3
            inner.stroke()

            drawClockMarks(center: center, radius: radius - 11)
            drawClockHand(center: center, radius: radius - 18, progress: clampedProgress)
        }
    }

    private static func drawClockMarks(center: CGPoint, radius: CGFloat) {
        UIColor(red: 0.86, green: 0.20, blue: 0.17, alpha: 1).setStroke()
        for index in 0..<4 {
            let angle = CGFloat(index) * .pi / 2 - .pi / 2
            let outer = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            let inner = CGPoint(
                x: center.x + cos(angle) * (radius - Constants.staffClockMarkLength),
                y: center.y + sin(angle) * (radius - Constants.staffClockMarkLength)
            )

            let mark = UIBezierPath()
            mark.move(to: inner)
            mark.addLine(to: outer)
            mark.lineWidth = 6
            mark.lineCapStyle = .round
            mark.stroke()
        }
    }

    private static func drawClockHand(center: CGPoint, radius: CGFloat, progress: Double) {
        let angle = CGFloat(progress * 2 * .pi) - .pi / 2
        let end = CGPoint(
            x: center.x + cos(angle) * radius,
            y: center.y + sin(angle) * radius
        )

        UIColor(red: 0.12, green: 0.39, blue: 0.75, alpha: 1).setStroke()
        let hand = UIBezierPath()
        hand.move(to: center)
        hand.addLine(to: end)
        hand.lineWidth = Constants.staffClockHandWidth
        hand.lineCapStyle = .round
        hand.stroke()

        Constants.happyGreen.setFill()
        UIBezierPath(ovalIn: CGRect(x: center.x - 7, y: center.y - 7, width: 14, height: 14)).fill()
    }

    private static var centeredParagraphStyle: NSParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        return paragraph
    }
}
