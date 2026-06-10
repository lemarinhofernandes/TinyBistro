import SceneKit
import UIKit

final class BistroEffectsController {
    private struct Constants {
        static let cookingGlowName = "bistro-effect:cooking-glow"
        static let readyCounterGlowName = "bistro-effect:ready-counter-glow"
        static let readyCustomerGlowPrefix = "bistro-effect:ready-customer-glow:"
        static let patienceBarPrefix = "bistro-effect:patience-bar:"

        static let cookingGlowY: Float = 0.56
        static let cookingGlowRingRadius: CGFloat = 0.34
        static let cookingGlowPipeRadius: CGFloat = 0.025
        static let cookingPulseScale: CGFloat = 1.18
        static let cookingPulseDuration = 0.62

        static let readyCounterY: Float = 0.86
        static let readyCustomerY: Float = 1.32
        static let readyBadgeWidth: CGFloat = 0.92
        static let readyBadgeHeight: CGFloat = 0.36
        static let readyPulseScale: CGFloat = 1.1
        static let readyPulseDuration = 0.72

        static let patienceBarY: Float = 1.18
        static let patienceBarWidth: CGFloat = 0.92
        static let patienceBarHeight: CGFloat = 0.22

        static let lightIntensity: CGFloat = 185
        static let lightY: Float = 0.62
        static let lightZ: Float = 0.05
    }

    private let scene: SCNScene
    private var activeReadyCustomerID: Entity.ID?

    init(scene: SCNScene) {
        self.scene = scene
    }

    func sync(
        world: BistroWorld,
        furnitureNodes: [Furniture.ID: SCNNode],
        entityNodes: [Entity.ID: SCNNode]
    ) {
        syncCookingGlow(world: world, furnitureNodes: furnitureNodes)
        syncReadyGlow(world: world, furnitureNodes: furnitureNodes, entityNodes: entityNodes)
        syncWaitingCustomerTimers(world: world, entityNodes: entityNodes)
    }

    private func syncCookingGlow(
        world: BistroWorld,
        furnitureNodes: [Furniture.ID: SCNNode]
    ) {
        guard world.orders.contains(where: { $0.status == .cooking }),
              let stoveNode = node(for: .stove, in: world, furnitureNodes: furnitureNodes)
        else {
            removeEffect(named: Constants.cookingGlowName)
            return
        }

        guard stoveNode.childNode(withName: Constants.cookingGlowName, recursively: false) == nil else {
            return
        }

        stoveNode.addChildNode(cookingGlowNode())
    }

    private func syncReadyGlow(
        world: BistroWorld,
        furnitureNodes: [Furniture.ID: SCNNode],
        entityNodes: [Entity.ID: SCNNode]
    ) {
        guard let readyOrder = world.orders.first(where: { $0.status == .ready }) else {
            removeEffect(named: Constants.readyCounterGlowName)
            removeActiveReadyCustomerGlow(from: entityNodes)
            return
        }

        if let counterNode = node(for: .counter, in: world, furnitureNodes: furnitureNodes),
           counterNode.childNode(withName: Constants.readyCounterGlowName, recursively: false) == nil {
            counterNode.addChildNode(readyBadgeNode(name: Constants.readyCounterGlowName, y: Constants.readyCounterY))
        }

        if activeReadyCustomerID != readyOrder.customerID {
            removeActiveReadyCustomerGlow(from: entityNodes)
        }

        guard let customerNode = entityNodes[readyOrder.customerID] else {
            activeReadyCustomerID = nil
            return
        }

        let effectName = readyCustomerGlowName(for: readyOrder.customerID)
        if customerNode.childNode(withName: effectName, recursively: false) == nil {
            customerNode.addChildNode(readyBadgeNode(name: effectName, y: Constants.readyCustomerY))
        }
        activeReadyCustomerID = readyOrder.customerID
    }

