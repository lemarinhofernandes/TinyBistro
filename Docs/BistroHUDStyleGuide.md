# Bistro HUD Style Guide

## Visual Direction

Tiny Bistro uses a warm "2000s cafe" interface: polished wood, brass/copper controls, cream paper, translucent green glass, chunky rounded type, soft gloss, and clear iconography.

The HUD should feel playful and legible, but still compact enough for a game screen. Gameplay state stays in `Game/`; SwiftUI only formats and presents `BistroWorld`.

## Palette

| Token | Hex | Usage |
| --- | --- | --- |
| Wood | `#8C5A3C` | Main ticket panels, wood surfaces |
| Deep Wood | `#5D3827` | Panel depth, button bottoms |
| Copper | `#C47E3A` | Buttons, accents, brass trim |
| Brass | `#D6A14A` | Score panel highlights |
| Cream | `#F3E7D0` | Bottom status strip, readable surfaces |
| Glass Green | `#9EC6A6` | Ready state, glass counters |
| Tomato | `#E24A3B` | Timeout, lost guests, danger feedback |
| Slate | `#34495E` | Idle/created status, staff material |
| Graphite | `#2C2C2C` | Text on light panels |
| Off White | `#FBF7F1` | Text on dark panels |

## Typography

- Titles: SF Rounded Heavy/Bold via `.system(..., design: .rounded)`.
- HUD labels: rounded bold, short and scannable.
- Body/status copy: system regular or rounded semibold when inside compact panels.
- Numbers and timers: monospaced system design for stable widths.

## Components

- `BistroPanel`: base 2.5D surface with gradient, gloss, border, and shadow.
- `BistroBadge`: compact status chip with a high-contrast icon and outline.
- `BistroButton`: large command button for cooking and delivery actions.
- `BistroTicketView`: active order card with recipe icon, status, progress, and timer.
- `BistroScoreView`: session progress, target, and lost-guest badge.
- `BistroStatusBar`: bottom event/status strip keyed by `lastEventID`.

## Layout

- Top left: active ticket.
- Top right: score/goal panel.
- Bottom left: current event/status message.
- Bottom right: contextual command buttons.
- Use 4 pt grid spacing; prefer 8, 12, 16, and 20 pt.

## Feedback

- Use amber for cooking, glass green for ready, tomato for loss/timeout.
- Animate status changes with scale/opacity around 200-250 ms.
- Keep `statusMessage` changes event-driven through `BistroWorld.postEvent(_:)`.

## Accessibility

- Preserve AA contrast between dark wood panels and off-white text.
- Keep important labels within Dynamic Type-friendly SwiftUI text.
- Do not rely on color alone: status badges also use icons and text.
