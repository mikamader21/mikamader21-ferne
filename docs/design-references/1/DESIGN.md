---
name: Cinematic Radiance
colors:
  surface: '#fff8f7'
  surface-dim: '#dfd9d8'
  surface-bright: '#fff8f7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f9f2f1'
  surface-container: '#f3eceb'
  surface-container-high: '#ede7e6'
  surface-container-highest: '#e8e1e0'
  on-surface: '#1d1b1b'
  on-surface-variant: '#574146'
  inverse-surface: '#33302f'
  inverse-on-surface: '#f6efee'
  outline: '#8a7076'
  outline-variant: '#debfc5'
  surface-tint: '#ae275d'
  primary: '#ae275d'
  on-primary: '#ffffff'
  primary-container: '#f45f92'
  on-primary-container: '#5e002b'
  inverse-primary: '#ffb1c5'
  secondary: '#8e4b45'
  on-secondary: '#ffffff'
  secondary-container: '#fda89f'
  on-secondary-container: '#793b35'
  tertiary: '#7a5911'
  on-tertiary: '#ffffff'
  tertiary-container: '#b58e43'
  on-tertiary-container: '#3d2900'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9e1'
  primary-fixed-dim: '#ffb1c5'
  on-primary-fixed: '#3f001b'
  on-primary-fixed-variant: '#8d0545'
  secondary-fixed: '#ffdad6'
  secondary-fixed-dim: '#ffb4ab'
  on-secondary-fixed: '#3a0a08'
  on-secondary-fixed-variant: '#71352f'
  tertiary-fixed: '#ffdea7'
  tertiary-fixed-dim: '#ecc070'
  on-tertiary-fixed: '#271900'
  on-tertiary-fixed-variant: '#5e4200'
  background: '#fff8f7'
  on-background: '#1d1b1b'
  surface-variant: '#e8e1e0'
typography:
  display-lg:
    fontFamily: Libre Caslon Text
    fontSize: 64px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Libre Caslon Text
    fontSize: 40px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Libre Caslon Text
    fontSize: 32px
    fontWeight: '400'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-caps:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1.0'
    letterSpacing: 0.1em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1280px
  gutter: 24px
  margin-mobile: 20px
  margin-desktop: 64px
---

## Brand & Style
The design system embodies a cinematic, editorial aesthetic that transitions through the phases of a day. It is built on the concept of "Atmospheric Immersion," blending high-end fashion editorial layouts with dynamic, living backgrounds. The target audience values elegance, storytelling, and sensory depth.

The visual style is a fusion of **Glassmorphism** and **High-Contrast Editorial**. It utilizes layered transparencies, heavy backdrop blurs, and vibrant gradients to create a sense of three-dimensional space. The UI should feel like a viewfinder into a shifting landscape—warm, vibrant, and deeply emotive.

## Colors
The palette is anchored by **Ivory Rose (#FFF8F7)**, serving as a clean, warm canvas. Typography for titles must strictly use **Deep Plum (#3C102F)** to ensure editorial authority against vibrant backgrounds.

The system utilizes time-based dynamic themes:
- **Morning:** Dominated by Coral Pink and Ivory Rose; soft, waking energy.
- **Afternoon:** Saturated Peach and Gold; high-contrast, high-energy.
- **Night:** Deep Plum and Lavender; high-depth, glowing elements, and "moonlight" accents using Morning Gold.

Gradients should be applied to backgrounds and primary action buttons, never to body text. Use mesh gradients for large surface areas to mimic the scattering of light.

## Typography
The typographic scale establishes a clear hierarchy between "Story" and "Function." 

**Libre Caslon Text** is reserved for headings and display moments to evoke a literary, high-fashion feel. Use tight letter-spacing on larger sizes to maintain a "cinematic poster" density.

**Hanken Grotesk** handles all functional UI, navigation, and long-form body copy. It provides a sharp, contemporary counterpoint to the traditional serif. All labels should use the `label-caps` style to differentiate them from interactive text elements.

## Layout & Spacing
The design system employs a **Fluid Grid** with generous margins to mimic editorial white space. 

- **Desktop:** 12-column grid with 64px outer margins. Content blocks often overlap grid lines slightly to create a dynamic, non-rigid feel.
- **Mobile:** 4-column grid with 20px margins.
- **Rhythm:** Use an 8px base unit for all vertical spacing. Elements like cards and image containers should use 48px or 64px gaps to allow the background gradients to "breathe" through the layout.

## Elevation & Depth
Depth is created through "Luminous Layering" rather than traditional shadows.

1.  **Base Layer:** The dynamic time-based mesh gradient.
2.  **Middling Layer (Glass):** UI containers use `backdrop-filter: blur(20px)` and a white/ivory border at 10-20% opacity. This creates a frosted glass effect that inherits the color of the background.
3.  **Accent Layer (Glow):** Interactive elements (active buttons, chips) use soft, colored shadows that match the element's background color (e.g., a Coral Pink button has a Coral Pink shadow with 40% opacity and 20px blur).
4.  **Floating Elements:** Use "floating nubes" (soft, semi-transparent blurred circles) that drift slowly behind the UI to create a parallax sense of depth.

## Shapes
The shape language is organic but structured. Standard UI components use a 0.5rem (8px) radius to maintain professional alignment. However, "Feature Containers" (large imagery or highlight sections) should use `rounded-xl` (1.5rem/24px) to feel softer and more inviting. 

Interactive indicators, such as progress fills and selection pills, should utilize fully rounded (pill-shaped) ends to imply fluid motion.

## Components
- **Buttons:** Primary buttons use a linear gradient (Morning Gold to Coral Pink). On hover, they should "glow" by increasing shadow spread. Text remains Deep Plum or White depending on contrast.
- **Glass Cards:** Containers for content must have a 1px solid border (`rgba(255,255,255,0.2)`) and a background blur. No solid fills.
- **Progress Fills:** These must use "Elastic Motion." When a value changes, the fill should stretch slightly past the target and settle (back-out easing). Use a vibrant gradient for the fill.
- **Sparkling Destellos:** Use small, high-frequency "star" icons or CSS-generated glints that appear briefly on successful interactions or hover states of featured items.
- **Motion Standards:** 
    - **Floating Nubes:** Continuous slow translation (20-30s loops) with 5% opacity shifts.
    - **Page Transitions:** Soft cross-fades combined with a subtle upward slide (20px) of the serif typography.