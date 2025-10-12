# Native Search Bar Integration Patterns

## Overview

The native `CNSearchBar` can be integrated into toolbars and tab bars to provide authentic iOS search experiences. This document shows the different integration patterns.

## Pattern 1: Toolbar with Expandable Search

**Use Case:** Search in navigation toolbar (Mail, Notes, Settings pattern)

**Implementation:**
```dart
class _ToolbarDemoPageState extends State<ToolbarDemoPage> {
  bool _isSearchExpanded = false;
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Content...
        
        // Top toolbar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: _isSearchExpanded
                ? _buildExpandedSearchToolbar()
                : _buildNormalToolbar(),
          ),
        ),
      ],
    );
  }

  Widget _buildNormalToolbar() {
    return CNToolbar(
      leading: [/* back button, etc. */],
      trailing: [
        CNToolbarAction(
          icon: CNSymbol('magnifyingglass'),
          onPressed: () {
            setState(() => _isSearchExpanded = true);
          },
        ),
        // Other trailing actions...
      ],
    );
  }

  Widget _buildExpandedSearchToolbar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(8),
      child: CNSearchBar(
        placeholder: 'Search',
        showsCancelButton: true,
        onTextChanged: (text) => performSearch(text),
        onCancelButtonClicked: () {
          setState(() {
            _isSearchExpanded = false;
            _searchText = '';
          });
        },
      ),
    );
  }
}
```

**Behavior:**
1. User taps search icon in toolbar trailing area
2. Toolbar transitions to show native search bar
3. Search bar appears with cancel button
4. User can type and search immediately
5. Tapping cancel collapses back to normal toolbar

**Example Apps:** Mail, Notes, Settings

---

## Pattern 2: Tab Bar with Expandable Search

**Use Case:** Search as a tab that expands to full search bar (Apple Music, TV pattern)

**Implementation:**
```dart
class _TabBarDemoPageState extends State<TabBarDemoPage> {
  int _index = 0;
  bool _isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Content...
        
        // Bottom area
        Align(
          alignment: Alignment.bottomCenter,
          child: _isSearchExpanded 
              ? _buildExpandedSearch() 
              : _buildTabBar(),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return CNTabBar(
      items: [
        CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
        CNTabBarItem(label: 'Library', icon: CNSymbol('music.note.list')),
        CNTabBarItem(label: 'Search', icon: CNSymbol('magnifyingglass')),
      ],
      currentIndex: _index,
      onTap: (i) {
        if (i == 2) {
          // Search tab tapped - expand
          setState(() => _isSearchExpanded = true);
        } else {
          setState(() => _index = i);
        }
      },
    );
  }

  Widget _buildExpandedSearch() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: CNSearchBar(
        placeholder: 'Shows, Movies, and More',
        showsCancelButton: true,
        onCancelButtonClicked: () {
          setState(() => _isSearchExpanded = false);
        },
      ),
    );
  }
}
```

**Behavior:**
1. Tab bar shows search as a tab with magnifying glass icon
2. User taps search tab
3. Tab bar transitions to native search bar
4. Search field expands with cancel button
5. User can search with immediate results
6. Tapping cancel returns to tab bar

**Example Apps:** Apple Music, Apple TV, App Store

---

## Pattern 3: Always-Visible Search in Toolbar

**Use Case:** Search always present in navigation bar

**Implementation:**
```dart
CNToolbar(
  middle: [
    Expanded(
      child: CNSearchBar(
        placeholder: 'Search',
        showsCancelButton: false,
        onTextChanged: (text) => performSearch(text),
      ),
    ),
  ],
  trailing: [
    CNToolbarAction(
      icon: CNSymbol('line.3.horizontal.decrease.circle'),
      onPressed: () => showFilters(),
    ),
  ],
)
```

**Behavior:**
- Search bar always visible in toolbar
- No expansion/collapse animation
- Immediate search as user types
- Filter button or other actions in trailing area

**Example Apps:** Contacts, Files

---

## Pattern 4: Bottom Toolbar with Search

**Use Case:** Search field in bottom toolbar with other actions

**Implementation:**
```dart
Positioned(
  bottom: 0,
  left: 0,
  right: 0,
  child: SafeArea(
    top: false,
    child: Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          CNToolbarAction(
            icon: CNSymbol('line.3.horizontal'),
            onPressed: () => showMenu(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CNSearchBar(
              placeholder: 'Search',
              showsCancelButton: false,
              height: 40,
            ),
          ),
          const SizedBox(width: 8),
          CNToolbarAction(
            icon: CNSymbol('plus'),
            onPressed: () => addItem(),
          ),
        ],
      ),
    ),
  ),
)
```

**Behavior:**
- Search bar in center with buttons on sides
- Search bar always visible
- Actions remain accessible while searching

---

## Best Practices

### 1. Use Native Search Bar

✅ **Do:**
```dart
CNSearchBar(
  placeholder: 'Shows, Movies, and More',
  showsCancelButton: true,
)
```

This provides:
- Real `UISearchBar` (not Flutter widget)
- Native animations
- Platform-standard keyboard
- Authentic iOS behavior

❌ **Don't:**
Use `CupertinoSearchTextField` or custom Flutter widgets for main search - they won't match native iOS behavior.

