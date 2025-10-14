# Native Sheet Enhancements

## Overview

This document describes the enhancements made to the native sheet implementation, including custom styling, theming, and advanced customization options.

## Implemented Features

### ✅ 1. Custom Header Colors

The native sheet now supports complete color customization:

#### Swift Implementation
- **Header Background Color**: Custom background color or system blur effect
- **Title Color**: Custom text color for the header title
- **Divider Color**: Custom color for the bottom divider line
- **Close Button Color**: Custom tint color for the close button

#### Usage Example
```dart
CNNativeSheet.showWithCustomHeaderUiKitView(
  context: context,
  title: 'Custom Colors',
  builder: (context) => YourContent(),
  // Custom colors
  headerBackgroundColor: Color(0xFF1E1E1E),
  headerTitleColor: CupertinoColors.systemYellow,
  headerDividerColor: CupertinoColors.systemYellow.withOpacity(0.3),
  closeButtonColor: CupertinoColors.systemYellow,
);
```

### ✅ 2. Custom Font Styling

Full control over title typography:

#### Parameters
- **`headerTitleSize`**: Font size for the title (default: 17)
- **`headerTitleWeight`**: Font weight from ultraLight to black
- **`headerTitleColor`**: Title text color

#### Usage Example
```dart
CNNativeSheet.showWithCustomHeaderUiKitView(
  context: context,
  title: 'Premium Feature',
  builder: (context) => YourContent(),
  headerTitleSize: 20,
  headerTitleWeight: FontWeight.bold,
  headerTitleColor: CupertinoColors.white,
);
```

### ✅ 3. Custom Button Icons

Extended SF Symbols support for close button:

#### Parameters
- **`closeButtonIcon`**: SF Symbol name (e.g., 'xmark', 'chevron.down', 'xmark.circle.fill')
- **`closeButtonSize`**: Button icon size (default: 17)
- **`closeButtonColor`**: Button tint color
- **`closeButtonPosition`**: 'leading' or 'trailing' (default: 'trailing')

#### Usage Example
```dart
CNNativeSheet.showWithCustomHeaderUiKitView(
  context: context,
  title: 'Minimal',
  builder: (context) => YourContent(),
  closeButtonIcon: 'chevron.down',
  closeButtonSize: 14,
  closeButtonColor: CupertinoColors.systemGrey,
  closeButtonPosition: 'leading',
);
```

### ✅ 4. Dark Mode Optimization

All customization options automatically adapt to dark mode:

- System colors adjust automatically
- Custom colors are preserved as specified
- Blur effects adapt to system appearance
- Separator and divider colors respect dark mode

## Demo Page

A comprehensive demo page showcases all customization options:

**File**: `example/lib/demos/sheet_custom_styling.dart`

### Demo Examples

1. **Default Style**: System colors with blur effect
2. **Custom Colors**: Dark header with yellow accents
3. **Branded**: Purple brand theme
4. **Minimal**: Clean, understated design
5. **Alert Style**: Warning/error state
6. **Success**: Confirmation state

## Technical Details

### Swift Implementation

**File**: `ios/Classes/Views/CupertinoNativeSheetHeaderView.swift`

#### Close Button Behavior

The close button in the native header triggers different behaviors based on the sheet's modal state:

- **Modal sheets**: Uses `Navigator.pop()` to dismiss via the navigation stack
- **Non-modal sheets**: Uses the `onClose` callback to remove the OverlayEntry

This ensures proper cleanup regardless of presentation mode.

#### Color Parsing
```swift
if let bgColorValue = args["headerBackgroundColor"] as? Int64 {
    backgroundColor = UIColor(argb: bgColorValue)
    useBlur = false // Disable blur with custom color
}
```

#### Font Weight Mapping
```swift
private func fontWeightFromString(_ weightStr: String) -> UIFont.Weight {
    switch weightStr {
    case "ultraLight": return .ultraLight
    case "thin": return .thin
    case "light": return .light
    case "regular": return .regular
    case "medium": return .medium
    case "semibold": return .semibold
    case "bold": return .bold
    case "heavy": return .heavy
    case "black": return .black
    default: return .regular
    }
}
```

#### Dynamic Styling
- Blur effect is automatically disabled when custom background color is set
- All colors support ARGB format from Flutter
- SF Symbols with size and weight configuration

### Dart API

All parameters are optional with sensible defaults:

```dart
static Future<void> showWithCustomHeaderUiKitView({
  required BuildContext context,
  required String title,
  required Widget Function(BuildContext) builder,
  List<CNSheetDetent> detents = const [CNSheetDetent.large],
  bool prefersGrabberVisible = true,
  bool isModal = false,
  bool prefersEdgeAttachedInCompactHeight = false,
  bool widthFollowsPreferredContentSizeWhenEdgeAttached = false,
  double? preferredCornerRadius,
  // Customization options
  double? headerTitleSize,
  FontWeight? headerTitleWeight,
  Color? headerTitleColor,
  double? headerHeight,
  Color? headerBackgroundColor,
  bool showHeaderDivider = true,
  Color? headerDividerColor,
  String closeButtonPosition = 'trailing',
  String closeButtonIcon = 'xmark',
  double? closeButtonSize,
  Color? closeButtonColor,
}) async
```

## Common Use Cases

### Branded Experience
```dart
CNNativeSheet.showWithCustomHeaderUiKitView(
  context: context,
  title: 'Premium',
  builder: (context) => Content(),
  headerBackgroundColor: brandColor,
  headerTitleColor: Colors.white,
  headerTitleWeight: FontWeight.bold,
  closeButtonColor: Colors.white,
);
```

### Alert/Warning
```dart
CNNativeSheet.showWithCustomHeaderUiKitView(
  context: context,
  title: 'Warning',
  builder: (context) => Content(),
  headerBackgroundColor: Color(0xFFFFEBEE),
  headerTitleColor: CupertinoColors.destructiveRed,
  closeButtonIcon: 'xmark.circle.fill',
  closeButtonColor: CupertinoColors.destructiveRed,
);
```

### Minimal Design
```dart
CNNativeSheet.showWithCustomHeaderUiKitView(
  context: context,
  title: 'Options',
  builder: (context) => Content(),
  headerBackgroundColor: CupertinoColors.systemGrey6,
  headerTitleSize: 15,
  headerTitleWeight: FontWeight.w500,
  showHeaderDivider: false,
  closeButtonIcon: 'chevron.down',
  closeButtonSize: 14,
);
```

## Future Enhancements

### Planned Features

1. **Header Accessories**: Additional buttons in the header (e.g., "Done", "Cancel")
2. **Sheet Resize Callbacks**: Notification when detent changes
3. **Keyboard Avoidance**: Automatic adjustment for keyboard
4. **Enhanced Safe Area**: Better handling for notched devices

## Testing

To test the enhancements:

1. Build the example app: `cd example && flutter build ios`
2. Navigate to "Sheet Custom Styling" in the demo list
3. Tap each style option to see customization examples
4. Toggle dark mode to verify color adaptation
5. Try non-modal sheets to test background interaction

## Compatibility

- **iOS**: 13.0+ (for SF Symbols)
- **Flutter**: 3.0+
- **Dart**: 2.17+

All features gracefully degrade on older iOS versions.

## Notes

- Custom background colors disable the blur effect for better color accuracy
- SF Symbol names must be valid iOS system symbols
- All color values are passed as ARGB integers from Flutter
- Font weights map to UIFont.Weight equivalents
- Dark mode adaptation is automatic for system colors
