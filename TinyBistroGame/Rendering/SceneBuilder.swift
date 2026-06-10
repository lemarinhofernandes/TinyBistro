import SceneKit
import UIKit

enum SceneBuilder {
    static func buildBaseScene(world: BistroWorld) -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor(red: 0.10, green: 0.11, blue: 0.12, alpha: 1)

        let floor = SCNNode()
        floor.name = "floor"
        scene.rootNode.addChildNode(floor)

        for row in 0..<world.gridSize.rows {
            for column in 0..<world.gridSize.columns {
                let position = GridPosition(column: column, row: row)
                floor.addChildNode(
                    NodeFactory.tileNode(
                        position: position,
                        isDark: (column + row).isMultiple(of: 2),
                        world: world
                    )
                )
            }
        }

        addRoomEdges(to: scene, world: world)
        scene.rootNode.addChildNode(cameraNode(world: world))
        scene.rootNode.addChildNode(keyLightNode())
        scene.rootNode.addChildNode(ambientLightNode())
        return scene
    }

    private static func addRoomEdges(to scene: SCNScene, world: BistroWorld) {
        let width = CGFloat(world.gridSize.columns)
        let depth = CGFloat(world.gridSize.rows)

        let backWall = SCNBox(width: width, height: 0.70, length: 0.10, chamferRadius: 0)
        backWall.materials = [BistroMaterials.wall]
        let backNode = SCNNode(geometry: backWall)
        backNode.position = SCNVector3(0, 0.36, -Float(depth / 2))
        scene.rootNode.addChildNode(backNode)

        let leftWall = SCNBox(width: 0.10, height: 0.70, length: depth, chamferRadius: 0)
        leftWall.materials = [BistroMaterials.wall]
        let leftNode = SCNNode(geometry: leftWall)
        leftNode.position = SCNVector3(-Float(width / 2), 0.36, 0)
        scene.rootNode.addChildNode(leftNode)
    }

    private static func cameraNode(world: BistroWorld) -> SCNNode {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 9.2
        camera.zNear = 0.1
        camera.zFar = 100

        let node = SCNNode()
        node.name = "camera"
        node.camera = camera
        node.position = SCNVector3(5.7, 6.8, 7.4)
        node.eulerAngles = SCNVector3(-Float(GeometryUtils.radians(fromDegrees: 45)), Float(GeometryUtils.radians(fromDegrees: 45)), 0)
        return node
    }

    private static func keyLightNode() -> SCNNode {
        let light = SCNLight()
        light.type = .directional
        light.intensity = 900
        light.castsShadow = true
        light.shadowMode = .deferred

        let node = SCNNode()
        node.name = "key-light"
        node.light = light
        node.eulerAngles = SCNVector3(-Float(GeometryUtils.radians(fromDegrees: 60)), Float(GeometryUtils.radians(fromDegrees: 45)), 0)
        return node
    }

    private static func ambientLightNode() -> SCNNode {
        let light = SCNLight()
        light.type = .ambient
        light.intensity = 180
        light.color = UIColor(white: 1, alpha: 1)

        let node = SCNNode()
        node.name = "ambient-light"
        node.light = light
        return node
    }
}
