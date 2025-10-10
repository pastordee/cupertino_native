# CNToolbar

A native iOS and macOS floating toolbar component with blur effect and rounded corners, matching Apple's design language. Perfect for displaying action buttons at the top or bottom of your screen with a translucent, glassy appearance.

<img src="misc/screenshots/toolbar.png" width="300">

## Features

- ✨ Native UIKit (iOS) and AppKit (macOS) implementation
- 🎨 Automatic system blur effect (light/dark mode aware)
- 🔄 Rounded corners (14pt radius) for floating appearance
- 📍 Position at top or bottom of screen
- 🎯 Multiple alignment options (leading, center, trailing, space-between, etc.)
- 🎭 SF Symbol icons with optional labels
- 🎨 Customizable tint color
- 📱 Safe area aware with proper padding
- ♿️ **Apple HIG compliant** - 44pt minimum touch targets (iOS), 36pt (macOS)

## Basic Usage

```dart
import 'package:cupertino_native/cupertino_native.dart';

CNToolbar(
  actions: [
    CNToolbarAction(
      icon: CNSymbol('square.and.arrow.up'),
      label: 'Share',
      onPressed: () => print('Share tapped'),
    ),
    CNToolbarAction(
      icon: CNSymbol('heart'),
      label: 'Like',
      onPressed: () => print('Like tapped'),
    ),
    CNToolbarAction(
      icon: CNSymbol('bookmark'),
      label: 'Save',
      onPressed: () => print('Save tapped'),
    ),
  ],
)
```

## Position Control

Place the toolbar at the top or bottom of your screen:

```dart
// Bottom toolbar (default - like in reference images)
CNToolbar(
  position: CNToolbarPosition.bottom,
  actions: [...],
)

// Top toolbar
CNToolbar(
  position: CNToolbarPosition.top,
  actions: [...],
)
```

## Alignment Options

Control how actions are distributed within the toolbar:

```dart
// Center alignment (default)
CNToolbar(
  alignment: CNToolbarAlignment.center,
  actions: [...],
)

// Leading (left) alignment
CNToolbar(
  alignment: CNToolbarAlignment.leading,
  actions: [...],
)

// Trailing (right) alignment
CNToolbar(
  alignment: CNToolbarAlignment.trailing,
  actions: [...],
)

// Space between actions
CNToolbar(
  alignment: CNToolbarAlignment.spaceBetween,
  actions: [...],
)

// Space evenly
CNToolbar(
  alignment: CNToolbarAlignment.spaceEvenly,
  actions: [...],
)

// Space around
CNToolbar(
  alignment: CNToolbarAlignment.spaceAround,
  actions: [...],
)
```

## Custom Tint Color

Customize the color of icons and text:

```dart
CNToolbar(
  tint: const Color(0xFF667EEA), // Custom purple-blue
  actions: [...],
)
```

## Action Configuration

Actions can have icons, labels, or both:

```dart
// Icon with label
CNToolbarAction(
  icon: CNSymbol('square.and.arrow.up'),
  label: 'Share',
  onPressed: () => handleShare(),
)

// Icon only
CNToolbarAction(
  icon: CNSymbol('heart'),
  onPressed: () => handleLike(),
)

// Label only
CNToolbarAction(
  label: 'More Options',
  onPressed: () => handleMore(),
)
```

## Usage with Stack

The toolbar is designed to float over content using a `Stack`:

```dart
Stack(
  children: [
    // Your main content
    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: YourContent(),
    ),
    
    // Floating toolbar at bottom
    Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: CNToolbar(
          actions: [
            CNToolbarAction(
              icon: CNSymbol('square.and.arrow.up'),
              label: 'Share',
              onPressed: () => handleShare(),
            ),
            CNToolbarAction(
              icon: CNSymbol('heart'),
              label: 'Like',
              onPressed: () => handleLike(),
            ),
          ],
        ),
      ),
    ),
  ],
)
```

## API Reference

### CNToolbar

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `actions` | `List<CNToolbarAction>` | `[]` | List of action buttons to display |
| `position` | `CNToolbarPosition` | `.bottom` | Position of toolbar (top or bottom) |
| `alignment` | `CNToolbarAlignment` | `.center` | How actions are aligned/distributed |
| `tint` | `Color?` | System blue | Color for icons and text |
| `height` | `double` | `56` | Height of the toolbar |

### CNToolbarAction

| Property | Type | Description |
|----------|------|-------------|
| `icon` | `CNSymbol?` | SF Symbol icon for the action |
| `label` | `String?` | Text label for the action |
| `onPressed` | `VoidCallback` | Callback when action is tapped |

### CNToolbarPosition

- `CNToolbarPosition.top` - Display toolbar at top of screen
- `CNToolbarPosition.bottom` - Display toolbar at bottom of screen (default)

### CNToolbarAlignment

- `CNToolbarAlignment.leading` - Align actions to the left
- `CNToolbarAlignment.center` - Center actions (default)
- `CNToolbarAlignment.trailing` - Align actions to the right
- `CNToolbarAlignment.spaceBetween` - Equal space between actions
- `CNToolbarAlignment.spaceEvenly` - Equal space including edges
- `CNToolbarAlignment.spaceAround` - Equal space around each action

## Design Guidelines

### Visual Style
- The toolbar uses native blur effects (.systemMaterial on iOS, .headerView on macOS)
- Rounded corners (14pt) create a floating, card-like appearance
- 16pt horizontal padding and 12pt vertical padding inside the blur container
- 12pt padding from screen edges (top or bottom based on position)

### Best Practices
- Use 3-5 actions for optimal usability
- Prefer icons with labels for clarity
- Use SF Symbols for consistent iconography
- Place toolbar in SafeArea to avoid notches/home indicators
- Consider using Positioned widget for proper floating layout

### Accessibility
- Labels provide context for screen readers
- Icon + label combination is recommended
- Adequate spacing between actions (12pt) for easy tapping
- **Apple HIG compliant**: Minimum 44pt touch targets on iOS, 36pt on macOS
- Icon-only buttons automatically sized to meet minimum width requirements

## Platform Differences

### iOS
- Uses `UIVisualEffectView` with `UIBlurEffect.Style.systemMaterial`
- Actions use `UIButton` with system font
- Automatically adapts blur to light/dark mode
- **44pt minimum** touch target height (Apple HIG standard)
- **44pt minimum** width for icon-only buttons

### macOS
- Uses `NSVisualEffectView` with `.headerView` material
- Actions use `NSButton` with system font
- Blur effect includes vibrancy for better integration
- **36pt minimum** touch target size (comfortable for mouse/trackpad)

### Fallback (Web/Linux/Windows)
- Renders as a Container with semi-transparent white/black background
- Uses Flutter buttons for actions
- Maintains consistent layout and behavior

## Related Components

- **CNNavigationBar** - Traditional top navigation bar (edge-to-edge)
- **CNTabBar** - Bottom tab bar for app-level navigation
- **CNButton** - Native button component

## Examples

See the [demo page](example/lib/demos/toolbar.dart) for a complete interactive example with position and alignment controls.
