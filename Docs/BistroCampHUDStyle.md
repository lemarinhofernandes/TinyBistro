# Bistro Camp HUD Style

## Direction

The camp HUD leans into early-2000s cafe game energy: shiny plastic buttons, loud gradients, heavy gloss, bevels, outlines, saturated warm color, and readable chunky type.

Gameplay still lives in `Game/`. SwiftUI formats state from `BistroWorld`; SceneKit mirrors world state and owns visual effects.

## Palette

| Token | Hex | Usage |
| --- | --- | --- |
| Varnish Orange | `#F59E42` | Main ticket, buy/cook buttons, warm surfaces |
| Tomato | `#E24A3B` | Customers, warning/lost states, decor accent |
| Neon Glass | `#7FE9A8` | Ready state, counter, success fills |
| Cobalt UI | `#2E86DE` | Score panel, staff, secondary buttons |
| Cream | `#FFF3D9` | Text fill, light panels |
| Graphite | `#1E1E1E` | Button dock, deep shadows, metal base |
| Lead | `#5C6A72` | Neutral controls, stove metal |
| Polished Steel | `#B6C2CC` | Future trims and disabled UI |

## Typography

- Display labels use `MarkerFelt-Wide` through `Font.custom` for a playful, campy feel without adding a font file.
- If a future `.ttf` is embedded, replace the font name in `BistroCampTheme.Fonts.camp`.
- Score/timer text uses monospaced digits so progress labels do not shift.
- High-impact text uses a faux outline via `CampOutlinedText`.

## UI Rules

- Use strong gloss on the top 25-35% of panels and buttons.
- Use double strokes: translucent white outside, dark inset stroke inside.
- Keep touch targets at least 44 pt high.
- Use saturated status color plus text/icon, never color alone.
- Main progress uses `Bistro3DProgressBar` with numbers in the center.

## HUD Composition

- Top: active ticket with recipe, badge, and 3D progress bar.
- Right: score panel with `served/target` and lost badge.
- Bottom: status bubble plus action dock.
- Action dock includes current gameplay commands and placeholder feature buttons: Buy, Staff, Items, Decor.

## Future Capture Notes

Add screenshots here after visual QA on simulator:

- Portrait iPhone
- Landscape iPhone
- Ready order glow
- Customer patience bar under timeout pressure
