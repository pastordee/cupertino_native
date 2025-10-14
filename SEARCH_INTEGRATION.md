# Search Integration Components

This document explains the new search-enabled variants of `CNToolbar`, `CNNavigationBar`, and `CNTabBar` that provide automatic search expansion with animation and results overlay.

## Overview

The search integration components automatically add a search button/tab and handle the expansion animation, search bar display, and results overlay. They're perfect for implementing iOS-style search experiences.

## Components

### 1. CNToolbarSearch

A toolbar with integrated search functionality. When the search icon is tapped, it animates to show a search bar with an optional context icon.

```dart
CNToolbarSearch(
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
    resultsBuilder: (context, searchText) {
      return MySearchResults(query: searchText);
    },
  ),
  contextIcon: const CNSymbol('apps.iphone'),
  transparent: false,
)
```

### 2. CNNavigationBarSearch

A navigation bar with integrated search. When search is tapped, the navigation bar transforms to show a search bar.

```dart
CNNavigationBarSearch(
  title: 'Contacts',
  leading: [
    CNNavigationBarAction(
      icon: const CNSymbol('plus'),
      onPressed: () => print('Add'),
    ),
  ],
  trailing: [
    CNNavigationBarAction(
      icon: const CNSymbol('ellipsis.circle'),
      onPressed: () => print('More'),
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

### 3. CNTabBarSearch

A tab bar with an integrated search tab. When tapped, it expands to show a search bar with the previously active tab icon for context.

```dart
CNTabBarSearch(
  items: const [
    CNTabBarItem(
      label: 'Home',
      icon: CNSymbol('house.fill'),
    ),
    CNTabBarItem(
      label: 'Radio',
      icon: CNSymbol('dot.radiowaves.left.and.right'),
    ),
    CNTabBarItem(
      label: 'Library',
      icon: CNSymbol('music.note.list'),
    ),
  ],
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() => _currentIndex = index);
  },
  searchConfig: CNSearchConfig(
    placeholder: 'Shows, Movies, and More',
    onSearchTextChanged: (text) {
      print('Searching: $text');
    },
    resultsBuilder: (context, searchText) {
      return MusicSearchResults(query: searchText);
    },
  ),
  split: true,
  rightCount: 1, // Search will be on the right
)
```

## CNSearchConfig

Configuration object for search behavior:

```dart
CNSearchConfig(
  // Placeholder text in the search bar
  placeholder: 'Search',
  
  // Icon for the search button/tab
  searchIcon: const CNSymbol('magnifyingglass'),
  
  // Whether to show cancel button
  showsCancelButton: true,
  
  // Animation duration for expand/collapse
  animationDuration: const Duration(milliseconds: 300),
  
  // Height of the search bar when expanded
  searchBarHeight: 50.0,
  
  // Called as user types
  onSearchTextChanged: (text) {
    // Update your search results
  },
  
  // Called when return key is pressed
  onSearchSubmitted: (text) {
    // Perform final search action
  },
  
  // Called when search is cancelled
  onSearchCancelled: () {
    // Clean up search state
  },
  
  // Builder for search results overlay
  resultsBuilder: (context, searchText) {
    return YourSearchResultsWidget(query: searchText);
  },
  
  // Whether to show results overlay automatically
  showResultsOverlay: true,
)
```

## Key Features

### Automatic Search Button/Tab
- Search icon is automatically added to the component
- No need to manually create search actions

### Smooth Animations
- Fade animation for toolbar/navbar
- Slide animation for tab bar
- Configurable duration

### Context Awareness
- Tab bar shows the last active tab icon when search is expanded
- Optional context icon for toolbar

### Results Overlay
- Optional results builder for real-time search results
- Results appear as user types
- Overlay automatically positioned

### Cancel Behavior
- Cancel button returns to previous state
- Animation reverses smoothly
- Search text is cleared

## Example: Tab Bar with Search (Apple Music Style)

This example replicates your current tab bar implementation:

```dart
class MyMusicApp extends StatefulWidget {
  @override
  State<MyMusicApp> createState() => _MyMusicAppState();
}

class _MyMusicAppState extends State<MyMusicApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tab content
        IndexedStack(
          index: _currentIndex,
          children: [
            HomePage(),
            RadioPage(),
            LibraryPage(),
          ],
        ),
        // Tab bar with search
        Align(
          alignment: Alignment.bottomCenter,
          child: CNTabBarSearch(
            items: const [
              CNTabBarItem(
                label: 'Home',
                icon: CNSymbol('house.fill'),
              ),
              CNTabBarItem(
                label: 'Radio',
                icon: CNSymbol('dot.radiowaves.left.and.right'),
              ),
              CNTabBarItem(
                label: 'Library',
                icon: CNSymbol('music.note.list'),
                badgeValue: 99,
              ),
            ],
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            searchConfig: CNSearchConfig(
              placeholder: 'Shows, Movies, and More',
              onSearchTextChanged: (text) {
                // Update search results in real-time
              },
              resultsBuilder: (context, searchText) {
                return MusicSearchResults(
                  query: searchText,
                  onResultTap: (result) {
                    print('Selected: $result');
                  },
                );
              },
            ),
            split: true,
            rightCount: 1,
          ),
        ),
      ],
    );
  }
}

class MusicSearchResults extends StatelessWidget {
  final String query;
  final ValueChanged<String> onResultTap;

  const MusicSearchResults({
    required this.query,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    // Filter your data based on query
    final results = getSearchResults(query);
    
    return Container(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      padding: const EdgeInsets.only(bottom: 60), // Space for tab bar
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          return CupertinoListTile(
            title: Text(results[index]),
            leading: Icon(CupertinoIcons.music_note),
            trailing: Icon(CupertinoIcons.play_fill),
            onTap: () => onResultTap(results[index]),
          );
        },
      ),
    );
  }
}
```

## Benefits vs Manual Implementation

### Before (Manual Implementation)
```dart
// Lots of boilerplate:
bool _isSearchExpanded = false;
String _searchText = '';
int _lastTabIndex = 0;
AnimationController _animationController;

// Manual animation setup
// Manual state management
// Manual tab tracking
// Manual search bar creation
// Manual results overlay positioning
```

### After (Search Integration Components)
```dart
// Clean, declarative:
CNTabBarSearch(
  items: myTabs,
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  searchConfig: CNSearchConfig(
    placeholder: 'Search',
    onSearchTextChanged: (text) { /* ... */ },
    resultsBuilder: (context, text) => MyResults(text),
  ),
)
```

## Demo

Check out the example app in `example/lib/demos/search_integration_demo.dart` for working examples of all three components with different search result presentations.

## Notes

- All three components maintain their original properties and behavior
- Search functionality is additive - existing components are unaffected
- The search button/tab is automatically positioned based on your configuration
- Animation and state management is handled internally
- Results overlay respects safe areas and component positioning
