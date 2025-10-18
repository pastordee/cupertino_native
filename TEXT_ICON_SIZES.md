# Text and Icon Size Controls

## Overview

Both `CNTabBarItem` and `CNToolbarAction` now support custom size parameters for fine-grained control over text and icon rendering.

## New Parameters

### CNTabBarItem

```dart
CNTabBarItem(
  label: 'Home',
  labelSize: 12.0,        // Font size for label text in points
  icon: CNSymbol('house.fill'),
  iconSize: 24.0,         // Icon size in points (overrides CNSymbol size)
  // ... other existing parameters
)
```

### CNToolbarAction

```dart
CNToolbarAction(
  label: 'Action',
  labelSize: 14.0,        // Font size for label text in points
  icon: CNSymbol('gear'),
  iconSize: 20.0,         // Icon size in points (overrides CNSymbol size)
  // ... other existing parameters
)
```

## Size Parameter Details

### Label Size (`labelSize`)

- **Type**: `double?` (optional)
- **Unit**: Points (logical pixels)
- **Default**: Platform default when `null`
- **Usage**: Controls the font size of text labels
- **Example Values**:
  - `10.0` - Small text
  - `12.0` - Caption size
  - `14.0` - Body text
  - `16.0` - Large text
  - `18.0` - Title size

### Icon Size (`iconSize`)

- **Type**: `double?` (optional)
- **Unit**: Points (logical pixels)
- **Default**: Uses icon's intrinsic size or platform default when `null`
- **Priority**: Overrides the size specified in `CNSymbol`
- **Example Values**:
  - `16.0` - Small icon
  - `20.0` - Standard icon
  - `24.0` - Medium icon
  - `28.0` - Large icon
  - `32.0` - Extra large icon

## Usage Examples

### Tab Bar with Progressive Sizes

```dart
CNTabBar(
  items: [
    CNTabBarItem(
      label: 'Small',
      icon: CNSymbol('house.fill'),
      labelSize: 10,
      iconSize: 16,
    ),
    CNTabBarItem(
      label: 'Medium',
      icon: CNSymbol('star.fill'),
      labelSize: 12,
      iconSize: 20,
    ),
    CNTabBarItem(
      label: 'Large',
      icon: CNSymbol('heart.fill'),
      labelSize: 14,
      iconSize: 24,
    ),
    CNTabBarItem(
      label: 'XLarge',
      icon: CNSymbol('gear'),
      labelSize: 16,
      iconSize: 28,
    ),
  ],
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
)
```

### Toolbar with Size Variations

```dart
CNToolbar(
  leading: [
    CNToolbarAction(
      label: 'Cancel',
      labelSize: 12,
      onPressed: () => Navigator.pop(context),
    ),
  ],
  middle: [
    CNToolbarAction(
      icon: CNSymbol('star.fill'),
      iconSize: 16,
      onPressed: () {},
    ),
    CNToolbarAction(
      label: 'Title',
      labelSize: 16,
      onPressed: () {},
    ),
    CNToolbarAction(
      icon: CNSymbol('heart.fill'),
      iconSize: 20,
      onPressed: () {},
    ),
  ],
  trailing: [
    CNToolbarAction(
      label: 'Done',
      labelSize: 14,
      onPressed: () {},
    ),
    CNToolbarAction(
      icon: CNSymbol('ellipsis'),
      iconSize: 18,
      onPressed: () {},
    ),
  ],
)
```

### Mixed Content Types

```dart
// Mixing text and icons with custom sizes
CNTabBar(
  items: [
    CNTabBarItem(
      label: 'Text Only',
      labelSize: 12,
      // No icon
    ),
    CNTabBarItem(
      icon: CNSymbol('gear'),
      iconSize: 24,
      // No label
    ),
    CNTabBarItem(
      label: 'Both',
      labelSize: 10,
      icon: CNSymbol('star.fill'),
      iconSize: 20,
    ),
  ],
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
)
```

## Size Priority and Fallbacks

### Icon Size Resolution Order

1. **`iconSize` parameter** (highest priority)
2. **CNSymbol.size** (if iconSize is null)
3. **Widget-level iconSize** (for CNTabBar only)
4. **Platform default** (lowest priority)

