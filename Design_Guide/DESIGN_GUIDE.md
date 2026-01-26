# 🎨 Comprehensive Design Guide
## Matte, Textured, Calm, Precise

This document serves as the "source of truth" for the N8N Mobile aesthetic. It is designed to ensure visual consistency across all future developments, prioritizing a skeuomorphic "matte" look over trendy glassmorphism.

---

## 1. Design Philosophy
Our system optimizes for **visual calm** and **tactile realism**.

- **Matte First**: All primary surfaces are matte. No glassmorphism, no transparency blurs, and no specular highlights.
- **Depth through Restraint**: Hierarchy is achieved through subtle value shifts (6-10%) and precise shadows.
- **Natural Texture**: A fine noise overlay is applied globally to prevent "digital deadness."

---

## 2. Technical Specifications

### Core Color Palette
| Token | Hex Code | Usage |
| :--- | :--- | :--- |
| `n8nPink` | `#EA4B71` | Primary Actions, Brand elements |
| `n8nPinkDark` | `#9E2A4D` | Gradient stop for actions |
| `n8nDark` | `#040506` | Scaffold background, Deepest voids |
| `n8nGrey` | `#1F1F1F` | Cards, Surface elements |
| `success` | `#4CAF50` | Status indicators |
| `error` | `#F44336` | Critical alerts |

### Gradients
Gradients are structural, not decorative. Use value differences of **6-10%**.

- **Primary Action**: `#EA4B71` → `#9E2A4D` (`topLeft` to `bottomRight`)
- **Dark Surface**: `#121212` → `#040506` (`topCenter` to `bottomCenter`)

---

## 3. Element Interactions & Skeuomorphism

### The Shadow System (3-Tiers)
Shadows suggest *separation*, not drama. Always color-tinted to the background.

| Tier | Radius/Offset | Opacity | Use Case |
| :--- | :--- | :--- | :--- |
| **0** | None | 0% | Background layer |
| **1** | 8.0 / (0, 4) | 12% (Dark) | Cards, Buttons, Inputs |
| **2** | 16.0 / (0, 8)| 15% (Dark) | Floating drawers, Modals |

### Interaction Feedback
Avoid high-contrast states or dramatic "glows."
- **Hover/Tap**: Shift the gradient values by 2-4% or increase shadow blur by 2px.
- **Active**: Slight scale down (98%) to imply physical compression.

---

## 4. Implementation Snippets (Flutter)

### Matte Container Pattern
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.n8nGrey,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Stack(
    children: [
      // Noise Texture Overlay (Optional but recommended)
      Opacity(
        opacity: 0.03,
        child: Image.asset('assets/images/noise.png', repeat: ImageRepeat.repeat),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    ],
  ),
)
```

### Skeuomorphic Action Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.n8nPink,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: const Text('Action'),
)
```

---

## 5. Noise & Texture
The **Noise Overlay** is the "secret weapon" that unifies gradients and breaks banding.
- **Grain**: Fine, monochromatic.
- **Strength**: Barely perceptible (3-5% opacity).
- **Application**: Applied globally to backgrounds or explicitly to matte cards.

---

## 6. What to Avoid
- 🚫 **Glassmorphism**: No `BackdropFilter` or semi-transparent blurs.
- 🚫 **High Contrast Outlines**: Use subtle value shifts instead of hard white borders.
- 🚫 **Vibrant Neons**: Stick to the muted, grounded palette.
- 🚫 **Theatrics**: No dramatic bounces or over-animated transitions.
