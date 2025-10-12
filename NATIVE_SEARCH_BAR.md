# Native iOS Search Bar Implementation

## Overview

The `CNSearchBar` component provides a **native iOS UISearchBar** using platform views and platform channels, matching the same pattern as other native components like `CNTabBar` and `CNToolbar`.

## Architecture

### Dart Side (`lib/components/search_bar.dart`)
- `CNSearchBar` widget wraps a `UiKitView`
- Platform channel for bidirectional communication
- Callbacks for all search bar events
- Type-safe enums for iOS keyboard/appearance options

### Native iOS Side (`ios/Classes/Views/CupertinoSearchBarPlatformView.swift`)
- `CupertinoSearchBarPlatformView` wraps `UISearchBar`
- Implements `UISearchBarDelegate` for native events
- `CupertinoSearchBarPlatformViewFactory` for platform view creation
- Registered in `CupertinoNativePlugin.swift`

## Why Native Implementation?

✅ **Authentic iOS Experience**
- Real `UISearchBar` with native animations
- Native keyboard handling and interactions
- Platform-specific behavior (iOS-only features)
- Perfect visual consistency with iOS

✅ **Performance**
- No Flutter widget overhead for search bar
- Native rendering and layout
- Efficient platform channel communication

✅ **Feature Parity**
- Access to all UISearchBar features
- Scope bar (native UISegmentedControl)
- Native cancel button animations
- iOS 13+ search text field customization

## Comparison: Flutter vs Native

### Flutter Implementation (`CNSearchField`)
```dart
CNSearchField(
  placeholder: 'Search',
  showSuggestions: true,
  // Flutter widgets for suggestions, scope control
)
```
- ❌ Flutter widget rendering
- ❌ Custom animations
- ✅ Cross-platform (could work on Android/Web)
- ✅ More customization options

### Native Implementation (`CNSearchBar`)
```dart
CNSearchBar(
  placeholder: 'Search',
  showsScopeBar: true,
  // Native UISearchBar with UISegmentedControl
)
```
- ✅ Native UISearchBar
- ✅ Native iOS animations
- ✅ iOS-specific only
- ✅ Authentic Apple experience

## Usage

### Basic Search Bar

```dart
CNSearchBar(
  placeholder: 'Search',
  onTextChanged: (text) => performSearch(text),
  onSearchButtonClicked: (text) => submitSearch(text),
)
```

### Search Bar with Scope

```dart
CNSearchBar(
  placeholder: 'Search in Mail',
  showsCancelButton: true,
  showsScopeBar: true,
  scopeButtonTitles: ['All Mailboxes', 'Current Mailbox'],
  selectedScopeIndex: 0,
  onScopeChanged: (index) => updateScope(index),
)
```

### Search Bar Styles

```dart
// Default style
CNSearchBar(
  searchBarStyle: CNSearchBarStyle.defaultStyle,
)

// Prominent style (more visual weight)
CNSearchBar(
  searchBarStyle: CNSearchBarStyle.prominent,
)

// Minimal style (less chrome)
CNSearchBar(
  searchBarStyle: CNSearchBarStyle.minimal,
)
```

### Keyboard Customization

```dart
CNSearchBar(
  keyboardType: CNKeyboardType.emailAddress,
  keyboardAppearance: CNKeyboardAppearance.dark,
  returnKeyType: CNReturnKeyType.search,
  autocapitalizationType: CNAutocapitalizationType.none,
  autocorrectionType: CNAutocorrectionType.yes,
)
```

## Features

### ✅ All UISearchBar Features
- Text input with placeholder
- Cancel button (animated show/hide)
- Bookmark button
- Search results button
- Scope bar (native segmented control)
- Prompt text above search bar
- Custom colors (bar tint, tint, field background)

### ✅ Keyboard Configuration
- 12 keyboard types (default, email, URL, number pad, etc.)
- Keyboard appearance (light/dark)
- 12 return key types (search, go, done, etc.)
- Auto-capitalization (none, words, sentences, all)
- Auto-correction (default, yes, no)
- Spell checking (default, yes, no)

