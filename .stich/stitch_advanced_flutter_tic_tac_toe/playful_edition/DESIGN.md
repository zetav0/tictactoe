---
name: Playful Edition
colors:
  surface: '#121414'
  surface-dim: '#121414'
  surface-bright: '#37393a'
  surface-container-lowest: '#0c0f0f'
  surface-container-low: '#1a1c1c'
  surface-container: '#1e2020'
  surface-container-high: '#282a2b'
  surface-container-highest: '#333535'
  on-surface: '#e2e2e2'
  on-surface-variant: '#c3c6d7'
  inverse-surface: '#e2e2e2'
  inverse-on-surface: '#2f3131'
  outline: '#8d90a0'
  outline-variant: '#434655'
  surface-tint: '#b4c5ff'
  primary: '#b4c5ff'
  on-primary: '#002a78'
  primary-container: '#2b65ec'
  on-primary-container: '#f2f2ff'
  inverse-primary: '#0553da'
  secondary: '#ffba38'
  on-secondary: '#432c00'
  secondary-container: '#db9900'
  on-secondary-container: '#513600'
  tertiary: '#5edda0'
  on-tertiary: '#003822'
  tertiary-container: '#007f53'
  on-tertiary-container: '#cbffdf'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003da9'
  secondary-fixed: '#ffdeac'
  secondary-fixed-dim: '#ffba38'
  on-secondary-fixed: '#281900'
  on-secondary-fixed-variant: '#604100'
  tertiary-fixed: '#7cfabb'
  tertiary-fixed-dim: '#5edda0'
  on-tertiary-fixed: '#002112'
  on-tertiary-fixed-variant: '#005234'
  background: '#121414'
  on-background: '#e2e2e2'
  surface-variant: '#333535'
typography:
  display-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '800'
    lineHeight: 36px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  gutter: 16px
  margin-mobile: 24px
  margin-desktop: 40px
  stack-gap: 12px
---

## Brand & Style

This design system is built on an **Energetic & Playful** narrative, specifically optimized for the "Playful Edition" game suite. The visual identity draws heavy inspiration from mobile puzzle aesthetics, utilizing a "Squishy-Tactile" style that combines vibrant saturation with physical metaphors. 

The goal is to evoke joy, excitement, and a sense of reward. The UI is not just a functional layer but an interactive toy, characterized by:
- **Toy-like Physicality:** Elements appear to have volume, using inner glows and drop shadows to simulate depth.
- **High-Sensation Feedback:** Every interaction should feel heavy and satisfying, as if pressing a physical rubber button.
- **Friendly Geometry:** Elimination of sharp corners in favor of hyper-rounded, "bubbly" forms.

## Colors

The palette is anchored by a deep, vibrant **Royal Blue (#2B65EC)** background, which serves as the canvas for high-contrast "Action Colors." 

- **Primary Canvas:** The background should utilize the primary blue, often with a subtle radial gradient to create a sense of focal depth.
- **Action Yellow (#FFB82E):** Reserved for the "Primary Action" or "Adventure" paths.
- **Success Green (#53D397):** Used for "Classic" modes or positive progression states.
- **Vibrant Magenta (#D444BD):** Used for secondary menus, "More Games," or celebratory highlights.
- **Neutral White (#FFFFFF):** Used for card surfaces and primary text on dark backgrounds, maintaining a clean contrast against the saturated environment.

## Typography

While the brand logo utilizes custom expressive lettering, the UI relies on **Plus Jakarta Sans** for its balanced, rounded terminals that complement the soft UI shapes. 

- **Weight Strategy:** Use Bold (700) and ExtraBold (800) for almost all UI elements to maintain the "chunky" game aesthetic.
- **Hierarchy:** High-level headers should use `display-xl` with a white fill and a subtle dark blue drop shadow (2px offset) to separate text from the vibrant background.
- **Readability:** Body text on white cards should remain `body-lg` at 600 weight to ensure clarity amidst the visual noise of the colors.

## Layout & Spacing

The layout follows a **Fluid Centralized** model, where content is often stacked vertically to accommodate one-handed mobile play. 

- **Grid System:** On mobile, use a single-column layout with 24px side margins. On tablet/desktop, keep the content container max-width at 600px to maintain the "vertical game" feel.
- **Rhythm:** Elements are spaced using a tight 8px base grid. Interactive blocks (buttons) should have a `stack-gap` of 12px to 16px to ensure distinct "tap zones."
- **Safe Areas:** Ensure a 48px bottom margin to clear device navigation gestures, keeping the "More Games" and primary actions easily reachable.

## Elevation & Depth

This design system rejects flat design in favor of **Soft 3D Volume**. Depth is communicated through:

- **Bevel Effects:** Interactive elements use a 4px bottom "lip" (a darker shade of the element's color) to simulate a physical button height.
- **Top Highlights:** A very subtle, semi-transparent white inner glow at the top edge of buttons creates a "glossy" plastic finish.
- **Ambient Playful Shadows:** Drop shadows are never black; they are deep, saturated versions of the background color (e.g., a dark navy shadow on the blue background) with 15-20% opacity and 10px blur.
- **Layering:** White surface cards sit "below" the primary action buttons in the hierarchy but "above" the background through the use of soft, wide-spread shadows.

## Shapes

The shape language is dominated by **Hyper-Rounded Corners**. 

- **Base Corner Radius:** Standard buttons and cards use a 1rem (16px) radius to ensure they feel soft and approachable.
- **Container Radius:** Larger informational panels or "Daily Victory" cards should use `rounded-xl` (1.5rem/24px) to emphasize the "block" aesthetic of the game.
- **Icon Treatment:** Icons should be enclosed in circular or highly rounded square containers with matching 3D bevels.

## Components

### Buttons
The core interaction component. Must include:
- **3D Lip:** A 4px solid bottom border in a darker shade of the button color.
- **Iconography:** Large, white glyphs on the left side of the button text.
- **Active State:** On press, the button should shift 2px downward and the bottom lip should decrease, simulating a physical press.

### Cards & Panels
Used for stats and secondary info. 
- **Header Strip:** A slightly darker top section (e.g., light lavender on a white card) to house the title.
- **Container:** High roundedness (24px) with a soft 1px stroke in a light grey-blue to define the edge.

### Chips & Badges
- **Notification Dots:** Bright red (#FF4B4B) circles placed on the top-right corner of buttons or icons to indicate new content.
- **Status Chips:** Pill-shaped with high-contrast fills for "WIN" or "NEW" labels.

### Input Fields
- Avoid standard thin-line inputs. Use thick, rounded-pill containers with a subtle inner shadow to make the input feel "recessed" into the UI.