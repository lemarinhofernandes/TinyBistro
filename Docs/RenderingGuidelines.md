# Rendering Guidelines

- SceneKit is a mirror of gameplay state, not the source of truth.
- Use `SceneCoordinates` for grid-to-world placement and keep the origin centered.
- Use `SceneNodeName` for all node naming so taps can be routed back to gameplay reliably.
- Keep recurring node patterns in a small rendering core, such as `SceneBillboardFactory`.
- Prefer cached `SCNMaterial` instances in `Rendering/Materials.swift` when the same look is reused.
- Keep visual feedback nodes small, named, and easy to remove when state changes.
- Use `SCNBillboardConstraint` for HUD-like world-space badges and timers.
- Document any new geometry offsets or world-space constants near the builder that uses them.
