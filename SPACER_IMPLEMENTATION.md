# Toolbar Spacer Implementation

## Overview
Added support for fixed and flexible spacing between toolbar items in `CNToolbar`, following Apple Human Interface Guidelines.

## Dart API (Complete)

### New Constructors
- `CNToolbarAction.fixedSpace(double width)` - Creates a fixed-width spacer
- `CNToolbarAction.flexedSpace()` - Creates a flexible (expandable) spacer

### Implementation Details
- Added `_isFixedSpace` and `_isFlexibleSpace` flags to `CNToolbarAction`
- Added getters: `isSpacer`, `isFixedSpace`, `isFlexibleSpace`
- For spacers, icons/labels are sent as empty strings
- For fixed spacers, the width is stored in the `padding` field
- Data sent to native platforms includes spacer type arrays:
  - `leadingSpacers`: Array of `'fixed'`, `'flexible'`, or `''` (empty for buttons)
  - `middleSpacers`: Same format
  - `trailingSpacers`: Same format

## iOS Implementation (Complete) ✅

### Changes to `CupertinoNavigationBarPlatformView.swift`

#### 1. Added Spacer Array Variables
```swift
var leadingSpacers: [String] = []
var middleSpacers: [String] = []
var trailingSpacers: [String] = []
```

#### 2. Parse Spacer Arrays from Initialization Dict
```swift
leadingSpacers = (dict["leadingSpacers"] as? [String]) ?? []
middleSpacers = (dict["middleSpacers"] as? [String]) ?? []
trailingSpacers = (dict["trailingSpacers"] as? [String]) ?? []
```

#### 3. Refactored Button Creation
Changed from creating one button group with all buttons to creating individual button groups with spacers:

**Before:**
```swift
let buttonGroup = createButtonGroup(icons: leadingIcons, labels: leadingLabels, ...)
let barItem = UIBarButtonItem(customView: buttonGroup)
navigationItem.leftBarButtonItems = [barItem]
```

**After:**
```swift
var barItems: [UIBarButtonItem] = []
for i in 0..<count {
  let spacerType = i < leadingSpacers.count ? leadingSpacers[i] : ""
  
  if spacerType == "flexible" {
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, ...)
    barItems.append(flexibleSpace)
  } else if spacerType == "fixed" {
    let width = i < leadingPaddings.count ? CGFloat(leadingPaddings[i]) : 8.0
    let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, ...)
    fixedSpace.width = width
    barItems.append(fixedSpace)
  } else {
    // Create single-item button group
    let buttonGroup = createButtonGroup(icons: [icon], labels: [label], ...)
    // Update button tag to match original index
    if let button = findButton(in: buttonGroup) {
      button.tag = i
    }
    let barItem = UIBarButtonItem(customView: buttonGroup)
    barItems.append(barItem)
  }
}
navigationItem.leftBarButtonItems = barItems
```

#### 4. Added Helper Function
```swift
private func findButton(in view: UIView) -> UIButton? {
  if let button = view as? UIButton {
    return button
  }
  for subview in view.subviews {
    if let button = findButton(in: subview) {
      return button
    }
  }
  return nil
}
```

### Key Implementation Notes

1. **UIBarButtonItem System Items**: iOS provides built-in spacer types:
   - `.flexibleSpace` - Expands to fill available space
   - `.fixedSpace` - Fixed width specified by `width` property

2. **Button Tags**: Since we now create single-item button groups, the button's tag inside is always 0. We use `findButton(in:)` to locate the button and update its tag to match the original index for tap handling.

3. **Middle Alignment**: Updated to use `append(contentsOf:)` for arrays instead of appending single items.

4. **All Three Sections**: Applied spacer logic to leading, middle, and trailing sections consistently.

## macOS Implementation (Pending) ⚠️

### Current Status
- Spacer arrays are parsed from initialization dict ✅
- Button creation logic NOT yet updated ❌

### Implementation Plan

macOS uses `NSLayoutConstraint` instead of bar button items, so the approach is different:

1. **For Fixed Spacing:**
   - Skip button creation for spacer items
   - Add spacing between adjacent buttons using constraints
   - Example: `button2.leadingAnchor.constraint(equalTo: button1.trailingAnchor, constant: width)`

