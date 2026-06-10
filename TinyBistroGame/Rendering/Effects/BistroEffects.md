# Bistro Effects

This folder is the extension point for lightweight 3D/Metal effects. Effects must stay rendering-only: they can read presentation state derived from `BistroWorld`, but they should not own or mutate gameplay rules.

## Recommended First Effects

- Ready glow: a subtle green-gold pulse on a ready dish, stove, or counter.
- Timeout pop: SceneKit billboard particles or planes near the customer.
- Cooking warmth: small amber emission increase on the stove while cooking.

## Current Implementation

`BistroEffectsController` is the rendering-only coordination point for these effects.

- While any order is `cooking`, the stove receives an amber pulsing burner glow plus a small local light.
- While an order is `ready`, the counter and matching customer receive a billboarded `READY` badge with green glass glow.
- Timeout feedback remains a one-shot customer-attached billboard created by `BistroSceneController`.

The controller reads `BistroWorld` and existing SceneKit nodes, but it does not mutate gameplay state.

## Cost Guidelines

- Prefer `SCNMaterial` emission, transparency, and shader modifiers before adding Metal.
- Use `SCNTechnique` for a narrow post-process only if material-level effects are insufficient.
- Use `MTKView` overlays only for isolated effects that cannot be expressed cleanly in SceneKit.
- Always provide a no-Metal fallback using SceneKit materials or nodes.

## SceneKit Shader Modifier Stub

The following is intentionally not wired into gameplay yet. It shows the shape of a small fresnel/glow modifier that could be applied to a ready-dish material.

```swift
enum BistroReadyGlowEffect {
    static let surfaceShader = """
    #pragma arguments
    float glowIntensity;

    #pragma body
    float fresnel = pow(1.0 - dot(_surface.normal, _surface.view), 2.0);
    _surface.emission.rgb += vec3(0.62, 0.78, 0.65) * fresnel * glowIntensity;
    """

    static func apply(to material: SCNMaterial, intensity: CGFloat = 0.45) {
        material.shaderModifiers = [.surface: surfaceShader]
        material.setValue(intensity, forKey: "glowIntensity")
    }
}
```

## Integration Notes

- Keep effect triggers in rendering controllers, such as `BistroSceneController`, by observing state changes already present in `BistroWorld`.
- Do not add command methods or gameplay timers for visual-only effects.
- If Metal is introduced later, isolate it behind an `EffectsController` with a SceneKit fallback.
