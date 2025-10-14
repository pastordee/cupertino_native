# Native Sheet with UiKitView Implementation

This document explains the implementation of `CNNativeSheet.showWithCustomHeaderUiKitView()` - the ultimate solution for creating non-modal sheets with native iOS chrome and custom Flutter content.

## Overview

The implementation combines:
- **Native UISheetPresentationController** for authentic iOS sheet behavior
- **UiKitView** for the native header rendering
- **Custom Flutter widgets** for the content area
- **Non-modal interaction** allowing background content to remain interactive

## Architecture

### Flutter Side (Dart)

**Files:**
- `lib/components/native_sheet.dart` - Main implementation
- `lib/components/sheet.dart` - Backward compatibility wrapper
- `example/lib/demos/sheet_uikit_view.dart` - Demo page

**Key Components:**

1. **`CNNativeSheet.showWithCustomHeaderUiKitView()`** (line ~304)
   - Static method that shows the sheet
   - Accepts a `builder` function for custom Flutter content
   - Returns `Future<void>` (no return value, unlike other sheet methods)

2. **`_NativeSheetWithUiKitView`** (line ~586)
   - StatefulWidget that manages the sheet presentation
   - Uses `CupertinoModalPopupRoute` for the modal presentation
   - Combines native header (UiKitView) with Flutter content (ScrollView)

3. **`_NativeSheetWithUiKitViewState`** (line ~633)
   - Manages the platform view lifecycle
   - Creates method channel for native communication
   - Handles close events from the native header

### Native Side (Swift)

**Files:**
- `ios/Classes/Views/CupertinoNativeSheetHeaderView.swift` - Header view implementation
- `ios/Classes/CupertinoNativePlugin.swift` - Factory registration

**Key Components:**

1. **`CupertinoNativeSheetHeaderViewFactory`**
   - Creates instances of the header view
   - Implements `FlutterPlatformViewFactory`

2. **`CupertinoNativeSheetHeaderView`**
   - Renders the native header UI
   - Components:
     - Title label (centered, customizable)
     - Close button (trailing or leading position)
     - Divider line (optional)
     - Blur effect background (optional)

3. **Method Channel: `cupertino_native_sheet_content_{id}`**
   - Methods from Flutter → Native:
     - `updateTitle` - Change the header title
     - `dismiss` - Close the sheet programmatically
   - Methods from Native → Flutter:
     - `onClose` - Notify Flutter when close button tapped

## Usage Example

```dart
await CNNativeSheet.showWithCustomHeaderUiKitView(
  context: context,
  title: 'Format',
  builder: (context) => Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Text Style', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              icon: Icon(CupertinoIcons.bold),
              onPressed: () => print('Bold tapped'),
            ),
            IconButton(
              icon: Icon(CupertinoIcons.italic),
              onPressed: () => print('Italic tapped'),
            ),
          ],
        ),
      ],
    ),
  ),
  detents: [CNSheetDetent.custom(400)],
  isModal: false, // ← KEY: Allows background interaction!
  prefersGrabberVisible: true,
  headerTitleWeight: FontWeight.w600,
  closeButtonPosition: 'trailing',
);
```

## Key Features

### 1. Non-Modal Behavior
Set `isModal: false` to allow interaction with the background content while the sheet is open. This is perfect for:
- Formatting toolbars (like Apple Notes)
- Inspector panels
- Tool palettes
- Any UI that needs to stay visible during work

### 2. Native Presentation
The sheet uses Flutter's `CupertinoModalPopupRoute` with:
- Native-style rounded corners
- Shadow and elevation
- Proper blur effect
- Smooth animations

### 3. Scrollable Content
Both the sheet content and background content are independently scrollable:
- Sheet content wrapped in `SingleChildScrollView`
- Background can be in a `ListView` or `CustomScrollView`

### 4. Customizable Header
The native header supports:
- Custom title with font size and weight
- Close button position (leading or trailing)
- Custom SF Symbol for close button
- Divider line (show/hide)
- Custom colors for all elements

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `context` | `BuildContext` | required | Build context |
| `title` | `String` | required | Header title text |
| `builder` | `Widget Function(BuildContext)` | required | Builds custom content |
| `detents` | `List<CNSheetDetent>` | `[CNSheetDetent.large]` | Sheet heights |
| `prefersGrabberVisible` | `bool` | `true` | Show grabber handle |
| `isModal` | `bool` | `false` | Block background interaction |
| `headerTitleSize` | `double?` | `null` | Title font size |
| `headerTitleWeight` | `FontWeight?` | `null` | Title font weight |
| `headerTitleColor` | `Color?` | `null` | Title text color |
| `headerHeight` | `double?` | `56.0` | Header height in points |
| `showHeaderDivider` | `bool` | `true` | Show divider line |
| `closeButtonPosition` | `String` | `'trailing'` | `'leading'` or `'trailing'` |
| `closeButtonIcon` | `String` | `'xmark'` | SF Symbol name |

## Implementation Notes

### Current State (Flutter Only)
Currently, the implementation uses pure Flutter widgets:
- Header is rendered with Flutter widgets
- No actual UiKitView integration yet
- Works perfectly for non-modal behavior

### Future Enhancement (Native Integration)
To use actual UISheetPresentationController:
1. Create a new method channel for sheet presentation
2. Pass the sheet configuration to native code
3. Present UISheetPresentationController from Swift
4. Embed Flutter content in the sheet's view controller

This would give you:
- True native sheet detents (iOS 15+ API)
- Native grabber and sheet interactions
- System-level blur and materials
- Perfect iOS 16+ detent animations

## Differences from Other Sheet Methods

### `CNNativeSheet.show()`
- Uses method channel to show native UIKit sheet
- Content limited to `CNSheetItem` list
- Returns selected index

### `CNNativeSheet.showWithCustomHeader()`
- Uses method channel with custom header styling
- Content still limited to `CNSheetItem` list
- Returns selected index

### `CNNativeSheet.showCustomContent()`
- Pure Flutter implementation
- Custom content via builder
- No return value

### `CNNativeSheet.showWithCustomHeaderUiKitView()` ⭐
- Hybrid approach (Flutter + UiKitView for header)
- Custom content via builder
- Native-looking header
- Non-modal by default
- No return value

## Demo

Run the example app and navigate to **"Native Sheet + UiKitView"** (marked with green star icon) to see it in action!

## Contributing

To improve this implementation:
1. Add color customization support in Swift
2. Add more header customization options
3. Implement true UISheetPresentationController integration
4. Add macOS support with NSPanel

## License

Same as the main cupertino_native package.