### ✅ Event Callbacks
- `onTextChanged` - fires as user types
- `onSearchButtonClicked` - search/return key pressed
- `onCancelButtonClicked` - cancel button tapped
- `onScopeChanged` - scope selection changed
- `onBookmarkButtonClicked` - bookmark button tapped

## Platform Channel Communication

### Dart → Native (Setup)
```dart
Map<String, dynamic> creationParams = {
  'placeholder': 'Search',
  'showsCancelButton': true,
  'scopeButtonTitles': ['All', 'Movies'],
  // ... other properties
};
```

### Native → Dart (Events)
```swift
channel.invokeMethod("onTextChanged", arguments: searchText)
channel.invokeMethod("onSearchButtonClicked", arguments: searchBar.text ?? "")
channel.invokeMethod("onCancelButtonClicked", arguments: nil)
channel.invokeMethod("onScopeChanged", arguments: selectedScope)
```

## Apple HIG Compliance

The native implementation automatically follows Apple HIG because it **is** the Apple-provided UISearchBar:

✅ Native animations and transitions
✅ Correct spacing and sizing
✅ Platform-appropriate keyboard
✅ Native scope bar (UISegmentedControl)
✅ Cancel button animations
✅ Dark mode support
✅ Accessibility support (built into UISearchBar)

## Example: Mail-Style Search

```dart
CNSearchBar(
  placeholder: 'Search in Mail',
  prompt: 'Search', // Shows above search bar
  showsCancelButton: true,
  showsScopeBar: true,
  scopeButtonTitles: [
    'All Mailboxes',
    'Current Mailbox',
  ],
  selectedScopeIndex: 0,
  searchBarStyle: CNSearchBarStyle.prominent,
  keyboardType: CNKeyboardType.emailAddress,
  returnKeyType: CNReturnKeyType.search,
  autocapitalizationType: CNAutocapitalizationType.none,
  autocorrectionType: CNAutocorrectionType.yes,
  onTextChanged: (text) {
    // Search as user types
    performLiveSearch(text);
  },
  onSearchButtonClicked: (text) {
    // Final search submission
    performFinalSearch(text);
    dismissKeyboard();
  },
  onCancelButtonClicked: () {
    // Clear search and dismiss
    clearSearch();
  },
  onScopeChanged: (index) {
    // Update search scope
    updateSearchScope(index);
  },
  height: 56.0,
)
```

## Height Considerations

The search bar height adjusts automatically:
- Base height: ~56 points
- With scope bar: +44 points (total ~100 points)

```dart
CNSearchBar(
  height: 56.0, // Base height
  showsScopeBar: true, // Adds 44 points automatically
)
```

## Implementation Pattern

This follows the same pattern as other native components:

1. **Dart Component** (`CNSearchBar`)
   - StatefulWidget with properties
   - UiKitView for platform view
   - MethodChannel for communication
   - Type-safe callbacks

2. **Swift Platform View** (`CupertinoSearchBarPlatformView`)
   - Wraps native UIKit component
   - Implements delegate protocol
   - Handles platform channel events

3. **Factory Registration** (`CupertinoNativePlugin`)
   - Factory registered with Flutter
   - Unique view type identifier

This ensures consistency across all native components in the plugin.

## Future Enhancements

Potential additions:
- [ ] Search tokens (iOS 13+)
- [ ] Custom input accessory view
- [ ] Search bar positioning helpers
- [ ] Search results controller integration
- [ ] Recent searches support
- [ ] macOS AppKit support

## Comparison with Other Native Components

| Component | Native Type | Delegate | Features |
|-----------|-------------|----------|----------|
| CNTabBar | UITabBar | UITabBarDelegate | Tabs, badges, split mode |
| CNToolbar | UIToolbar | - | Items, spacing |
| CNSearchBar | UISearchBar | UISearchBarDelegate | Search, scope, keyboard |
| CNNavigationBar | UINavigationBar | - | Title, buttons |

All follow the same platform view + method channel pattern for native iOS rendering and Flutter integration.
