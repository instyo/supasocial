---
name: Luminous Social
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#434655'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#5c5f61'
  on-secondary: '#ffffff'
  secondary-container: '#e0e3e5'
  on-secondary-container: '#626567'
  tertiary: '#943700'
  on-tertiary: '#ffffff'
  tertiary-container: '#bc4800'
  on-tertiary-container: '#ffede6'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#e0e3e5'
  secondary-fixed-dim: '#c4c7c9'
  on-secondary-fixed: '#191c1e'
  on-secondary-fixed-variant: '#444749'
  tertiary-fixed: '#ffdbcd'
  tertiary-fixed-dim: '#ffb596'
  on-tertiary-fixed: '#360f00'
  on-tertiary-fixed-variant: '#7d2d00'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 20px
  margin-mobile: 20px
  margin-desktop: auto
  max-width-content: 640px
---

## Brand & Style

The design system is centered on **Digital Minimalism**. It targets a user base that seeks a focused, calm social experience away from the traditional visual noise of algorithmic feeds. The UI prioritizes content—photography and thoughtful text—through an expansive use of whitespace and a high-end, gallery-like feel.

The aesthetic blends **Minimalism** with subtle **Glassmorphism** to create a sense of lightness and transparency. The emotional response should be one of clarity, breathability, and premium quality. Every element exists with a clear purpose, avoiding unnecessary decoration in favor of structural elegance and functional hierarchy.

## Colors

The palette is intentionally restricted to maintain a clean, airy atmosphere. 

*   **Primary (Electric Blue):** Used exclusively for high-priority calls to action, active states, and critical interaction points. It provides the "spark" in an otherwise neutral environment.
*   **Neutrals:** A range of soft grays (Slate) manages secondary text and borders, while pure whites define the primary canvas.
*   **Backgrounds:** Pure white is used for the main viewport to maximize "breathability." Soft grays are reserved for subtle grouping or surface differentiation.

## Typography

This design system utilizes **Inter** for its systematic, utilitarian, and highly legible qualities. 

The type hierarchy relies on significant scale contrasts rather than heavy weights. Headlines use a slight negative letter-spacing to appear more cohesive and "editorial." Body text is generously leaded to ensure comfortable reading of longer posts. All labels and secondary information utilize a medium weight and slightly increased tracking for clarity at smaller sizes.

## Layout & Spacing

The layout philosophy follows a **Fixed-Fluid Hybrid**. For the core social experience, content is contained within a centered max-width column (640px) to prevent line lengths from becoming illegible and to maintain a focused "feed" feel.

*   **Grid:** A 12-column grid is used for desktop dashboards, while mobile uses a single-column stack with 20px side margins.
*   **Spacing Rhythm:** A strict 8px base unit is used. However, "Macro-spacing" (40px+) is preferred between major sections to emphasize the minimal aesthetic.
*   **Negative Space:** Padding within cards and containers should be generous (minimum 24px) to ensure content never feels crowded.

## Elevation & Depth

Depth is conveyed through **Soft Ambient Shadows** rather than traditional borders.

1.  **Level 0 (Base):** Pure white background.
2.  **Level 1 (Cards/Containers):** Subtle, extra-diffused shadows (e.g., `0 4px 20px rgba(0,0,0,0.04)`). These surfaces should appear to float slightly above the base.
3.  **Level 2 (Modals/Overlays):** Increased shadow spread and the addition of a backdrop blur (12px) on the underlying content to create a glass-like focus effect.
4.  **Interactions:** On hover or tap, elements should slightly lift (increase shadow) or subtly scale (1.02x) rather than changing color significantly.

## Shapes

The shape language is friendly and approachable, utilizing **Rounded** corners across all UI components.

*   **Small Elements (Buttons, Inputs):** 12px (0.75rem) radius.
*   **Medium Elements (Cards, Modals):** 24px (1.5rem) radius to emphasize the modern, soft aesthetic.
*   **Large Elements (Avatars):** Fully circular (pill-shaped) to distinguish human elements from functional UI.

## Components

*   **Buttons:** Primary buttons are solid Electric Blue with white text. Secondary buttons use a soft gray surface with neutral text. All buttons feature 24px horizontal padding and 12px vertical padding.
*   **Cards:** Use a pure white fill with a Level 1 shadow. No borders. Content within cards (like post text) should have at least 24px of internal padding.
*   **Inputs:** Fields are defined by a light gray background (`#F1F5F9`) rather than an outline. On focus, they transition to a white background with a thin Electric Blue border.
*   **Avatars:** Always circular. Use a subtle 2px white border when placed on top of images or colored backgrounds.
*   **Chips/Tags:** Small, pill-shaped elements with a soft gray background and medium-weight labels.
*   **Icons:** Use 24px minimalist line icons (2px stroke width). Avoid filled icons unless they represent an active/selected state.
*   **Feed Item:** A combination of a circular avatar, "Label-MD" for usernames, and "Body-MD" for content, separated by 12px of vertical spacing.