2. **For Flexible Spacing:**
   - Add spacer views with low priority constraints
   - Or use constraint priorities to make spacing flexible
   - Example: Use a spacer view with `setContentHuggingPriority(.defaultLow, for: .horizontal)`

3. **Constraint Management:**
   - Need to track which constraints to activate/deactivate
   - Consider using `NSStackView` with custom spacing
   - May need to refactor button group creation to handle individual buttons

### Files to Update
- `/Users/prayercircle/Development/cupertino_native/macos/Classes/Views/CupertinoNavigationBarNSView.swift`
  - Update button creation sections (lines ~115, ~138, ~162)
  - Modify `createButtonGroup` or create alternative approach
  - Add constraint logic for fixed/flexible spacing

## Testing

### iOS Testing (Complete) ✅
- App builds successfully ✅
- Top toolbar displays with icon spacing ✅
- Bottom toolbar displays with text label spacing ✅
- Button taps work correctly ✅
- All three alignment modes work ✅

### macOS Testing (Pending)
- Not yet implemented

## Example Usage

```dart
CNToolbar(
  leading: [
    CNToolbarAction(
      label: 'Edit',
      onPressed: () => print('Edit tapped'),
    ),
    const CNToolbarAction.fixedSpace(20), // 20pt fixed space
    CNToolbarAction(
      label: 'Share',
      onPressed: () => print('Share tapped'),
    ),
  ],
  middle: [
    CNToolbarAction(
      icon: CNSymbol('pencil'),
      onPressed: () => print('Edit tapped'),
    ),
    const CNToolbarAction.fixedSpace(16), // 16pt spacing between icons
    CNToolbarAction(
      icon: CNSymbol('trash'),
      onPressed: () => print('Delete tapped'),
    ),
  ],
  trailing: [
    CNToolbarAction(
      icon: CNSymbol('gear'),
      onPressed: () => print('Settings tapped'),
    ),
    const CNToolbarAction.flexibleSpace(), // Flexible spacing
    CNToolbarAction(
      icon: CNSymbol('plus'),
      onPressed: () => print('Add tapped'),
    ),
  ],
)
```

## HIG Compliance

### Text Labels
- **Requirement**: 20pt minimum spacing between text-labeled buttons
- **Implementation**: Use `fixedSpace(20)` between text labels
- **Rationale**: Prevents visual confusion, improves touch targets

### Icons
- **Recommendation**: 8-16pt spacing between icons (optional)
- **Implementation**: Use `fixedSpace(8)` or `fixedSpace(16)`
- **Rationale**: Improves visual separation and touch targets

### Flexible Spacing
- **Use Case**: Distributing items across toolbar width
- **Implementation**: `flexibleSpace()` between groups
- **Result**: Items position themselves with equal spacing

## Documentation

See `TOOLBAR_SPACING.md` for user-facing documentation and best practices.

## Next Steps

1. **macOS Implementation** (High Priority)
   - Implement constraint-based spacing for fixed spacers
   - Implement flexible spacing with constraint priorities
   - Test all spacing combinations on macOS

2. **Testing** (Medium Priority)
   - Add unit tests for spacer data mapping
   - Add integration tests for spacing behavior
   - Test edge cases (empty sections, only spacers, etc.)

3. **Documentation** (Low Priority)
   - Add more examples to TOOLBAR_SPACING.md
   - Add screenshots showing spacing effects
   - Document constraint-based approach for macOS

## Known Issues

1. **macOS Not Implemented**: Spacer arrays are parsed but not yet used in button creation
2. **Hot Reload**: Changes to toolbar may require full restart (Flutter limitation)

## References

- Apple HIG: Toolbars (iOS) - [developer.apple.com](https://developer.apple.com/design/human-interface-guidelines/toolbars)
- Apple HIG: Toolbars (macOS) - [developer.apple.com](https://developer.apple.com/design/human-interface-guidelines/toolbars)
- UIBarButtonItem Documentation - [developer.apple.com](https://developer.apple.com/documentation/uikit/uibarbuttonitem)
- NSLayoutConstraint Documentation - [developer.apple.com](https://developer.apple.com/documentation/appkit/nslayoutconstraint)
