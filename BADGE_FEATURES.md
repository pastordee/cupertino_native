# Tab Bar Badge Features

## Overview
Enhanced badge support for the CNTabBar component with automatic formatting and custom color options, following Apple's Human Interface Guidelines.

## Features Implemented

### 1. Automatic Badge Value Formatting
Badges now support both String and int values with automatic formatting:

```dart
CNTabBarItem(
  label: 'Messages',
  icon: CNSymbol('message.fill'),
  badgeValue: 5,        // Shows "5"
)

CNTabBarItem(
  label: 'Notifications',
  icon: CNSymbol('bell.fill'),
  badgeValue: 150,      // Automatically formatted as "99+"
)

CNTabBarItem(
  label: 'Alerts',
  icon: CNSymbol('exclamationmark.circle'),
  badgeValue: '!',      // Shows "!" for critical alerts
)
```

**Formatting Rules:**
- Numbers 1-99: Display as-is ("1", "5", "99")
- Numbers > 99: Display as "99+"
- Zero or negative: Badge hidden
- Strings: Display as-is
- Null or empty: Badge hidden

### 2. Custom Badge Colors
Badges now support custom background colors to convey different notification types:

```dart
CNTabBarItem(
  label: 'Critical',
  badgeValue: 5,
  badgeColor: CupertinoColors.systemRed,    // Default: Critical/urgent
)

CNTabBarItem(
  label: 'Info',
  badgeValue: 3,
  badgeColor: CupertinoColors.systemBlue,   // Informational
)

CNTabBarItem(
  label: 'Success',
  badgeValue: 2,
  badgeColor: CupertinoColors.systemGreen,  // Success/new content
)

CNTabBarItem(
  label: 'Warning',
  badgeValue: 1,
  badgeColor: CupertinoColors.systemOrange, // Warning/attention needed
)
```

**Recommended Color Usage:**
- **Red** (default): Critical notifications, errors, urgent actions
- **Blue**: Informational updates, messages
- **Green**: Success states, new content
- **Orange**: Warnings, items needing attention
- **Purple**: Special features, premium content

### 3. Apple HIG Compliance
- Badges use iOS native `UITabBarItem.badgeValue` and `badgeColor` properties
- Automatic text color (white) for optimal contrast
- Standard oval shape with system spacing
- Follows iOS accessibility guidelines

## API Reference

### CNTabBarItem Properties

```dart
class CNTabBarItem {
  /// Badge value to display on the tab.
  /// 
  /// Supports automatic formatting:
  /// - Numbers are formatted (e.g., 150 becomes "99+" if over 99)
  /// - Use "!" for critical alerts
  /// - Use empty string or null to hide the badge
  /// 
  /// Pass either a String or an int:
  /// ```dart
  /// badgeValue: '5'      // Shows "5"
  /// badgeValue: 150      // Shows "99+"
  /// badgeValue: '!'      // Shows "!" for alerts
  /// ```
  final dynamic badgeValue;

  /// Optional custom badge background color.
  /// If null, uses the system default red color for badges.
  /// 
  /// Examples:
  /// ```dart
  /// badgeColor: CupertinoColors.systemRed      // Default critical (red)
  /// badgeColor: CupertinoColors.systemBlue     // Informational (blue)
  /// badgeColor: CupertinoColors.systemGreen    // Success (green)
  /// badgeColor: CupertinoColors.systemOrange   // Warning (orange)
  /// ```
  final Color? badgeColor;
}
```

## Implementation Details

### Dart Side
- Added `formattedBadgeValue` getter to `CNTabBarItem` for automatic formatting
- Badge values sent to native as formatted strings
- Badge colors sent as ARGB integers via platform channel

### iOS Side (Swift)
- Badge values applied via `UITabBarItem.badgeValue`
- Badge colors applied via `UITabBarItem.badgeColor` (iOS 10+)
- Colors converted from ARGB integers using `colorFromARGB()` helper
- Full support in both single and split tab bar modes

## Usage Example

```dart
CNTabBar(
  items: const [
    CNTabBarItem(
      label: 'Home',
      icon: CNSymbol('house.fill'),
      // No badge
    ),
    CNTabBarItem(
      label: 'Messages',
      icon: CNSymbol('message.fill'),
      badgeValue: 5,
      badgeColor: CupertinoColors.systemRed, // Critical
    ),
    CNTabBarItem(
      label: 'Updates',
      icon: CNSymbol('arrow.down.circle'),
      badgeValue: 150, // Shows as "99+"
      badgeColor: CupertinoColors.systemBlue, // Informational
    ),
    CNTabBarItem(
      label: 'Alerts',
      icon: CNSymbol('exclamationmark.triangle'),
      badgeValue: '!',
      badgeColor: CupertinoColors.systemOrange, // Warning
    ),
  ],
  currentIndex: _index,
  onTap: (index) => setState(() => _index = index),
)
```

## Design Guidelines

Following Apple's Human Interface Guidelines:

1. **Reserve badges for critical information** - Don't overuse badges; they lose impact when shown on too many items
2. **Use numbers for counts** - Show notification counts (1-99, or "99+" for higher counts)
3. **Use "!" for critical alerts** - Reserve exclamation marks for truly urgent situations
4. **Choose colors meaningfully** - Use color psychology to convey urgency/type
5. **Keep text minimal** - Badges should show simple counts or symbols, not messages
6. **Update dynamically** - Badge values can change based on app state

## Testing

Test the demo app to see all badge features:

```bash
cd example
flutter run -d iPhone
```

Navigate to the "Native Tab Bar" demo to see:
- Badge count formatting (5, 99+)
- Different badge colors (red, blue, green)
- Alert badges (!)
- Dynamic badge updates

## Platform Support

- ✅ iOS 10+ (full support including custom colors)
- ✅ iOS 13+ (enhanced appearance API support)
- 🔄 macOS (badge value support, color customization pending)
- ❌ Web/Android (Flutter fallback without badges)

## Future Enhancements

Potential additions:
- Badge animations (pulse, fade) on value changes
- Badge position customization
- Text badge support (e.g., "NEW")
- macOS badge color support
- Accessibility announcements for badge value changes
