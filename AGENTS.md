# Agent Notes

This project is a fresh Xcode-only rewrite of the earlier `../TinyBistro` prototype. Keep the useful ideas, but do not recreate the old `Sources/TinyBistroCore` and `Sources/TinyBistroDemo` split.

## Project Goal

Build a small playable iOS restaurant sim prototype inspired by Cafe Mania.

First milestone:

- One simple 3D isometric room.
- One staff/player placeholder.
- Customers enter, sit, order, wait, eat, and leave.
- Player cooks a recipe with a timer and delivers it.
- No shop, decoration system, network/social features, monetization, or broad progression yet.

## Architecture Rules

- Keep this as a single Xcode app target.
- Organize source files by folder inside `TinyBistroGame/`.
- Gameplay state lives in pure Swift under `Game/`.
- SceneKit rendering lives under `Rendering/`.
- SwiftUI app shell and HUD live under `App/` and `UI/`.
- SceneKit nodes mirror `BistroWorld`; they are not the source of truth.
- Do not put gameplay rules inside SwiftUI views or SceneKit node subclasses.
- Prefer small value types and explicit state machines over broad manager objects.

## Rendering Direction

Use SceneKit first.

- Orthographic camera with isometric-like angle.
- Simple 3D placeholder geometry before asset polish.
- Stable node IDs so the renderer can update positions without rebuilding the whole scene every tick.
- Use SceneKit hit testing for taps and route results to `BistroGame` commands.

Avoid custom Metal rendering until gameplay proves the need.

## Implementation Notes

- Before adding code files, check whether Xcode's project file needs manual membership updates.
- Prefer Swift's `@Observable` or `ObservableObject` consistently with the app's deployment target and existing style.
- Use `TimeInterval` for timers and keep ticking centralized in `BistroGame`.
- Keep public command methods narrow: `startCooking`, `deliver`, `tapTile`, `tapFurniture`, `tick`.
- Add tests around pure gameplay systems when they are introduced.

## Useful Previous Prototype

The old project in `../TinyBistro` contains:

- `README.md` with the original checkpoint.
- `Docs/ARCHITECTURE.md` with the first architecture notes.
- A very simple SceneKit tiled floor and placeholder staff/customer.

Use it as reference only. Do not copy the old package-style folder structure into this project.
