import SceneKit
import SwiftUI
import UIKit

struct BistroSceneView: UIViewRepresentable {
    var world: BistroWorld
    var onTapTarget: (SceneTapTarget) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(world: world, onTapTarget: onTapTarget)
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = context.coordinator.controller.scene
        view.backgroundColor = .black
        view.autoenablesDefaultLighting = false
        view.allowsCameraControl = false
        view.antialiasingMode = .multisampling4X
        view.preferredFramesPerSecond = 60

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        view.addGestureRecognizer(pinchGesture)
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        context.coordinator.onTapTarget = onTapTarget
        context.coordinator.controller.sync(to: world)
    }

    final class Coordinator: NSObject {
        let controller: BistroSceneController
        var onTapTarget: (SceneTapTarget) -> Void

        init(world: BistroWorld, onTapTarget: @escaping (SceneTapTarget) -> Void) {
            self.controller = BistroSceneController(world: world)
            self.onTapTarget = onTapTarget
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let view = recognizer.view as? SCNView else {
                return
            }

            let location = recognizer.location(in: view)
            let hitResults = view.hitTest(location, options: [
                SCNHitTestOption.searchMode: SCNHitTestSearchMode.closest.rawValue
            ])

            guard let target = SceneNodeName.target(from: hitResults.first?.node) else {
                return
            }

            onTapTarget(target)
        }

        @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
            guard let view = recognizer.view else {
                return
            }

            let translation = recognizer.translation(in: view)
            controller.panCamera(by: translation, in: view.bounds.size)
            recognizer.setTranslation(.zero, in: view)
        }

        @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
            controller.zoomCamera(by: recognizer.scale)
            recognizer.scale = 1
        }
    }
}
