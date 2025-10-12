import 'package:flutter/services.dart';

/// Style for alert buttons.
enum CNAlertActionStyle {
  /// Default style for standard actions.
  defaultStyle,

  /// Style for cancel actions (bold text).
  cancel,

  /// Style for destructive actions (red text).
  destructive,
}

/// Represents an action button in an alert.
class CNAlertAction {
  /// The title displayed on the button.
  final String title;

  /// The style of the button.
  final CNAlertActionStyle style;

  /// Callback when the button is tapped.
  final VoidCallback? onPressed;

  /// Creates an alert action.
  const CNAlertAction({
    required this.title,
    this.style = CNAlertActionStyle.defaultStyle,
    this.onPressed,
  });

  /// Converts the action to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'style': style.index,
    };
  }
}

/// A native iOS/macOS alert dialog.
///
/// Alerts give people critical information they need right away. Use alerts
/// sparingly and only for important, actionable information.
///
/// Example:
/// ```dart
/// await CNAlert.show(
///   context: context,
///   title: 'Delete Photo',
///   message: 'Are you sure you want to delete this photo? This action cannot be undone.',
///   actions: [
///     CNAlertAction(
///       title: 'Cancel',
///       style: CNAlertActionStyle.cancel,
///     ),
///     CNAlertAction(
///       title: 'Delete',
///       style: CNAlertActionStyle.destructive,
///       onPressed: () {
///         // Perform delete action
///       },
///     ),
///   ],
/// );
/// ```
class CNAlert {
  static const MethodChannel _channel =
      MethodChannel('cupertino_native_alert');

  /// Shows a native alert dialog.
  ///
  /// - [title]: The title of the alert (required).
  /// - [message]: Optional informative text that adds value.
  /// - [actions]: List of action buttons (up to 3 recommended).
  /// - [preferredActionIndex]: Index of the preferred (default) action.
  ///
  /// Returns the index of the action that was tapped, or null if dismissed.
  static Future<int?> show({
    required String title,
    String? message,
    required List<CNAlertAction> actions,
    int? preferredActionIndex,
  }) async {
    if (actions.isEmpty) {
      throw ArgumentError('Alert must have at least one action');
    }

    if (preferredActionIndex != null &&
        (preferredActionIndex < 0 || preferredActionIndex >= actions.length)) {
      throw ArgumentError('preferredActionIndex out of range');
    }

    try {
      final result = await _channel.invokeMethod<int>('showAlert', {
        'title': title,
        'message': message,
        'actions': actions.map((a) => a.toMap()).toList(),
        'preferredActionIndex': preferredActionIndex,
      });

      // Execute the callback for the selected action
      if (result != null && result >= 0 && result < actions.length) {
        actions[result].onPressed?.call();
      }

      return result;
    } catch (e) {
      print('Error showing alert: $e');
      return null;
    }
  }

  /// Shows a simple informational alert with an OK button.
  static Future<void> showInfo({
    required String title,
    String? message,
  }) async {
    await show(
      title: title,
      message: message,
      actions: [
        CNAlertAction(
          title: 'OK',
          style: CNAlertActionStyle.defaultStyle,
        ),
      ],
    );
  }

  /// Shows a confirmation alert with Cancel and Confirm buttons.
  static Future<bool> showConfirmation({
    required String title,
    String? message,
    String confirmTitle = 'Confirm',
    VoidCallback? onConfirm,
  }) async {
    final result = await show(
      title: title,
      message: message,
      actions: [
        CNAlertAction(
          title: 'Cancel',
          style: CNAlertActionStyle.cancel,
        ),
        CNAlertAction(
          title: confirmTitle,
          style: CNAlertActionStyle.defaultStyle,
          onPressed: onConfirm,
        ),
      ],
      preferredActionIndex: 1, // Confirm button is preferred
    );

    return result == 1; // Returns true if Confirm was tapped
  }

  /// Shows a destructive confirmation alert.
  static Future<bool> showDestructiveConfirmation({
    required String title,
    String? message,
    required String destructiveTitle,
    VoidCallback? onDestroy,
  }) async {
    final result = await show(
      title: title,
      message: message,
      actions: [
        CNAlertAction(
          title: 'Cancel',
          style: CNAlertActionStyle.cancel,
        ),
        CNAlertAction(
          title: destructiveTitle,
          style: CNAlertActionStyle.destructive,
          onPressed: onDestroy,
        ),
      ],
    );

    return result == 1; // Returns true if destructive action was tapped
  }
}
