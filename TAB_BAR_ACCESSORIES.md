# Tab Bar Accessories and Search Field

## Overview
Extended tab bar support with accessories (leading/trailing buttons) and an integrated search field, following Apple's Human Interface Guidelines for iOS tab bars and toolbars.

## Features

### 1. Leading Accessories
Add buttons or controls before the tab bar items. Typically used for:
- Menu buttons (hamburger icon)
- Filter controls
- Navigation buttons
- Settings access

### 2. Trailing Accessories
Add buttons or controls after the tab bar items. Typically used for:
- Compose/Create buttons
- Add buttons
- Action buttons
- More options menu

### 3. Search Field
Integrate a native search field into the tab bar area. Provides:
- Placeholder text customization
- Live search text updates
- Search submission handling
- Native iOS keyboard integration

## Usage Examples

### Example 1: Tab Bar with Search Field

```dart
CNTabBar(
  showSearchField: true,
  searchPlaceholder: 'Search music, artists...',
  onSearchChanged: (text) {
    print('Searching: $text');
    // Update search results
  },
  onSearchSubmitted: (text) {
    print('Search submitted: $text');
    // Navigate to search results
  },
  items: [
    CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
    CNTabBarItem(label: 'Library', icon: CNSymbol('books.vertical.fill')),
  ],
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
)
```

### Example 2: Tab Bar with Leading and Trailing Accessories

```dart
CNTabBar(
  leadingAccessory: CupertinoButton(
    padding: EdgeInsets.zero,
    child: Icon(
      CupertinoIcons.line_horizontal_3,
      color: CupertinoColors.systemBlue,
    ),
    onPressed: () => _showMenu(),
  ),
  
  trailingAccessory: CupertinoButton(
    padding: EdgeInsets.zero,
    child: Icon(
      CupertinoIcons.square_pencil,
      color: CupertinoColors.systemBlue,
    ),
    onPressed: () => _compose(),
  ),
  
  items: [
    CNTabBarItem(label: 'Inbox', icon: CNSymbol('tray.fill')),
    CNTabBarItem(label: 'Sent', icon: CNSymbol('paperplane.fill')),
    CNTabBarItem(label: 'Archive', icon: CNSymbol('archivebox.fill')),
  ],
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
)
```

### Example 3: Combined - Search with Accessories

```dart
CNTabBar(
  showSearchField: true,
  searchPlaceholder: 'Search',
  onSearchChanged: (text) => _handleSearch(text),
  
  leadingAccessory: CupertinoButton(
    padding: EdgeInsets.zero,
    child: Icon(CupertinoIcons.line_horizontal_3),
    onPressed: () => _showMenu(),
  ),
  
  trailingAccessory: CupertinoButton(
    padding: EdgeInsets.zero,
    child: Icon(CupertinoIcons.plus_circle_fill),
    onPressed: () => _addNew(),
  ),
  
  items: [
    CNTabBarItem(label: 'All', icon: CNSymbol('square.grid.2x2')),
    CNTabBarItem(label: 'Recent', icon: CNSymbol('clock.fill')),
  ],
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
)
```

### Example 4: Bottom Toolbar Pattern (HIG Compliant)

```dart
// Recreate the Apple Music-style bottom toolbar with search
CNTabBar(
  showSearchField: true,
  searchPlaceholder: 'Search music, artists, lyrics...',
  leadingAccessory: _buildMenuButton(),
  trailingAccessory: _buildMoreButton(),
  items: [], // No tabs, just search with accessories
  currentIndex: 0,
  onTap: (_) {},
)
```

### Example 5: Mail App Pattern

```dart
CNTabBar(
  showSearchField: true,
  searchPlaceholder: 'Search emails',
  trailingAccessory: CupertinoButton(
    padding: EdgeInsets.zero,
    child: Icon(CupertinoIcons.square_pencil),
    onPressed: () => _composeEmail(),
  ),
  items: [
    CNTabBarItem(
      label: 'Inbox',
      icon: CNSymbol('tray.fill'),
      badgeValue: 42,
      badgeColor: CupertinoColors.systemBlue,
    ),
    CNTabBarItem(label: 'Sent', icon: CNSymbol('paperplane.fill')),
  ],
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
)
```

