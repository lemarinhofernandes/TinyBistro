# Bistro Camp Effects

## Current Effects

- `BistroEffectsController` applies cooking glow to the stove while an order is cooking.
- Ready orders get green `READY` billboards on the counter and customer.
- Customers waiting for food get a billboarded patience timer above their head.
- Timeout anger feedback remains a one-shot billboard attached to the customer.

## SceneKit First

Prefer these before adding a full Metal overlay:

- `SCNMaterial.emission` for fake glow.
- Billboarded `SCNPlane` textures for readable UI-in-world.
- Small local `SCNLight` nodes for warmth.
- `SCNAction` pulses for campy motion.
- Shader modifiers for fresnel or rim light.

## Shader Modifier Stub

```swift
enum BistroCampGlowShader {
    static let surface = """
    #pragma arguments
    float glowIntensity;

    #pragma body
    float fresnel = pow(1.0 - dot(_surface.normal, _surface.view), 2.0);
    _surface.emission.rgb += vec3(0.50, 0.91, 0.66) * fresnel * glowIntensity;
    """
}
```

## Metal Path

A future Metal pass should be isolated behind an effects controller and have a SceneKit fallback.

Good candidates:

- Full-screen bloom/shine only on ready states.
- Heat shimmer above the stove while cooking.
- Pixel-sparkle overlay for session success.

Avoid using Metal for ordinary HUD controls; SwiftUI is enough for the camp 2.5D panels.
