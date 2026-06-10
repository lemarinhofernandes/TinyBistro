# Coding Guidelines

- Keep gameplay rules in `Game/` and keep SwiftUI and SceneKit as mirrors of `BistroWorld`.
- Prefer small, explicit state machines over broad manager objects.
- Route all status text through `BistroWorld.postEvent(_:)` and keep templates in `Core/EventStrings.swift`.
- Use `Core/` for reusable helpers such as `TimeUtils`, `GeometryUtils`, `CoreTypes`, and lightweight logging.
- Keep tap handling centralized through `SceneTapTarget` and `SceneNodeName`.
- Use `TimeInterval` for gameplay timing and clamp tick delta in one place.
- Avoid repeating `first(where:)` predicates when a small query helper on `BistroWorld` can name the intent.
- Keep new code ASCII-only unless the file already needs Unicode.