### 2. Descriptive Placeholders

✅ **Do:**
```dart
CNSearchBar(placeholder: 'Shows, Movies, and More')
CNSearchBar(placeholder: 'Search in Mail')
CNSearchBar(placeholder: 'Songs, Albums, Artists')
```

❌ **Don't:**
```dart
CNSearchBar(placeholder: 'Search') // Too generic
```

### 3. Always Show Cancel Button When Expanded

✅ **Do:**
```dart
Widget _buildExpandedSearch() {
  return CNSearchBar(
    showsCancelButton: true, // ✅ Always true when expanded
    onCancelButtonClicked: () => collapse(),
  );
}
```

This provides clear exit affordance.

### 4. Smooth Transitions

✅ **Do:**
```dart
child: AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: _isSearchExpanded
      ? _buildExpandedSearch()
      : _buildNormalState(),
)
```

Use animations for expand/collapse transitions.

### 5. Handle Cancel Properly

✅ **Do:**
```dart
onCancelButtonClicked: () {
  setState(() {
    _isSearchExpanded = false;
    _searchText = ''; // Clear search
    // Reset any search results
  });
}
```

Always reset state when search is cancelled.

---

## Scope Bar Integration

Add scope filtering to search:

```dart
CNSearchBar(
  placeholder: 'Search in Mail',
  showsScopeBar: true,
  scopeButtonTitles: ['All Mailboxes', 'Current Mailbox'],
  selectedScopeIndex: 0,
  onScopeChanged: (index) {
    setState(() => _selectedScope = index);
    performSearch(_searchText);
  },
)
```

**Height Consideration:**
- Base search bar: ~56 points
- With scope bar: ~100 points (56 + 44)

```dart
Container(
  height: _showScopeBar ? 100 : 56,
  child: CNSearchBar(
    showsScopeBar: _showScopeBar,
    scopeButtonTitles: ['All', 'Movies', 'TV Shows'],
  ),
)
```

---

## Keyboard Configuration

Customize keyboard for search context:

```dart
// Email search
CNSearchBar(
  keyboardType: CNKeyboardType.emailAddress,
  autocapitalizationType: CNAutocapitalizationType.none,
)

// General text search
CNSearchBar(
  keyboardType: CNKeyboardType.defaultType,
  autocorrectionType: CNAutocorrectionType.yes,
)

// Number search
CNSearchBar(
  keyboardType: CNKeyboardType.numberPad,
  returnKeyType: CNReturnKeyType.search,
)
```

---

## Complete Example: Mail-Style Search

```dart
class MailStyleSearchDemo extends StatefulWidget {
  @override
  State<MailStyleSearchDemo> createState() => _MailStyleSearchDemoState();
}

class _MailStyleSearchDemoState extends State<MailStyleSearchDemo> {
  bool _isSearchExpanded = false;
  String _searchText = '';
  int _selectedScope = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Content
          ListView(/* email list */),
          
          // Top navigation with search
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _isSearchExpanded
                  ? _buildSearchBar()
                  : _buildNavigationBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return CNToolbar(
      leading: [
        CNToolbarAction(
          icon: CNSymbol('chevron.left'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      middle: [
        Text('Inbox', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ],
      trailing: [
        CNToolbarAction(
          icon: CNSymbol('magnifyingglass'),
          onPressed: () {
            setState(() => _isSearchExpanded = true);
          },
        ),
        CNToolbarAction(
          icon: CNSymbol('ellipsis.circle'),
          onPressed: () => showMenu(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 100, // With scope bar
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
          ),
        ),
      ),
      child: CNSearchBar(
        placeholder: 'Search in Mail',
        showsCancelButton: true,
        showsScopeBar: true,
        scopeButtonTitles: ['All Mailboxes', 'Current Mailbox'],
        selectedScopeIndex: _selectedScope,
        keyboardType: CNKeyboardType.emailAddress,
        returnKeyType: CNReturnKeyType.search,
        autocapitalizationType: CNAutocapitalizationType.none,
        onTextChanged: (text) {
          setState(() => _searchText = text);
          searchEmails(text, _selectedScope);
        },
        onSearchButtonClicked: (text) {
          searchEmails(text, _selectedScope);
        },
        onCancelButtonClicked: () {
          setState(() {
            _isSearchExpanded = false;
            _searchText = '';
          });
          clearSearch();
        },
        onScopeChanged: (index) {
          setState(() => _selectedScope = index);
          if (_searchText.isNotEmpty) {
            searchEmails(_searchText, index);
          }
        },
      ),
    );
  }

  void searchEmails(String query, int scope) {
    print('Searching "$query" in scope $scope');
    // Perform actual search...
  }

  void clearSearch() {
    // Clear search results...
  }

  void showMenu() {
    // Show action menu...
  }
}
```

---

## Summary

The native `CNSearchBar` integrates seamlessly into toolbars and tab bars, providing authentic iOS search experiences. Key patterns:

1. **Expandable toolbar search** - Search icon expands to full search bar
2. **Expandable tab bar search** - Search tab expands to search bar
3. **Always-visible search** - Search bar always present in toolbar
4. **Bottom toolbar search** - Search with actions on sides

All patterns use the native `UISearchBar` for pixel-perfect iOS appearance and behavior.
