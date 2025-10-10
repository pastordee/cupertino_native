# Native Navigation Bar with Liquid Glass Effect

The `CNNavigationBar` component provides a truly native navigation bar with the signature iOS/macOS translucent "liquid glass" effect.

## Overview

This component uses:
- **iOS**: Native `UINavigationBar` with `UIBlurEffect` for authentic translucent blur
- **macOS**: Native `NSVisualEffectView` with `.headerView` material for proper translucency
- **Other platforms**: Falls back to `CupertinoNavigationBar`

## Features

✨ **Liquid Glass Translucency**: Real platform blur effects that adapt to content behind them  
🎨 **Native Appearance**: True iOS/macOS navigation bar look and feel  
🔘 **Custom Actions**: Leading (back) button and multiple trailing actions  
🎯 **SF Symbols Support**: Native icon rendering with full symbol support  
🌓 **Automatic Dark Mode**: Adapts blur effect to light/dark themes  
📱 **Large Title Support**: iOS 11+ style large titles  
👻 **Transparent Mode**: Completely transparent for custom effects  

## Usage

### Basic Navigation Bar

```dart
CNNavigationBar(
  leading: CNNavigationBarAction(
    icon: CNSymbol('chevron.left'),
    onPressed: () => Navigator.pop(context),
  ),
  title: 'My Page',
  trailing: [
    CNNavigationBarAction(
      icon: CNSymbol('gear'),
      onPressed: () => print('Settings'),
    ),
  ],
)
```

### With Large Title

```dart
CNNavigationBar(
  title: 'Messages',
  largeTitle: true, // iOS 11+ style
  trailing: [
    CNNavigationBarAction(
      icon: CNSymbol('square.and.pencil'),
      onPressed: () => print('Compose'),
    ),
  ],
)
```

### Transparent Mode

```dart
CNNavigationBar(
  title: 'Photo',
  transparent: true, // No blur, fully transparent
  tint: CupertinoColors.white,
  leading: CNNavigationBarAction(
    icon: CNSymbol('xmark'),
    onPressed: () => Navigator.pop(context),
  ),
)
```

### Multiple Trailing Actions

```dart
CNNavigationBar(
  title: 'Edit',
  trailing: [
    CNNavigationBarAction(
      icon: CNSymbol('square.and.arrow.up'),
      onPressed: () => print('Share'),
    ),
    CNNavigationBarAction(
      icon: CNSymbol('heart'),
      onPressed: () => print('Favorite'),
    ),
    CNNavigationBarAction(
      icon: CNSymbol('ellipsis.circle'),
      onPressed: () => print('More'),
    ),
  ],
)
```

### Text-Based Actions

```dart
CNNavigationBar(
  leading: CNNavigationBarAction(
    label: 'Cancel',
    onPressed: () => Navigator.pop(context),
  ),
  title: 'New Message',
  trailing: [
    CNNavigationBarAction(
      label: 'Send',
      onPressed: () => print('Send message'),
    ),
  ],
)
```

## Complete Example

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Native translucent navigation bar
            CNNavigationBar(
              leading: CNNavigationBarAction(
                icon: CNSymbol('chevron.left'),
                onPressed: () => Navigator.pop(context),
              ),
              title: 'Liquid Glass',
              trailing: [
                CNNavigationBarAction(
                  icon: CNSymbol('square.and.arrow.up'),
                  onPressed: () => _share(),
                ),
                CNNavigationBarAction(
                  icon: CNSymbol('ellipsis.circle'),
                  onPressed: () => _showMore(),
                ),
              ],
              tint: CupertinoColors.systemBlue,
            ),
            
            // Your content here
            Expanded(
              child: ListView(
                children: [
                  // Content scrolls behind the translucent bar
                  // creating the liquid glass effect
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Properties

### CNNavigationBar

| Property | Type | Description |
|----------|------|-------------|
| `leading` | `CNNavigationBarAction?` | Leading action (typically back button) |
| `title` | `String?` | Title text displayed in the center |
| `trailing` | `List<CNNavigationBarAction>?` | Trailing actions (right side buttons) |
| `largeTitle` | `bool` | Use iOS 11+ large title style (default: `false`) |
| `transparent` | `bool` | Use transparent background without blur (default: `false`) |
| `tint` | `Color?` | Tint color for buttons and icons |
| `height` | `double?` | Fixed height (if null, uses platform default) |

### CNNavigationBarAction

| Property | Type | Description |
|----------|------|-------------|
| `icon` | `CNSymbol?` | SF Symbol icon |
| `label` | `String?` | Text label (used if icon is null) |
| `onPressed` | `VoidCallback?` | Callback when tapped |

## Platform-Specific Behavior

### iOS
- Uses `UINavigationBar` with `UINavigationBarAppearance`
- Blur effect via `UIBlurEffect` with `.systemMaterialLight` / `.systemMaterialDark`
- Large titles use native `prefersLargeTitles` API
- Standard height: ~44pt (compact), ~96pt (large title)

### macOS
- Uses `NSVisualEffectView` with `.headerView` material
- Native toolbar appearance with proper vibrancy
- Standard height: 52pt

### Other Platforms
- Falls back to Flutter's `CupertinoNavigationBar`
- Maintains similar API but without native blur effects

## Tips for Best Results

### 1. Don't Use with CupertinoPageScaffold's navigationBar
```dart
// ❌ Don't do this
CupertinoPageScaffold(
  navigationBar: CupertinoNavigationBar(...), // Don't use
  child: CNNavigationBar(...), // Your custom bar
)

// ✅ Do this instead
CupertinoPageScaffold(
  child: SafeArea(
    top: false,
    child: Column(
      children: [
        CNNavigationBar(...),
        Expanded(child: yourContent),
      ],
    ),
  ),
)
```

### 2. Use SafeArea Carefully
```dart
// Set top: false to let the nav bar extend to the status bar
SafeArea(
  top: false, // Important!
  child: Column(
    children: [
      CNNavigationBar(...),
      // content
    ],
  ),
)
```

### 3. Best with Scrollable Content
The translucent effect looks best when content scrolls behind the bar:

```dart
Column(
  children: [
    CNNavigationBar(...),
    Expanded(
      child: ListView(...), // Content scrolls behind bar
    ),
  ],
)
```

### 4. Transparent Mode for Custom Backgrounds
Use `transparent: true` for photo viewers or custom backgrounds:

```dart
Stack(
  children: [
    Image.network(photoUrl), // Full-screen photo
    Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: CNNavigationBar(
        transparent: true,
        tint: CupertinoColors.white,
        // ...
      ),
    ),
  ],
)
```

## Limitations

- Large title mode only available on iOS 11+ (falls back gracefully)
- Custom title widgets not supported (title is always text)
- Fixed to top of screen (not scrollable like `SliverNavigationBar`)
- Action icons must be SF Symbols (or text labels)

## See Also

- [CNTabBar](tab_bar.md) - Native tab bar with translucent effect
- [CNButton](button.md) - Native buttons for navigation bar actions
- [CNSymbol](sf_symbol.md) - SF Symbol icons for actions