    private func syncWaitingCustomerTimers(
        world: BistroWorld,
        entityNodes: [Entity.ID: SCNNode]
    ) {
        let waitingCustomers = world.entities.filter { entity in
            entity.role == .customer && entity.customerState == .waitingForFood
        }
        let waitingIDs = Set(waitingCustomers.map(\.id))

        for (id, node) in entityNodes where !waitingIDs.contains(id) {
            node.childNode(withName: patienceBarName(for: id), recursively: false)?.removeFromParentNode()
        }

        for customer in waitingCustomers {
            guard let customerNode = entityNodes[customer.id] else {
                continue
            }

            let remainingTime = max(world.waitTimeout - customer.stateElapsedTime, 0)
            let progress = world.waitTimeout > 0 ? remainingTime / world.waitTimeout : 0
            let material = Self.patienceBarMaterial(
                progress: progress,
                remainingSeconds: Int(ceil(remainingTime))
            )
            let effectName = patienceBarName(for: customer.id)

            if let existingNode = customerNode.childNode(withName: effectName, recursively: false),
               let plane = existingNode.geometry as? SCNPlane {
                plane.materials = [material]
            } else {
                let node = SCNNode()
                node.name = effectName
                node.position.y = Constants.patienceBarY
                node.constraints = [SCNBillboardConstraint()]

                let plane = SCNPlane(width: Constants.patienceBarWidth, height: Constants.patienceBarHeight)
                plane.materials = [material]
                node.geometry = plane
                customerNode.addChildNode(node)
            }
        }
    }

    private func node(
        for kind: FurnitureKind,
        in world: BistroWorld,
        furnitureNodes: [Furniture.ID: SCNNode]
    ) -> SCNNode? {
        guard let furniture = world.furniture.first(where: { $0.kind == kind }) else {
            return nil
        }

        return furnitureNodes[furniture.id]
    }

    private func cookingGlowNode() -> SCNNode {
        let root = SCNNode()
        root.name = Constants.cookingGlowName

        let ring = SCNTorus(
            ringRadius: Constants.cookingGlowRingRadius,
            pipeRadius: Constants.cookingGlowPipeRadius
        )
        ring.materials = [Self.glowMaterial(color: UIColor(hex: 0xF0B84D), alpha: 0.85)]

        let ringNode = SCNNode(geometry: ring)
        ringNode.eulerAngles.x = Float.pi / 2
        ringNode.position.y = Constants.cookingGlowY
        root.addChildNode(ringNode)

        let light = SCNLight()
        light.type = .omni
        light.color = UIColor(hex: 0xF0B84D)
        light.intensity = Constants.lightIntensity
        light.attenuationEndDistance = 2.1

        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0, Constants.lightY, Constants.lightZ)
        root.addChildNode(lightNode)

        let scaleUp = SCNAction.scale(to: Constants.cookingPulseScale, duration: Constants.cookingPulseDuration)
        scaleUp.timingMode = .easeInEaseOut
        let scaleDown = SCNAction.scale(to: 1, duration: Constants.cookingPulseDuration)
        scaleDown.timingMode = .easeInEaseOut
        root.runAction(.repeatForever(.sequence([scaleUp, scaleDown])))

