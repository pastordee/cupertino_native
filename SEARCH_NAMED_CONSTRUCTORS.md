# Search Integration with Named Constructors

## Summary

Search functionality has been integrated directly into `CNToolbar` and `CNNavigationBar` using **named constructors** (`.search()`). This keeps all functionality in one place and makes it discoverable through IDE autocomplete.

## Usage

### CNToolbar.search()

```dart
CNToolbar.search(
  leading: [
    CNToolbarAction(
      icon: const CNSymbol('star.fill'),
      onPressed: () => print('Favorites'),
    ),
  ],
  trailing: [
    CNToolbarAction(
      icon: const CNSymbol('ellipsis.circle'),
      onPressed: () => print('More'),
    ),
  ],
  searchConfig: CNSearchConfig(
    placeholder: 'Search services',
    onSearchTextChanged: (text) {
      print('Searching: $text');
    },
    onSearchSubmitted: (text) {
      print('Submitted: $text');
    },
    resultsBuilder: (context, searchText) {
      return MySearchResults(query: searchText);
    },
  ),
  contextIcon: const CNSymbol('apps.iphone'), // Shows when search is active
  transparent: false,
)
```

### CNNavigationBar.search()

```dart
CNNavigationBar.search(
  title: 'Contacts',
  leading: [
    CNNavigationBarAction(
      icon: const CNSymbol('plus'),
      onPressed: () => print('Add'),
    ),
  ],
  searchConfig: CNSearchConfig(
    placeholder: 'Search contacts',
    onSearchTextChanged: (text) {
      print('Searching: $text');
    },
    resultsBuilder: (context, searchText) {
      return ContactSearchResults(query: searchText);
    },
  ),
)
```

## CNSearchConfig

Shared configuration object for all search-enabled components:

```dart
CNSearchConfig({
  placeholder: 'Search',                    // Search bar placeholder
  searchIcon: CNSymbol('magnifyingglass'),  // Icon for search button/tab
  showsCancelButton: true,                   // Show cancel button
  animationDuration: Duration(milliseconds: 300), // Expand/collapse duration
  searchBarHeight: 50.0,                     // Height when expanded
  onSearchTextChanged: (text) { },           // Called as user types
  onSearchSubmitted: (text) { },             // Called on return key
  onSearchCancelled: () { },                 // Called when cancelled
  resultsBuilder: (context, searchText) {    // Build search results overlay
    return YourResultsWidget(query: searchText);
  },
  showResultsOverlay: true,                  // Auto-show results
})
```

## Key Features

### 1. Same File Organization
- Search functionality lives in the same file as the component
- Accessible via named constructor (`.search()`)
- Shows up in IDE autocomplete and documentation

### 2. Automatic Search Button
- Search icon automatically added to component
- No manual action creation needed
- Configurable icon and position

### 3. Smooth Animations
- Fade animation for toolbar/navbar
- Configurable duration
- Reverse animation on cancel

### 4. Context Awareness
- Toolbar can show context icon when search is active
- Represents the previous state/screen
- Optional parameter

### 5. Results Overlay
- Real-time results as user types
- Builder pattern for custom results UI
- Automatically positioned
- Optional - can be disabled

## Benefits

### Discoverability
```dart
// User types "CNToolbar." and IDE shows:
CNToolbar()              // Regular toolbar
CNToolbar.search()       // Search-enabled toolbar ✨
```

### Organization
- All toolbar code in `toolbar.dart`
- All navigation bar code in `navigation_bar.dart`
- Search config in `search_config.dart` (shared)
- No separate "search_integration.dart"

### Documentation
- Search functionality documented alongside regular constructors
- Examples visible in same file
- Easier to maintain

## Architecture

Each search-enabled component uses:
1. **Named Constructor** - `.search()` accepts `CNSearchConfig`
2. **Internal Flag** - `_isSearchEnabled` determines state class
3. **Separate State Class** - `_CNToolbarSearchState` or `_CNNavigationBarSearchState`
4. **Animation Controller** - Handles expand/collapse
5. **Recursion** - Search state builds regular widget when not expanded

```dart
class CNToolbar extends StatefulWidget {
  // Regular constructor
  const CNToolbar({ ... }) 
    : searchConfig = null,
      _isSearchEnabled = false;

  // Search constructor
  const CNToolbar.search({ 
    required this.searchConfig,
    ...
  }) : _isSearchEnabled = true;

  final CNSearchConfig? searchConfig;
  final bool _isSearchEnabled;

  @override
  State<CNToolbar> createState() {
    if (_isSearchEnabled) {
      return _CNToolbarSearchState();
    }
    return _CNToolbarState();
  }
}
```

## Files Structure

```
lib/components/
├── toolbar.dart              // CNToolbar + CNToolbar.search()
├── navigation_bar.dart       // CNNavigationBar + CNNavigationBar.search()
├── tab_bar.dart              // CNTabBar (search TBD)
├── search_config.dart        // Shared CNSearchConfig
└── search_bar.dart           // Native UISearchBar

example/lib/demos/
└── simple_search_demo.dart   // Demo showing .search() usage
```

## Migration from Separate Classes

### Before (Separate Classes)
```dart
CNToolbarSearch(
  leading: [...],
  searchConfig: CNSearchConfig(...),
)
```

### After (Named Constructor)
```dart
CNToolbar.search(
  leading: [...],
  searchConfig: CNSearchConfig(...),
)
```

Just change:
- `CNToolbarSearch` → `CNToolbar.search`
- `CNNavigationBarSearch` → `CNNavigationBar.search`

## Demo

Run the example app and navigate to "Search Integration" to see:
- `CNToolbar.search()` with context icon
- `CNNavigationBar.search()` with title transformation
- Live search results overlay
- Smooth expand/collapse animations

## Future: CNTabBar.search()

The tab bar search integration is more complex due to tab state management. It will follow the same pattern:

```dart
CNTabBar.search(
  items: myTabs,
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  searchConfig: CNSearchConfig(...),
)
```

The search tab will:
- Auto-insert at specified position (or end)
- Show last active tab icon when expanded
- Slide up animation from bottom
- Return to previous tab on cancel

## Implementation Notes

### State Management
- Each component has its own search state class
- State classes use `SingleTickerProviderStateMixin` for animations
- Search state builds regular widget when collapsed (recursion)

### Animation
- `AnimationController` for expand/collapse
- `FadeTransition` for toolbar/navbar
- `SlideTransition` for tab bar
- Configurable duration via CNSearchConfig

### Results Overlay
- Positioned absolutely
- Z-index above content, below search bar
- Builder pattern for flexibility
- Respects safe areas

This approach keeps everything organized, discoverable, and easy to maintain! 🎉
