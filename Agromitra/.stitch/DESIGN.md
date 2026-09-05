# AgroMitra Design System Tokens & Style Guide

## 1. Color Palette
- **Primary Color:** `#2E7D32` (Deep Forest Green - trust, agriculture, growth)
- **Primary Dark:** `#1B5E20`
- **Primary Light / Container:** `#E8F5E9` (Soft Mint Tint)
- **Secondary Color:** `#66BB6A` (Fresh Leaf Green)
- **Accent / Highlight:** `#F9A825` (Golden Harvest Yellow)
- **Accent Light:** `#FFF8E1` (Warm Honey Container)
- **Background:** `#F8FAF8` (Ultra-soft White / Natural Off-White)
- **Surface / Card Background:** `#FFFFFF` (Pure White with subtle border/shadow)
- **Text Primary:** `#1A2E1A` (Deep Forest Charcoal)
- **Text Secondary:** `#556B55` (Subtle Sage Green Grey)
- **Text Hint / Border:** `#D8E2DC`
- **Grade A Tag:** `#2E7D32` text with `#E8F5E9` background
- **Grade B Tag:** `#F57F17` text with `#FFF8E1` background
- **Grade C Tag:** `#C62828` text with `#FFEBEE` background

## 2. Typography
- **Heading 1:** 26px Bold, LetterSpacing: -0.5px
- **Heading 2:** 20px SemiBold, LetterSpacing: -0.2px
- **Heading 3 / Card Titles:** 16px SemiBold
- **Body Large:** 15px Regular / Medium
- **Body Medium:** 13px Regular
- **Caption / Badges:** 11px SemiBold, All-Caps or Title-Case
- **Price Metric:** 22-28px Bold with currency symbol

## 3. Shapes & Layout Elevation
- **Cards:** 18–22px rounded corners (`BorderRadius.circular(20)`)
- **Buttons:** Pill-shaped (`BorderRadius.circular(30)`)
- **Input Fields:** 16px rounded with smooth outline
- **Chips:** 12–16px rounded pill chips with selected elevation
- **Elevation:** Subtle soft diffuse shadows (`BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))`)

## 4. Interaction & Motion
- Smooth fade transitions between screens
- Hero animations for produce thumbnails
- Step indicators with progress animations in Sell Produce Flow
- Tactile feedback on button taps and card presses

## 5. Design System Notes for Stitch Generation
```css
--primary: #2E7D32;
--secondary: #66BB6A;
--accent: #F9A825;
--background: #F8FAF8;
--surface: #FFFFFF;
--text-primary: #1A2E1A;
--text-secondary: #556B55;
--border-radius-card: 20px;
--border-radius-pill: 30px;
--font-family: 'Poppins', 'Inter', -apple-system, sans-serif;
```
