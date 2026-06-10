# Tiny Bistro Game

Tiny Bistro Game is an iOS restaurant simulation prototype inspired by classic social cooking games such as Cafe Mania. The current goal is not a full tycoon loop yet; it is a playable 3D room where a customer enters, sits, orders, the player cooks a recipe with a timer, and the dish is delivered.

## Direction

- Build as one Xcode iOS app target.
- Keep code organized by folders inside `TinyBistroGame/`, not by separate demo/core packages.
- Use SwiftUI for the app shell and HUD.
- Use SceneKit for the first 3D isometric room.
- Keep gameplay state independent from SceneKit nodes so the game can evolve without rewriting the rules.

## Why SceneKit First

SceneKit is the best starting point for this project because it gives us real 3D, orthographic cameras, lighting, hit testing, animation, and asset loading with low setup cost. Metal is powerful but too low-level for the first milestone. SpriteKit would be fast for 2D, but the desired room, camera, and characters fit better as simple 3D.

The visual target is an orthographic 3D room with an isometric-like camera: small grid, readable furniture, chunky placeholder characters, warm lighting, and simple animations. The game should feel like a tiny playable diorama before it becomes a larger cafe-management game.

## Proposed Source Layout

```text
TinyBistroGame/
  App/
    TinyBistroGameApp.swift
    ContentView.swift
  Game/
    BistroGame.swift
    BistroWorld.swift
    GameClock.swift
  Game/Models/
    GridPosition.swift
    Entity.swift
    Furniture.swift
    Recipe.swift
    Order.swift
  Game/Systems/
    CustomerSystem.swift
    CookingSystem.swift
    SeatingSystem.swift
    MovementSystem.swift
  Rendering/
    BistroSceneView.swift
    BistroSceneController.swift
    SceneBuilder.swift
    NodeFactory.swift
    Materials.swift
  UI/
    GameHUD.swift
    OrderTicketView.swift
    CookingTimerView.swift
  Assets.xcassets/
```

These are folder boundaries inside the app target. They are not separate frameworks.

## First Playable Milestone

1. Show a small 3D isometric room with floor tiles, one table, one chair, one stove/counter, one staff placeholder, and one entrance.
2. Spawn one customer and move them from the entrance to the table.
3. Seat the customer and create a single order.
4. Let the player tap the stove/counter to start cooking.
5. Show a visible timer in the HUD.
6. Let the player deliver the completed dish to the seated customer.
7. Customer leaves and the loop can repeat.

Out of scope for the first milestone: shop, decoration, social/network features, monetization, multiple recipes, saving, complex staff automation, and polished art.

## Useful Docs

- [Architecture](Docs/ARCHITECTURE.md)
- [Agent Instructions](AGENTS.md)