        return root
    }

    private func readyBadgeNode(name: String, y: Float) -> SCNNode {
        let node = SCNNode()
        node.name = name
        node.position.y = y
        node.constraints = [SCNBillboardConstraint()]

        let geometry = SCNPlane(width: Constants.readyBadgeWidth, height: Constants.readyBadgeHeight)
        geometry.materials = [Self.readyBadgeMaterial()]
        node.geometry = geometry

        let scaleUp = SCNAction.scale(to: Constants.readyPulseScale, duration: Constants.readyPulseDuration)
        scaleUp.timingMode = .easeInEaseOut
        let scaleDown = SCNAction.scale(to: 1, duration: Constants.readyPulseDuration)
        scaleDown.timingMode = .easeInEaseOut
        node.runAction(.repeatForever(.sequence([scaleUp, scaleDown])))

        return node
    }

    private func removeActiveReadyCustomerGlow(from entityNodes: [Entity.ID: SCNNode]) {
        guard let activeReadyCustomerID else {
            return
        }

        entityNodes[activeReadyCustomerID]?
            .childNode(withName: readyCustomerGlowName(for: activeReadyCustomerID), recursively: false)?
            .removeFromParentNode()
        self.activeReadyCustomerID = nil
    }

    private func removeEffect(named name: String) {
        scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == name {
                node.removeFromParentNode()
            }
        }
    }

    private func readyCustomerGlowName(for id: Entity.ID) -> String {
        Constants.readyCustomerGlowPrefix + id.uuidString
    }

    private func patienceBarName(for id: Entity.ID) -> String {
        Constants.patienceBarPrefix + id.uuidString
    }

    private static func glowMaterial(color: UIColor, alpha: CGFloat) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color.withAlphaComponent(alpha)
        material.emission.contents = color
        material.emission.intensity = 0.65
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.transparency = alpha
        return material
    }

    private static func readyBadgeMaterial() -> SCNMaterial {
        let image = readyBadgeImage()
        let material = SCNMaterial()
        material.diffuse.contents = image
        material.emission.contents = image
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.writesToDepthBuffer = false
        return material
    }

    private static func readyBadgeImage() -> UIImage {
        let size = CGSize(width: 220, height: 92)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let cgContext = context.cgContext
            let rect = CGRect(x: 12, y: 16, width: size.width - 24, height: size.height - 32)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 24)

            cgContext.setShadow(
                offset: .zero,
                blur: 16,
                color: UIColor(hex: 0x9EC6A6, alpha: 0.85).cgColor
            )
            UIColor(hex: 0x9EC6A6, alpha: 0.72).setFill()
            path.fill()

            cgContext.setShadow(offset: .zero, blur: 5, color: UIColor.black.withAlphaComponent(0.65).cgColor)

            let strokePath = UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: 22)
            UIColor.white.withAlphaComponent(0.9).setStroke()
            strokePath.lineWidth = 4
            strokePath.stroke()

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .black),
                .foregroundColor: UIColor(hex: 0xFBF7F1),
                .strokeColor: UIColor(hex: 0x34495E),
                .strokeWidth: -3,
                .paragraphStyle: centeredParagraphStyle
            ]
            ("READY" as NSString).draw(in: CGRect(x: 0, y: 26, width: size.width, height: 42), withAttributes: attributes)
        }
    }

    private static func patienceBarMaterial(progress: Double, remainingSeconds: Int) -> SCNMaterial {
        let image = patienceBarImage(progress: progress, remainingSeconds: remainingSeconds)
        let material = SCNMaterial()
        material.diffuse.contents = image
        material.emission.contents = image
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.writesToDepthBuffer = false
        return material
    }

    private static func patienceBarImage(progress: Double, remainingSeconds: Int) -> UIImage {
        let size = CGSize(width: 220, height: 54)
        let progress = min(max(progress, 0), 1)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let cgContext = context.cgContext
            let outerRect = CGRect(x: 8, y: 10, width: size.width - 16, height: 34)
            let innerRect = outerRect.insetBy(dx: 5, dy: 6)
            let fillWidth = max(8, innerRect.width * progress)
            let fillRect = CGRect(x: innerRect.minX, y: innerRect.minY, width: fillWidth, height: innerRect.height)
            let fillHex: UInt = progress < 0.28 ? 0xE24A3B : 0x7FE9A8

            cgContext.setShadow(offset: .zero, blur: 10, color: UIColor.black.withAlphaComponent(0.65).cgColor)
            UIColor(hex: 0x1E1E1E, alpha: 0.88).setFill()
            UIBezierPath(roundedRect: outerRect, cornerRadius: 15).fill()

            UIColor.white.withAlphaComponent(0.78).setStroke()
            let stroke = UIBezierPath(roundedRect: outerRect.insetBy(dx: 1.5, dy: 1.5), cornerRadius: 13)
            stroke.lineWidth = 3
            stroke.stroke()

            UIColor(hex: fillHex, alpha: 0.92).setFill()
            UIBezierPath(roundedRect: fillRect, cornerRadius: 9).fill()

            let glossRect = CGRect(x: fillRect.minX, y: fillRect.minY, width: fillRect.width, height: 5)
            UIColor.white.withAlphaComponent(0.56).setFill()
            UIBezierPath(roundedRect: glossRect, cornerRadius: 4).fill()

            let label = "\(remainingSeconds)s"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .black),
                .foregroundColor: UIColor(hex: 0xFFF3D9),
                .strokeColor: UIColor.black,
                .strokeWidth: -3,
                .paragraphStyle: centeredParagraphStyle
            ]
            (label as NSString).draw(in: CGRect(x: 0, y: 15, width: size.width, height: 24), withAttributes: attributes)
        }
    }

    private static var centeredParagraphStyle: NSParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        return paragraph
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
