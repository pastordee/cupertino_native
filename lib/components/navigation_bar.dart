import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';

/// Action item for navigation bar trailing/leading positions.
class CNNavigationBarAction { 
  /// Creates a navigation bar action item.
  const CNNavigationBarAction({
    this.icon,
    this.label,
    this.padding = 0,
    this.onPressed,
  });

  /// SF Symbol icon for the action.
  final CNSymbol? icon;

  /// Text label for the action (used if icon is null).
  final String? label;

  /// Horizontal padding around the button (increases button width).
  final double padding;

  /// Callback when the action is tapped.
  final VoidCallback? onPressed;
}

/// A Cupertino-native navigation bar with liquid glass translucent effect.
///
/// Uses native UINavigationBar on iOS and NSToolbar on macOS for authentic
/// translucent blur effects. The navigation bar automatically blurs content
/// behind it, creating the signature iOS/macOS "liquid glass" appearance.
class CNNavigationBar extends StatefulWidget {
  /// Creates a native translucent navigation bar.
  const CNNavigationBar({
    super.key,
    this.leading,
    this.title,
    this.trailing,
    this.largeTitle = false,
    this.transparent = true,
    this.tint,
    this.height,
  });

  /// Leading actions (typically back button, can include multiple items).
  final List<CNNavigationBarAction>? leading;

  /// Title text for the navigation bar.
  final String? title;

  /// Trailing actions (buttons/icons on the right).
  final List<CNNavigationBarAction>? trailing;

  /// Use large title style (iOS 11+ style).
  final bool largeTitle;

  /// Use completely transparent background (no blur).
  final bool transparent;

  /// Tint color for buttons and icons.
  final Color? tint;

  /// Fixed height (if null, uses intrinsic platform height).
  final double? height;

  @override
  State<CNNavigationBar> createState() => _CNNavigationBarState();
}

class _CNNavigationBarState extends State<CNNavigationBar> {
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
  void didUpdateWidget(covariant CNNavigationBar oldWidget) {
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
        middle: widget.title != null ? Text(widget.title!) : null,
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
        widget.leading?.map((e) => e.padding).toList() ?? [];
    final trailingIcons =
        widget.trailing?.map((e) => e.icon?.name ?? '').toList() ?? [];
    final trailingLabels =
        widget.trailing?.map((e) => e.label ?? '').toList() ?? [];
    final trailingPaddings =
        widget.trailing?.map((e) => e.padding).toList() ?? [];

    final creationParams = <String, dynamic>{
      'title': widget.title ?? '',
      'leadingIcons': leadingIcons,
      'leadingLabels': leadingLabels,
      'leadingPaddings': leadingPaddings,
      'trailingIcons': trailingIcons,
      'trailingLabels': trailingLabels,
      'trailingPaddings': trailingPaddings,
      'largeTitle': widget.largeTitle,
      'transparent': widget.transparent,
      'isDark': _isDark,
      'style': encodeStyle(context, tint: _effectiveTint),
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
    _lastTitle = widget.title;
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

    final title = widget.title ?? '';
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
