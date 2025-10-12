import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Detent heights for resizable sheets (iOS only)
class CNSheetDetent {
  final String type;
  final double? height;
  
  const CNSheetDetent._(this.type, this.height);
  
  /// Medium height (~50% of screen)
  static const medium = CNSheetDetent._('medium', null);
  
  /// Large height (~100% of screen)
  static const large = CNSheetDetent._('large', null);
  
  /// Custom fixed height in points
  /// Example: CNSheetDetent.custom(300) for a 300pt tall sheet
  static CNSheetDetent custom(double height) => CNSheetDetent._('custom', height);
  
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      if (height != null) 'height': height,
    };
  }
}

/// An item to display in a native sheet
class CNSheetItem {
  final String? title;
  final String? icon;
  final bool dismissOnTap;
  
  /// Creates a simple sheet item with title and optional icon.
  /// This will be rendered natively using UISheetPresentationController.
  const CNSheetItem({
    required this.title,
    this.icon,
    this.dismissOnTap = true,
  });
  
  Map<String, dynamic> toMap() {
    return {
      if (title != null) 'title': title,
      if (icon != null) 'icon': icon,
      'dismissOnTap': dismissOnTap,
    };
  }
}

/// A native iOS/macOS sheet presentation using UIKit rendering.
/// 
/// Sheets are modal views that present scoped tasks closely related to the current context.
/// On iOS, sheets can be resizable with detents (medium/large heights).
/// On iPadOS, sheets use page or form sheet styles.
/// On macOS, sheets are always modal and attached to a window.
/// 
/// ## Nonmodal vs Modal Behavior
/// 
/// **Nonmodal Sheets** (like Apple Notes formatting sheet):
/// - User can interact with background content while sheet is open
/// - Can tap, scroll, and select in the parent view
/// - Sheet stays open during background interaction
/// - **Requires**: Set `isModal: false`
/// - Uses native UISheetPresentationController with `largestUndimmedDetentIdentifier`
/// 
/// **Modal Sheets** (default):
/// - Background is dimmed and non-interactive
/// - User must dismiss sheet before interacting with background
/// 
/// ## Usage
/// 
/// **Standard Sheet:**
/// ```dart
/// await CNNativeSheet.show(
///   context: context,
///   title: 'Settings',
///   items: [
///     CNSheetItem(title: 'Brightness', icon: 'sun.max'),
///     CNSheetItem(title: 'Appearance', icon: 'moon'),
///   ],
///   detents: [CNSheetDetent.medium],
/// );
/// ```
/// 
/// **Nonmodal Sheet:**
/// ```dart
/// await CNNativeSheet.show(
///   context: context,
///   title: 'Format',
///   items: [
///     CNSheetItem(title: 'Bold', icon: 'bold', dismissOnTap: false),
///     CNSheetItem(title: 'Italic', icon: 'italic', dismissOnTap: false),
///   ],
///   isModal: false,
/// );
/// ```
/// 
/// **Custom Header Sheet:**
/// ```dart
/// await CNNativeSheet.showWithCustomHeader(
///   context: context,
///   title: 'Format',
///   headerTitleWeight: FontWeight.w600,
///   items: [
///     CNSheetItem(title: 'Bold', icon: 'bold'),
///   ],
///   isModal: false,
/// );
/// ```
class CNNativeSheet {
  static const MethodChannel _channel = MethodChannel('cupertino_native_sheet');
  static const MethodChannel _customChannel = MethodChannel('cupertino_native_custom_sheet');
  
