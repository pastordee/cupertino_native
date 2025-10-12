// Backward compatibility wrapper for sheet components
// This file provides a CNSheet class that delegates to the appropriate implementation.
//
// For new code, prefer using:
// - CNNativeSheet for native UIKit rendering
// - CNCustomSheet for custom Flutter widget rendering

import 'native_sheet.dart';

// Re-export everything from both modules
export 'native_sheet.dart';
export 'custom_sheet.dart';

/// Backward compatibility class for CNSheet
/// 
/// Delegates to CNNativeSheet for native rendering.
/// This maintains API compatibility with existing code.
class CNSheet {
  /// Shows a native sheet (delegates to CNNativeSheet)
  static Future<int?> show({
    required context,
    String? title,
    String? message,
    List<CNSheetItem> items = const [],
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = true,
    bool prefersEdgeAttachedInCompactHeight = false,
    bool widthFollowsPreferredContentSizeWhenEdgeAttached = false,
    double? preferredCornerRadius,
    itemBackgroundColor,
    itemTextColor,
    itemTintColor,
  }) {
    return CNNativeSheet.show(
      context: context,
      title: title,
      message: message,
      items: items,
      detents: detents,
      prefersGrabberVisible: prefersGrabberVisible,
      isModal: isModal,
      prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight,
      widthFollowsPreferredContentSizeWhenEdgeAttached: widthFollowsPreferredContentSizeWhenEdgeAttached,
      preferredCornerRadius: preferredCornerRadius,
      itemBackgroundColor: itemBackgroundColor,
      itemTextColor: itemTextColor,
      itemTintColor: itemTintColor,
    );
  }
  
  /// Shows a sheet with custom header (delegates to CNNativeSheet)
  static Future<int?> showWithCustomHeader({
    required context,
    required String title,
    String? message,
    List<CNSheetItem> items = const [],
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = true,
    bool prefersEdgeAttachedInCompactHeight = false,
    bool widthFollowsPreferredContentSizeWhenEdgeAttached = false,
    double? preferredCornerRadius,
    double? headerTitleSize,
    headerTitleWeight,
    headerTitleColor,
    double? headerHeight,
    headerBackgroundColor,
    bool showHeaderDivider = true,
    headerDividerColor,
    String closeButtonPosition = 'trailing',
    String closeButtonIcon = 'xmark',
    double? closeButtonSize,
    closeButtonColor,
    itemBackgroundColor,
    itemTextColor,
    itemTintColor,
  }) {
    return CNNativeSheet.showWithCustomHeader(
      context: context,
      title: title,
      message: message,
      items: items,
      detents: detents,
      prefersGrabberVisible: prefersGrabberVisible,
      isModal: isModal,
      prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight,
      widthFollowsPreferredContentSizeWhenEdgeAttached: widthFollowsPreferredContentSizeWhenEdgeAttached,
      preferredCornerRadius: preferredCornerRadius,
      headerTitleSize: headerTitleSize,
      headerTitleWeight: headerTitleWeight,
      headerTitleColor: headerTitleColor,
      headerHeight: headerHeight,
      headerBackgroundColor: headerBackgroundColor,
      showHeaderDivider: showHeaderDivider,
      headerDividerColor: headerDividerColor,
      closeButtonPosition: closeButtonPosition,
      closeButtonIcon: closeButtonIcon,
      closeButtonSize: closeButtonSize,
      closeButtonColor: closeButtonColor,
      itemBackgroundColor: itemBackgroundColor,
      itemTextColor: itemTextColor,
      itemTintColor: itemTintColor,
    );
  }
}
