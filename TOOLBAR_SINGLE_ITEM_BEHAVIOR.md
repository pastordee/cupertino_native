# CNToolbar Single Item Behavior

## Overview

When `CNToolbar` has only **one item**, the positioning behavior follows native iOS UINavigationBar conventions. This document explains this important behavior.

## The Behavior

### Single Item Positioning

When you have only one button in `CNToolbar`:

- ✅ **Use `trailing`** → Item appears on the **left side** (natural position)
- ❌ **Use `leading`** → Item appears on the **left side** (but may not respond to taps consistently)

This might seem counterintuitive, but it's how iOS native `UINavigationBar` works!

## Why This Happens

### iOS UINavigationBar Architecture

`CNToolbar` wraps the native `UINavigationBar` which has two arrays:
- `leftBarButtonItems` (set by Dart's `leading`)
- `rightBarButtonItems` (set by Dart's `trailing`)

When the navigation bar has:
- **Multiple items on both sides**: They layout naturally (left items on left, right items on right)
- **Only one item**: iOS treats it specially and positions it with optimal spacing and touch targets

### The Counterintuitive Part

For single items, using `trailing` actually works better because:
1. iOS optimizes single `rightBarButtonItems` for common patterns (like back buttons)
2. The touch target is properly registered
3. The spacing and padding are optimal

## Code Examples

### ✅ Correct: Single Item with `trailing`

```dart
CNToolbar(
  trailing: [
    CNToolbarAction(
      icon: CNSymbol('house.fill'),
      onPressed: () {
        print('Tapped!'); // ✅ This works reliably
      },
    ),
  ],
  height: 44,
)
```

**Result**: Button appears on left, responds to taps reliably.

### ❌ Avoid: Single Item with `leading`

```dart
CNToolbar(
  leading: [
    CNToolbarAction(
      icon: CNSymbol('house.fill'),
      onPressed: () {
        print('Tapped!'); // ⚠️ May not work consistently
      },
    ),
  ],
  height: 44,
)
```

**Result**: Button appears on left, but tap handling may be inconsistent.

## Multiple Items - Normal Behavior

When you have **multiple items**, use `leading` and `trailing` naturally:

```dart
CNToolbar(
  leading: [
    CNToolbarAction(
      icon: CNSymbol('chevron.left'),
      onPressed: () => Navigator.pop(context),
    ),
    CNToolbarAction(
      icon: CNSymbol('square.and.arrow.up'),
      onPressed: () => share(),
    ),
  ],
  trailing: [
    CNToolbarAction(
      icon: CNSymbol('plus'),
      onPressed: () => add(),
    ),
  ],
)
```

**Result**: Leading items on left, trailing items on right (as expected).

## Real-World Use Case: Tab Bar Search

This behavior is especially important for tab bar search implementations:

```dart
Widget _buildExpandedSearch() {
  return Row(
    children: [
      // Show last tab icon on left
      SizedBox(
        width: 80,
        child: CNToolbar(
          trailing: [ // ✅ Use trailing for single item
            CNToolbarAction(
              icon: _getLastTabIcon(),
              onPressed: () {
                // Return to previous tab
                setState(() {
                  _isSearchExpanded = false;
                  _index = _lastTabIndex;
                });
              },
            ),
          ],
          height: 44,
          transparent: true,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: CNSearchBar(
          placeholder: 'Search',
          showsCancelButton: true,
        ),
      ),
    ],
  );
}
```

## Technical Details

### iOS Implementation

In `CupertinoNavigationBarPlatformView.swift`:

```swift
// Leading items → leftBarButtonItems
if !leadingIcons.isEmpty || !leadingLabels.isEmpty {
  // ... process leading items
  navigationItem.leftBarButtonItems = barItems
}

// Trailing items → rightBarButtonItems  
if !trailingIcons.isEmpty || !trailingLabels.isEmpty {
  // ... process trailing items
  navigationItem.rightBarButtonItems = trailingBarItems
}
```

When there's only one `rightBarButtonItem`, iOS:
1. Positions it with optimal spacing
2. Ensures proper touch target size
3. Handles tap gestures reliably

### Why Leading Can Be Inconsistent

When you use `leading` with a single item:
- The item is added to `leftBarButtonItems`
- If there's no title or middle content, the layout may be ambiguous
- Touch targets might not be properly calculated
- iOS doesn't optimize for this pattern

## Best Practices

### 1. Single Item → Use `trailing`

```dart
// ✅ DO THIS for single items
CNToolbar(
  trailing: [CNToolbarAction(icon: icon, onPressed: onTap)],
)
```

### 2. Multiple Items → Use Naturally

```dart
// ✅ DO THIS for multiple items
CNToolbar(
  leading: [backButton, shareButton],
  trailing: [addButton, menuButton],
)
```

### 3. Constrain Width in Rows

When using toolbar in a `Row`, always wrap in `SizedBox`:

```dart
// ✅ DO THIS
SizedBox(
  width: 80,
  child: CNToolbar(...),
)

// ❌ DON'T DO THIS
CNToolbar(...) // Will cause infinite width error in Row
```

## Summary

| Scenario | Use | Reason |
|----------|-----|--------|
| **Single button** | `trailing` | iOS optimizes this pattern |
| **Multiple buttons** | `leading` and `trailing` naturally | Works as expected |
| **In a Row** | Wrap in `SizedBox` | Prevents infinite width |
| **Tab bar search** | `trailing` for back icon | Reliable taps and layout |

## See Also

- `SEARCH_INTEGRATION_PATTERNS.md` - Search bar integration examples
- `example/lib/demos/tab_bar.dart` - Working implementation
- `example/lib/demos/toolbar.dart` - Multiple button examples

---

**Note**: This behavior matches native iOS patterns. Apps like Mail, Safari, and Music use similar patterns where single navigation items are positioned using `rightBarButtonItems` even when they appear on the left side of the screen.