  /// Shows a native sheet with the given content.
  /// 
  /// Uses native UISheetPresentationController for rendering. All items are
  /// rendered as native UIKit components for optimal performance and true
  /// nonmodal behavior.
  /// 
  /// [title] - Optional title for the sheet (displays in content area with close button)
  /// [message] - Optional message below the title
  /// [items] - List of items to display in the sheet
  /// [detents] - Heights at which the sheet can rest (iOS only, defaults to [large])
  /// [prefersGrabberVisible] - Whether to show the grabber handle (iOS only)
  /// [isModal] - Whether the sheet is modal (blocks interaction with parent view).
  ///            Default is true. Set to false for nonmodal sheets that allow
  ///            background interaction (iOS/iPadOS only, always modal on macOS/visionOS/watchOS).
  /// [prefersEdgeAttachedInCompactHeight] - Whether sheet attaches to edge in compact height
  /// [widthFollowsPreferredContentSizeWhenEdgeAttached] - Whether width follows preferred content size
  /// [preferredCornerRadius] - Custom corner radius for the sheet
  /// [itemBackgroundColor] - Background color for sheet item buttons (default: clear)
  /// [itemTextColor] - Text color for sheet item buttons (default: system label)
  /// [itemTintColor] - Tint color for icons in sheet item buttons (default: system tint)
  static Future<int?> show({
    required BuildContext context,
    String? title,
    String? message,
    List<CNSheetItem> items = const [],
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = true,
    bool prefersEdgeAttachedInCompactHeight = false,
    bool widthFollowsPreferredContentSizeWhenEdgeAttached = false,
    double? preferredCornerRadius,
    Color? itemBackgroundColor,
    Color? itemTextColor,
    Color? itemTintColor,
  }) async {
    try {
      final result = await _channel.invokeMethod('showSheet', {
        'title': title,
        'message': message,
        'items': items.map((item) => item.toMap()).toList(),
        'detents': detents.map((d) => d.toMap()).toList(),
        'prefersGrabberVisible': prefersGrabberVisible,
        'isModal': isModal,
        'prefersEdgeAttachedInCompactHeight': prefersEdgeAttachedInCompactHeight,
        'widthFollowsPreferredContentSizeWhenEdgeAttached': widthFollowsPreferredContentSizeWhenEdgeAttached,
        'preferredCornerRadius': preferredCornerRadius,
        if (itemBackgroundColor != null) 'itemBackgroundColor': itemBackgroundColor.value,
        if (itemTextColor != null) 'itemTextColor': itemTextColor.value,
        if (itemTintColor != null) 'itemTintColor': itemTintColor.value,
      });
      
      if (result is Map) {
        return result['selectedIndex'] as int?;
      }
      return null;
    } catch (e) {
      debugPrint('Error showing native sheet: $e');
      return null;
    }
  }
  
