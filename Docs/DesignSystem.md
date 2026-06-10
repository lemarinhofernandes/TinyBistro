# Design System

- Use `BistroTheme` and `BistroCampTheme` for colors, typography, spacing, radii, and shadows.
- Keep HUD components in `UI/DesignSystem/` and reuse them instead of inlining repeated styling.
- Use button and badge components for interactive UI rather than re-creating the same gloss and outline effects.
- Keep text legible inside compact HUD panels with `lineLimit`, `minimumScaleFactor`, and consistent padding.
- Expose session progress and status through shared components such as the ticket, score pill, and status bubble.
- Prefer a single source for size tokens so panel widths, corner radii, and spacing stay consistent across screens.
- When adding new HUD chrome, match the established camp style rather than introducing a new palette ad hoc.
