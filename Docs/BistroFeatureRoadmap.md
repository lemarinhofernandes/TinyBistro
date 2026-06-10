# Bistro Feature Roadmap

This roadmap keeps Cafe Mania-style features modular. Each item should land as models, systems, HUD presentation, then tuning/tests.

## Staff

- Current MVP: `idle`, `moving`, `cooking`, `carryingDish`, `delivering`.
- Next attributes: walk speed, cooking speed, hand slots, fatigue.
- Hiring: add staff candidates, cost, and max active staff.
- Upgrades: speed boosts and multi-dish carrying.
- Rule to preserve: one dish per staff hand slot.

## Customers

- Current flow: enter, sit, order, wait, eat, leave.
- Current penalty: waiting timeout increments `lostCustomers`.
- Next attributes: mood, patience, tip chance, favorite recipe.
- Future events: happy hour, impatient rush, VIP guests.

## Stations

- Current station: one stove.
- Next model: station slots with capacity and upgrade level.
- Future stations: grill, drink counter, dessert station.
- Upgrade axes: cook speed, slot count, burn tolerance.

## Buying And Inventory

- Ingredients: stock count and recipe consumption.
- Furniture: tables, chairs, counters, decorations.
- Expansion: unlockable floor space and placement grid.
- Shop UI: categories first, prices later.

## Economy

- Add soft currency: `coins`.
- Recipe value: reward per completed dish.
- Costs: ingredients, furniture, hiring, upgrades.
- Session report: earned coins, lost customers, best streak.

## Progression

- Current session goal: `servedCustomers / targetServed`.
- Next: stars by performance.
- Unlocks: recipes, stations, furniture, staff slots.
- Later: cafe level, reputation, cosmetic themes.

## Implementation Cadence

1. Add pure Swift models.
2. Add system rules and tests.
3. Expose minimal world state.
4. Present in HUD/SceneKit.
5. Tune durations, values, and feedback.

Keep public command APIs narrow and avoid moving rules into SwiftUI or SceneKit.