  /// Shows a native sheet with custom header (title + close button).
  /// 
  /// This is like the Apple Notes formatting sheet - it has a custom header bar
  /// with the title on the left and a close button (X) on the right.
  /// 
  /// **Key differences from `show()`:**
  /// - Custom header with title and close button (like Notes app)
  /// - Title is displayed in the header bar, not in the content area
  /// - Close button allows manual dismissal
  /// - Still supports nonmodal behavior with `isModal: false`
  /// - Full control over header styling
  /// 
  /// **Example:**
  /// ```dart
  /// await CNNativeSheet.showWithCustomHeader(
  ///   context: context,
  ///   title: 'Format',
  ///   headerTitleSize: 20,
  ///   headerTitleWeight: FontWeight.w600,
  ///   headerHeight: 56,
  ///   items: [
  ///     CNSheetItem(title: 'Bold', icon: 'bold'),
  ///     CNSheetItem(title: 'Italic', icon: 'italic'),
  ///   ],
  ///   detents: [CNSheetDetent.custom(280)],
  ///   isModal: false, // Nonmodal - can interact with background
  /// );
  /// ```
  /// 
  /// [title] - Title displayed in the header (required for custom header)
  /// [message] - Optional message below the header
  /// [items] - List of items to display
  /// [detents] - Heights at which the sheet can rest
  /// [prefersGrabberVisible] - Whether to show the grabber handle
  /// [isModal] - Whether the sheet blocks background interaction
  /// 
  /// **Header Styling Options:**
  /// [headerTitleSize] - Font size for the title (default: 20)
  /// [headerTitleWeight] - Font weight for the title (default: semibold/600)
  /// [headerTitleColor] - Color for the title (default: label color)
  /// [headerHeight] - Height of the header bar (default: 56)
  /// [headerBackgroundColor] - Background color of the header (default: system background)
  /// [showHeaderDivider] - Whether to show divider below header (default: true)
  /// [headerDividerColor] - Color of the header divider (default: separator color)
  /// [closeButtonPosition] - Position of close button: 'leading' or 'trailing' (default: 'trailing')
  /// [closeButtonIcon] - SF Symbol name for close button (default: 'xmark')
  /// [closeButtonSize] - Size of the close button icon (default: 17)
  /// [closeButtonColor] - Color of the close button (default: label color)
  /// [itemBackgroundColor] - Background color for sheet item buttons (default: clear)
  /// [itemTextColor] - Text color for sheet item buttons (default: system label)
  /// [itemTintColor] - Tint color for icons in sheet item buttons (default: system tint)
  static Future<int?> showWithCustomHeader({
    required BuildContext context,
    required String title,
    String? message,
    List<CNSheetItem> items = const [],
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = true,
    bool prefersEdgeAttachedInCompactHeight = false,
    bool widthFollowsPreferredContentSizeWhenEdgeAttached = false,
    double? preferredCornerRadius,
    // Header styling
    double? headerTitleSize,
    FontWeight? headerTitleWeight,
    Color? headerTitleColor,
    double? headerHeight,
    Color? headerBackgroundColor,
    bool showHeaderDivider = true,
    Color? headerDividerColor,
    String closeButtonPosition = 'trailing',
    String closeButtonIcon = 'xmark',
    double? closeButtonSize,
    Color? closeButtonColor,
    // Item styling
    Color? itemBackgroundColor,
    Color? itemTextColor,
    Color? itemTintColor,
  }) async {
    try {
      final result = await _customChannel.invokeMethod('showSheet', {
        'title': title,
        'message': message,
        'items': items.map((item) => item.toMap()).toList(),
        'detents': detents.map((d) => d.toMap()).toList(),
        'prefersGrabberVisible': prefersGrabberVisible,
        'isModal': isModal,
        'prefersEdgeAttachedInCompactHeight': prefersEdgeAttachedInCompactHeight,
        'widthFollowsPreferredContentSizeWhenEdgeAttached': widthFollowsPreferredContentSizeWhenEdgeAttached,
        'preferredCornerRadius': preferredCornerRadius,
        // Header styling parameters
        if (headerTitleSize != null) 'headerTitleSize': headerTitleSize,
        if (headerTitleWeight != null) 'headerTitleWeight': _fontWeightToString(headerTitleWeight),
        if (headerTitleColor != null) 'headerTitleColor': headerTitleColor.value,
        if (headerHeight != null) 'headerHeight': headerHeight,
        if (headerBackgroundColor != null) 'headerBackgroundColor': headerBackgroundColor.value,
        'showHeaderDivider': showHeaderDivider,
        if (headerDividerColor != null) 'headerDividerColor': headerDividerColor.value,
        'closeButtonPosition': closeButtonPosition,
        'closeButtonIcon': closeButtonIcon,
        if (closeButtonSize != null) 'closeButtonSize': closeButtonSize,
        if (closeButtonColor != null) 'closeButtonColor': closeButtonColor.value,
        // Item styling parameters
        if (itemBackgroundColor != null) 'itemBackgroundColor': itemBackgroundColor.value,
        if (itemTextColor != null) 'itemTextColor': itemTextColor.value,
        if (itemTintColor != null) 'itemTintColor': itemTintColor.value,
      });
      
      if (result is Map) {
        return result['selectedIndex'] as int?;
      }
      return null;
    } catch (e) {
      debugPrint('Error showing native custom header sheet: $e');
      return null;
    }
  }
  
  // Helper to convert FontWeight to string for native side
  static String _fontWeightToString(FontWeight weight) {
    if (weight == FontWeight.w100) return 'ultraLight';
    if (weight == FontWeight.w200) return 'thin';
    if (weight == FontWeight.w300) return 'light';
    if (weight == FontWeight.w400) return 'regular';
    if (weight == FontWeight.w500) return 'medium';
    if (weight == FontWeight.w600) return 'semibold';
    if (weight == FontWeight.w700) return 'bold';
    if (weight == FontWeight.w800) return 'heavy';
    if (weight == FontWeight.w900) return 'black';
    return 'regular';
  }
}
