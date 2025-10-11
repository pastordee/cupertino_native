# Toolbar Spacing Guide

The `CNToolbar` component now supports flexible and fixed spacing between items, following iOS/macOS Human Interface Guidelines.

## Overview

According to Apple's HIG, toolbars should:
- Keep actions with text labels separate to avoid confusion
- Use fixed space between text-labeled buttons to prevent text from running together
- Allow flexible spacing for dynamic layouts

## Spacer Types

### Fixed Space

Use `CNToolbarAction.fixedSpace(width)` to add a specific amount of space between items:

```dart
CNToolbar(
  leading: [
    CNToolbarAction(
      label: 'Edit',
      onPressed: () => print('Edit'),
    ),
    const CNToolbarAction.fixedSpace(20), // 20pt space
    CNToolbarAction(
      label: 'Share',
      onPressed: () => print('Share'),
    ),
  ],
)
```

**When to use:**
- Between text-labeled buttons (recommended 20pt)
- To prevent buttons from appearing as a single combined action
- When you need precise control over spacing

### Flexible Space

Use `CNToolbarAction.flexibleSpace()` to add expandable space that fills available width:

```dart
CNToolbar(
  middle: [
    CNToolbarAction(
      icon: CNSymbol('star'),
      onPressed: () {},
    ),
    const CNToolbarAction.flexibleSpace(), // Expands to fill space
    CNToolbarAction(
      icon: CNSymbol('heart'),
      onPressed: () {},
    ),
  ],
)
```

**When to use:**
- To push items apart to opposite ends of a section
- For dynamic layouts that adapt to available space
- To create balanced visual spacing

## Best Practices

### 1. Text Label Separation
✅ **DO**: Add fixed space between text labels
```dart
leading: [
  CNToolbarAction(label: 'Edit', onPressed: () {}),
  const CNToolbarAction.fixedSpace(20),
  CNToolbarAction(label: 'Share', onPressed: () {}),
]
```

❌ **DON'T**: Place text labels directly next to each other
```dart
leading: [
  CNToolbarAction(label: 'Edit', onPressed: () {}),
  CNToolbarAction(label: 'Share', onPressed: () {}), // Text may run together
]
```

### 2. Icon and Text Mixing
✅ **DO**: Separate icons from text labels
```dart
middle: [
  CNToolbarAction(icon: CNSymbol('pencil'), onPressed: () {}),
  const CNToolbarAction.fixedSpace(16),
  CNToolbarAction(label: 'Edit', onPressed: () {}),
]
```

❌ **DON'T**: Place icons directly next to text
```dart
middle: [
  CNToolbarAction(icon: CNSymbol('pencil'), onPressed: () {}),
  CNToolbarAction(label: 'Edit', onPressed: () {}), // May appear as single action
]
```

### 3. Icon Spacing
Icons can be placed together without spacers, but adding small fixed spaces can improve clarity:

```dart
trailing: [
  CNToolbarAction(icon: CNSymbol('gear'), onPressed: () {}),
  const CNToolbarAction.fixedSpace(8), // Optional, improves touch targets
  CNToolbarAction(icon: CNSymbol('plus'), onPressed: () {}),
]
```

## Recommended Spacing Values

- **Between text labels**: 20pt
- **Between icon and text**: 16pt  
- **Between icons** (optional): 8pt
- **For dramatic separation**: 32pt+

## Implementation Notes

The native platforms handle spacers differently:
- **iOS**: Uses `UIBarButtonItem.fixedSpace` and `flexibleSpace`
- **macOS**: Uses NSLayoutConstraint spacing

Both implementations provide consistent visual results.