```dart
// Example showing priority
CNTabBarItem(
  icon: CNSymbol('star.fill', size: 30), // This will be overridden
  iconSize: 24,                          // This takes priority
)

CNTabBar(
  iconSize: 20,           // Default for all items
  items: [
    CNTabBarItem(
      icon: CNSymbol('house.fill'),
      // Uses iconSize: 20 from CNTabBar
    ),
    CNTabBarItem(
      icon: CNSymbol('star.fill', size: 25),
      // Uses size: 25 from CNSymbol (overrides CNTabBar default)
    ),
    CNTabBarItem(
      icon: CNSymbol('heart.fill', size: 30),
      iconSize: 18,
      // Uses iconSize: 18 (highest priority, overrides everything)
    ),
  ],
)
```

### Label Size Resolution

1. **`labelSize` parameter** (if specified)
2. **Platform default** (if labelSize is null)

## Design Guidelines

### Recommended Size Ranges

**Tab Bar Labels:**
- Small: 10-12 points
- Standard: 12-14 points
- Large: 14-16 points

**Tab Bar Icons:**
- Small: 16-20 points
- Standard: 20-24 points
- Large: 24-28 points

**Toolbar Labels:**
- Small: 12-14 points
- Standard: 14-16 points
- Large: 16-18 points

**Toolbar Icons:**
- Small: 16-18 points
- Standard: 18-22 points
- Large: 22-26 points

### Accessibility Considerations

- Respect user's accessibility settings
- Test with Dynamic Type enabled
- Ensure touch targets remain accessible (minimum 44pt)
- Maintain good contrast with custom sizes

### Platform Consistency

- iOS: Icons typically 20-28pt, labels 10-12pt for tab bars
- iOS: Icons typically 17-22pt, labels 16-17pt for toolbars
- macOS: Slightly larger sizes may be appropriate

## Implementation Notes

### Performance

- Size changes trigger native view updates
- Batch size changes when possible
- No performance impact during normal usage

### Hot Reload

- Size changes are properly synchronized during hot reload
- Changes to both individual items and widget-level defaults are supported

### Platform Differences

- Sizes are specified in logical pixels (points)
- Platform-specific scaling is handled automatically
- Different platforms may have slightly different rendering

## Migration Guide

### From Global Icon Size

**Before:**
```dart
CNTabBar(
  iconSize: 24,
  items: [
    CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
    CNTabBarItem(label: 'Search', icon: CNSymbol('magnifyingglass')),
  ],
)
```

**After (if you want individual control):**
```dart
CNTabBar(
  items: [
    CNTabBarItem(
      label: 'Home', 
      icon: CNSymbol('house.fill'),
      iconSize: 24,
    ),
    CNTabBarItem(
      label: 'Search', 
      icon: CNSymbol('magnifyingglass'),
      iconSize: 20, // Different size
    ),
  ],
)
```

### Adding Label Sizes

**Before:**
```dart
CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill'))
```

**After:**
```dart
CNTabBarItem(
  label: 'Home', 
  labelSize: 12,
  icon: CNSymbol('house.fill'),
  iconSize: 24,
)
```

## Troubleshooting

### Common Issues

1. **Text appears too small/large**
   - Check `labelSize` value
   - Ensure it's in logical points, not pixels
   - Test on different screen densities

2. **Icons don't match expected size**
   - Verify `iconSize` parameter
   - Check if CNSymbol has conflicting size
   - Remember iconSize overrides CNSymbol.size

3. **Inconsistent sizes across platforms**
   - Use explicit size values instead of relying on defaults
   - Test on both iOS and macOS if applicable

### Debugging

```dart
// Log current sizes for debugging
CNTabBarItem(
  label: 'Debug',
  labelSize: 12,
  icon: CNSymbol('gear'),
  iconSize: 20,
)
// Check native logs for size application
```

## Examples

See the updated demo files:
- `example/lib/demos/tab_bar.dart` - Tab bar with progressive sizes
- `example/lib/demos/toolbar.dart` - Toolbar with size variations

Both demos showcase different size combinations and usage patterns.