## API Reference

### CNTabBar Properties

```dart
class CNTabBar extends StatefulWidget {
  /// Optional leading accessory (button or control) to display before tabs.
  /// Typically used for menu buttons, filters, or navigation controls.
  final Widget? leadingAccessory;

  /// Optional trailing accessory (button or control) to display after tabs.
  /// Typically used for compose, add, or action buttons.
  final Widget? trailingAccessory;

  /// When true, displays a search field in the tab bar.
  /// The search field appears as a separate row above the tabs.
  final bool showSearchField;

  /// Placeholder text for the search field.
  /// Defaults to "Search" if not specified.
  final String? searchPlaceholder;

  /// Called when the search text changes.
  /// Fired on every character entered/deleted.
  final ValueChanged<String>? onSearchChanged;

  /// Called when the user submits the search (e.g., taps return key).
  /// Use this to navigate to search results or trigger final search.
  final ValueChanged<String>? onSearchSubmitted;
}
```

## Layout Behavior

### With Search Field
When `showSearchField: true`:
- Search field appears in a separate row above the tab bar
- Search field is 52px tall with 6px vertical padding
- Accessories can be placed alongside the search field
- Tab bar appears below the search field

### With Accessories Only
When accessories are added without search:
- Accessories are positioned at the edges of the tab bar
- Leading accessory: 8px left padding, 4px right padding
- Trailing accessory: 4px left padding, 8px right padding
- Tab bar items fill the space between accessories

### Combined Layout
When both search and accessories are present:
- Search field row includes accessories
- Tab bar row shows only tabs
- Total height = search row (52px) + tab bar (50px) = 102px

## Design Guidelines

### Following Apple HIG

1. **Bottom Toolbar Search** (Music, TV apps)
   - Search field as primary element
   - Menu button (leading)
   - More/Options button (trailing)

2. **Mail Pattern**
   - Search at top of toolbar
   - Compose button (trailing)
   - Tabs with badges

3. **Settings Pattern**
   - Search as standalone toolbar
   - No accessories needed
   - Focus on content

### Best Practices

1. **Keep accessories minimal** - Use 1-2 buttons max per side
2. **Use clear icons** - SF Symbols or universally recognized icons
3. **Provide feedback** - Show visual response to button taps
4. **Consider reachability** - Bottom placement for frequently used actions
5. **Match system style** - Use CupertinoButtons with appropriate styling

### Accessibility

- All accessories should be tappable (min 44x44 points)
- Provide semantic labels for screen readers
- Ensure sufficient contrast for icons
- Support dynamic type for search placeholder

## Common Patterns

### Pattern 1: Search-First Experience
```dart
// Prominent search with minimal chrome
showSearchField: true,
leadingAccessory: menuButton,
items: [], // No tabs
```

### Pattern 2: Tab Bar with Actions
```dart
// Traditional tabs with action buttons
leadingAccessory: filterButton,
trailingAccessory: addButton,
items: [tab1, tab2, tab3],
```

### Pattern 3: Split Tab Bar with Search
```dart
// Split tabs with search row above
showSearchField: true,
split: true,
rightCount: 2,
items: [tab1, tab2, tab3, tab4],
```

## Implementation Notes

### Flutter Side
- Accessories are wrapped around the native tab bar view
- Search field uses `CupertinoSearchTextField`
- Layout handled in Flutter for flexibility
- Native tab bar remains a platform view

### iOS Side
- No changes needed to native implementation
- Tab bar continues to use UITabBar
- Accessories are pure Flutter widgets

### Performance
- Accessories are standard Flutter widgets
- No additional platform channels needed
- Search text updates are efficient
- Hot reload fully supported

## Testing

Test the demo to see:
```bash
cd example
flutter run -d iPhone
```

Navigate to "Native Tab Bar" demo to see:
- Search field with live updates
- Leading menu button (prints to console)
- Trailing compose button (prints to console)
- All working together with badges and colors

## Future Enhancements

Potential additions:
- Search tokens/chips
- Scope controls (segmented control in search)
- Search suggestions dropdown
- Animated search expansion
- Voice search button
- Custom search field styling
