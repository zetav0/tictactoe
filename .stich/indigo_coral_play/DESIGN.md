---
name: Indigo-Coral Play
colors:
  surface: '#fdf7ff'
  surface-dim: '#ded8e0'
  surface-bright: '#fdf7ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f8f2fa'
  surface-container: '#f2ecf4'
  surface-container-high: '#ece6ee'
  surface-container-highest: '#e6e0e9'
  on-surface: '#1d1b20'
  on-surface-variant: '#494551'
  inverse-surface: '#322f35'
  inverse-on-surface: '#f5eff7'
  outline: '#7a7582'
  outline-variant: '#cbc4d2'
  surface-tint: '#6750a4'
  primary: '#4f378a'
  on-primary: '#ffffff'
  primary-container: '#6750a4'
  on-primary-container: '#e0d2ff'
  inverse-primary: '#cfbcff'
  secondary: '#63597c'
  on-secondary: '#ffffff'
  secondary-container: '#e1d4fd'
  on-secondary-container: '#645a7d'
  tertiary: '#765b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#c9a74d'
  on-tertiary-container: '#503d00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#cfbcff'
  on-primary-fixed: '#22005d'
  on-primary-fixed-variant: '#4f378a'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#cdc0e9'
  on-secondary-fixed: '#1f1635'
  on-secondary-fixed-variant: '#4b4263'
  tertiary-fixed: '#ffdf93'
  tertiary-fixed-dim: '#e7c365'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#594400'
  background: '#fdf7ff'
  on-background: '#1d1b20'
  surface-variant: '#e6e0e9'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  title-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  grid-gutter: 12px
  screen-margin: 20px
---

## Brand & Style
The brand personality is energetic, modern, and competitive yet friendly. It targets a mobile-first audience that appreciates high-fidelity interactions and tactile feedback. The UI evokes a sense of "digital physicalness" through the use of Material Design 3 principles—specifically surface layering and meaningful motion.

The design style is **Modern Material with Glassmorphism touches**. It utilizes heavy roundedness to feel approachable and incorporates frosted glass effects on top-level overlays to maintain a sense of depth and context. The goal is to make a simple game feel like a premium, polished experience.

## Colors
The palette centers on a high-contrast pairing of **Indigo** and **Coral**. Indigo serves as the primary brand color and the "X" player's identity, while Coral represents the "O" player, ensuring clear visual distinction on the game board.

- **Primary (Indigo):** Used for main actions, brand elements, and Player X.
- **Secondary (Coral):** Used for accent details and Player O.
- **Surface Containers:** In light mode, use soft grays (Slate 50/100). In dark mode, use deep navy (Slate 900/950).
- **Status Colors:** Success (Green) is reserved for the winning line strike and victory screens. Warning (Amber) is used for draw states.

## Typography
This design system utilizes **Inter** for its neutral, highly legible, and systematic qualities. 

- **Display & Headlines:** Use tight letter-spacing and heavy weights (Bold/ExtraBold) to create a playful, "pop" aesthetic for scores and winner announcements.
- **Body & Labels:** Set in Medium or Regular weights for clarity. Labels use uppercase styling with slight letter spacing to differentiate from interactive text.
- **Mobile Scaling:** Headlines scale down by roughly 15% on mobile devices to ensure the game board remains the focal point without being crowded by text.

## Layout & Spacing
The layout follows a **Fluid Grid** model focused on a central square aspect ratio for the game board. 

- **The Board:** A 3x3 grid where each cell is separated by a 12px gutter.
- **Margins:** A standard 20px safe-area margin is maintained on the left and right of the screen.
- **Vertical Rhythm:** Elements are stacked using an 8px base unit. Larger 32px gaps are used to separate the header (scores), the game board, and the footer (controls).
- **Responsive Behavior:** On tablets, the game board is capped at a maximum width of 500px to prevent the grid from becoming overly sparse.

## Elevation & Depth
Depth is expressed through **Tonal Layers** and **Glassmorphism**.

1.  **Level 0 (Base):** The main background using the system surface color.
2.  **Level 1 (Cards/Board):** A slightly raised surface with a subtle 1px border-inner-glow.
3.  **Level 2 (Active Pieces):** X and O tokens use ambient shadows (8px blur, 10% opacity) to appear as if floating slightly above the grid.
4.  **Glassmorphism Overlays:** Game-over modals and pause menus use a backdrop-filter (blur: 12px) with a semi-transparent surface container (15% opacity) to maintain the visual state of the game in the background.

## Shapes
The shape language is consistently **Extra Rounded (2XL)**. 

- **Game Cells:** Use `rounded-lg` (16px) to create a soft, toy-like feel.
- **Buttons & Chips:** Use fully rounded (Pill) shapes for primary actions.
- **Cards & Modals:** Use `rounded-xl` (24px) for a modern, mobile-friendly appearance.
- **Game Pieces:** "X" should have rounded caps on its strokes, and "O" should be a perfect circle with a thick, soft stroke weight.

## Components

- **Game Board Cells:** Large, square interactive areas. Use a subtle inner-shadow when pressed to simulate a physical button being pushed down.
- **Action Buttons:** Elevated containers with a primary indigo fill. Use a "squishy" scale transform (scale: 0.95) on tap.
- **Player Score Chips:** Horizontal pill-shaped indicators. The active player's chip should glow with their respective color (Indigo or Coral).
- **Glass Modals:** Used for "Winner!" or "Draw" announcements. These should occupy 80% of the screen width with a heavy backdrop blur.
- **Success Indicators:** When a player wins, the winning three-in-a-row cells should pulse and the strike-through line should animate in using the Success Green.
- **Input Fields:** For player names, use a filled style with a bottom-only border that transforms into a full pill shape on focus.