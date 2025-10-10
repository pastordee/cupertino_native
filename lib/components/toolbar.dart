import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';

/// Alignment options for middle toolbar actions.
enum CNToolbarMiddleAlignment {
  /// Position middle close to leading (left side).
  leading,
  
  /// Position middle in the center.
  center,
  
  /// Position middle close to trailing (right side).
  trailing,
}

/// Action item for toolbar trailing/leading positions.
class CNToolbarAction {
  /// Creates a toolbar action item.
  const CNToolbarAction({
    this.icon,
    this.label,
    this.onPressed,
    this.padding,
  });

  /// SF Symbol icon for the action.
  final CNSymbol? icon;

  /// Text label for the action (used if icon is null).
  final String? label;

  /// Callback when the action is tapped.
  final VoidCallback? onPressed;

  /// Custom padding for this action. If null, uses default platform padding.
  /// Specified in logical pixels.
  final double? padding;
}

/// A Cupertino-native toolbar with liquid glass translucent effect.
///
/// Uses native UINavigationBar on iOS and NSToolbar on macOS for authentic
/// translucent blur effects. The toolbar automatically blurs content
/// behind it, creating the signature iOS/macOS "liquid glass" appearance.
class CNToolbar extends StatefulWidget {
  /// Creates a native translucent toolbar.
  const CNToolbar({
    super.key,
    this.leading,
    this.middle,
    this.trailing,
    this.middleAlignment = CNToolbarMiddleAlignment.center,
    this.transparent = false,
    this.tint,
    this.height,
    this.pillHeight,
  });

  /// Leading actions (buttons/icons on the left).
  final List<CNToolbarAction>? leading;

  /// Middle actions (buttons/icons in the center).
  final List<CNToolbarAction>? middle;

  /// Trailing actions (buttons/icons on the right).
  final List<CNToolbarAction>? trailing;

  /// Alignment of middle actions.
  /// - [CNToolbarMiddleAlignment.leading]: Position close to leading
  /// - [CNToolbarMiddleAlignment.center]: Position in center (default)
  /// - [CNToolbarMiddleAlignment.trailing]: Position close to trailing
  final CNToolbarMiddleAlignment middleAlignment;

  /// Use completely transparent background (no blur).
  final bool transparent;

  /// Tint color for buttons and icons.
  final Color? tint;

  /// Fixed height (if null, uses intrinsic platform height).
  final double? height;

  /// Height of button group pills. If null, uses default platform height.
  /// Controls the vertical size of the pill-shaped button groups.
  final double? pillHeight;

  @override
  State<CNToolbar> createState() => _CNToolbarState();
}

class _CNToolbarState extends State<CNToolbar> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  bool? _lastIsDark;
  String? _lastTitle;
  int? _lastTint;
  bool? _lastTransparent;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;
  Color? get _effectiveTint =>
      widget.tint ?? CupertinoTheme.of(context).primaryColor;

  @override
  void didUpdateWidget(covariant CNToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      // Fallback for non-Apple platforms
      return CupertinoNavigationBar(
        leading: widget.leading != null && widget.leading!.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.leading!.first.onPressed,
                child: Icon(CupertinoIcons.back),
              )
            : null,
        trailing: widget.trailing != null && widget.trailing!.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.trailing!.first.onPressed,
                child: Icon(CupertinoIcons.ellipsis_circle),
              )
            : null,
        backgroundColor: widget.transparent ? CupertinoColors.transparent : null,
      );
    }

    final leadingIcons =
        widget.leading?.map((e) => e.icon?.name ?? '').toList() ?? [];
    final leadingLabels =
        widget.leading?.map((e) => e.label ?? '').toList() ?? [];
    final leadingPaddings =
        widget.leading?.map((e) => e.padding ?? 0.0).toList() ?? [];
    final middleIcons =
        widget.middle?.map((e) => e.icon?.name ?? '').toList() ?? [];
    final middleLabels =
        widget.middle?.map((e) => e.label ?? '').toList() ?? [];
    final middlePaddings =
        widget.middle?.map((e) => e.padding ?? 0.0).toList() ?? [];
    final trailingIcons =
        widget.trailing?.map((e) => e.icon?.name ?? '').toList() ?? [];
    final trailingLabels =
        widget.trailing?.map((e) => e.label ?? '').toList() ?? [];
    final trailingPaddings =
        widget.trailing?.map((e) => e.padding ?? 0.0).toList() ?? [];

    final creationParams = <String, dynamic>{
      'title': '',
      'leadingIcons': leadingIcons,
      'leadingLabels': leadingLabels,
      'leadingPaddings': leadingPaddings,
      'middleIcons': middleIcons,
      'middleLabels': middleLabels,
      'middlePaddings': middlePaddings,
      'middleAlignment': widget.middleAlignment.name,
      'trailingIcons': trailingIcons,
      'trailingLabels': trailingLabels,
      'trailingPaddings': trailingPaddings,
      'transparent': widget.transparent,
      'isDark': _isDark,
      'style': encodeStyle(context, tint: _effectiveTint),
      'pillHeight': widget.pillHeight,
    };

    final viewType = 'CupertinoNativeNavigationBar';
    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
          )
        : AppKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
          );

    final h = widget.height ?? _intrinsicHeight ?? 44.0;
    return SizedBox(height: h, child: platformView);
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeNavigationBar_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTitle = '';
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastIsDark = _isDark;
    _lastTransparent = widget.transparent;
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'leadingTapped') {
      final args = call.arguments as Map?;
      final index = (args?['index'] as num?)?.toInt() ?? 0;
      if (index >= 0 &&
          widget.leading != null &&
          index < widget.leading!.length) {
        widget.leading![index].onPressed?.call();
      }
    } else if (call.method == 'middleTapped') {
      final args = call.arguments as Map?;
      final index = (args?['index'] as num?)?.toInt() ?? 0;
      if (index >= 0 &&
          widget.middle != null &&
          index < widget.middle!.length) {
        widget.middle![index].onPressed?.call();
      }
    } else if (call.method == 'trailingTapped') {
      final args = call.arguments as Map?;
      final index = (args?['index'] as num?)?.toInt() ?? 0;
      if (index >= 0 &&
          widget.trailing != null &&
          index < widget.trailing!.length) {
        widget.trailing![index].onPressed?.call();
      }
    }
    return null;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;

    final title = '';
    final tint = resolveColorToArgb(_effectiveTint, context);
    final transparent = widget.transparent;

    if (_lastTitle != title) {
      await ch.invokeMethod('setTitle', {'title': title});
      _lastTitle = title;
    }

    final style = <String, dynamic>{};
    if (_lastTint != tint && tint != null) {
      style['tint'] = tint;
      _lastTint = tint;
    }
    if (_lastTransparent != transparent) {
      style['transparent'] = transparent;
      _lastTransparent = transparent;
    }
    if (style.isNotEmpty) {
      await ch.invokeMethod('setStyle', style);
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    final isDark = _isDark;
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
  }

  Future<void> _requestIntrinsicSize() async {
    if (widget.height != null) return;
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final h = (size?['height'] as num?)?.toDouble();
      if (!mounted) return;
      setState(() {
        if (h != null && h > 0) _intrinsicHeight = h;
      });
    } catch (_) {}
  }
}
