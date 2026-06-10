# Architecture

Tiny Bistro Game should stay simple enough to run from Xcode, but structured enough that gameplay, rendering, and UI do not collapse into one file.

## High-Level Shape

```text
SwiftUI App
  owns screen layout, HUD, buttons, overlays

BistroGame
  owns game state, player commands, and ticking

Systems
  transform game state over time

SceneKit Renderer
  mirrors game state into 3D nodes and routes taps back to commands
```

SceneKit nodes are presentation. `BistroWorld` is the source of truth.

## Folder Ownership

### App

Application entry point and top-level composition.

- Creates `BistroGame`.
- Shows the SceneKit view.
- Shows HUD and interaction overlays.

### Game

Pure Swift gameplay state and orchestration. This layer should not import SceneKit, SwiftUI, or UIKit.

Responsibilities:

- World grid and walkability.
- Entity identity and state.
- Customer lifecycle.
- Orders and recipe timers.
- Player commands such as `startCooking`, `deliverOrder`, and `selectTile`.
- Save/load models later.

### Game/Models

Small value types and enums.

Suggested models:

- `GridPosition`: integer tile coordinate.
- `GridSize`: map dimensions and bounds checks.
- `Entity`: staff/customer identity, role, position, state.
- `Furniture`: table, chair, stove, counter, entrance.
- `Recipe`: duration and output dish.
- `Order`: customer, recipe, status.

### Game/Systems

Focused gameplay rules. Systems receive world state and elapsed time, then mutate the world through clear APIs.

Initial systems:

- `CustomerSystem`: spawn, enter, wait, order, eat, leave.
- `SeatingSystem`: assign available chair/table.
- `CookingSystem`: run recipe timers and produce ready dishes.
- `MovementSystem`: move entities along paths.

Pathfinding can start as direct tile steps on a small grid, then become A* once furniture blocks movement.

### Rendering

SceneKit adapter layer.

Responsibilities:

- Build the room scene.
- Maintain an orthographic isometric camera.
- Convert `GridPosition` to `SCNVector3`.
- Create placeholder nodes for furniture and characters.
- Update node transforms when `BistroWorld` changes.
- Use SceneKit hit testing to translate taps into game commands.

Rendering should avoid rebuilding the whole scene every state change once interactions begin. Start with a simple builder if needed, then move to a `BistroSceneController` that owns stable nodes by entity/furniture ID.

### UI

SwiftUI HUD and overlays.

Responsibilities:

- Current order ticket.
- Cooking timer.
- Selected object information.
- Minimal action buttons when tapping stove/table/customer.

Keep this work-focused and compact. The first screen should be the game, not a landing page.

## Rendering Direction

Use SceneKit for the first playable version.

Camera:

- Orthographic projection.
- Rotated about 45 degrees around Y.
- Tilted down about 35-45 degrees.
- No free camera controls in the playable prototype unless debugging.

Art style:

- Low-poly/chunky placeholders.
- Warm restaurant palette, not a single-hue UI.
- Floor tiles readable from camera distance.
- Furniture with simple silhouettes: table, chair, stove, counter, entrance mat.

Why not Metal now:

- Metal is excellent for a custom renderer, shaders, and performance tuning, but it would slow down gameplay discovery.
- SceneKit can still use Metal underneath on Apple platforms.
- If the game later needs a custom look, we can replace only the rendering adapter while keeping `BistroWorld` and systems.

Why not GameKit:

- GameKit is mainly for Apple gaming services such as Game Center multiplayer, leaderboards, achievements, and matchmaking.
- It is not a rendering or gameplay engine for this first local prototype.

## First Milestone State Machine

Customer:

```text
spawning -> entering -> waitingForSeat -> seated -> ordering -> waitingForFood -> eating -> leaving -> finished
```

Order:

```text
created -> cooking -> ready -> delivered -> completed
```

Staff/player:

```text
idle -> moving -> cooking -> carryingDish -> delivering
```

For milestone one, staff can be mostly player-commanded and customer movement can be scripted.

## First Milestone Commands

Suggested `BistroGame` public API:

```swift
func tick(deltaTime: TimeInterval)
func tapTile(_ position: GridPosition)
func tapFurniture(id: Furniture.ID)
func startCooking(orderID: Order.ID)
func deliver(orderID: Order.ID)
```

The renderer and HUD call commands. They should not mutate world arrays directly.

## Testing Strategy

Start with focused unit tests for pure gameplay once the first systems exist.

Good early tests:

- Customer reaches seated state when a table is available.
- Customer leaves when no table is available after a timeout.
- Cooking timer does not complete early.
- Ready dish can only be delivered to the matching customer/order.
- Furniture occupancy prevents two customers from sitting at the same chair.

SceneKit visual behavior should be verified manually at first, then with screenshot checks if the project gains automated UI tests.
