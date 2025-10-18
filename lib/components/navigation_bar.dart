import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import 'icon.dart';
import 'search_config.dart';
import 'search_bar.dart';

/// Action item for navigation bar trailing/leading positions.
class CNNavigationBarAction { 
  /// Creates a navigation bar action item.
  const CNNavigationBarAction({
    this.icon,
    this.label,
    this.onPressed,
    this.padding,
    this.labelSize,
    this.iconSize,
  })  : _isFixedSpace = false,
        _isFlexibleSpace = false;

  /// Creates a fixed space item with specific width.
  const CNNavigationBarAction.fixedSpace(double width)
      : icon = null,
        label = null,
        labelSize = null,
        iconSize = null,
        onPressed = null,
        padding = width,
        _isFixedSpace = true,
        _isFlexibleSpace = false;

  /// Creates a flexible space that expands to fill available space.
  const CNNavigationBarAction.flexibleSpace()
      : icon = null,
        label = null,
        labelSize = null,
        iconSize = null,
        onPressed = null,
        padding = null,
        _isFixedSpace = false,
        _isFlexibleSpace = true;

  /// SF Symbol icon for the action.
  final CNSymbol? icon;

  /// Text label for the action (used if icon is null).
  final String? label;

  /// Font size for the label text in points.
  /// If null, uses the platform default size.
  final double? labelSize;

  /// Size for the icon in points.
  /// If null, uses the icon's intrinsic size or platform default.
  /// This overrides the size specified in the CNSymbol.
  final double? iconSize;

  /// Callback when the action is tapped.
  final VoidCallback? onPressed;

  /// Custom padding for this action. If null, uses default platform padding.
  /// Specified in logical pixels. For fixed space, this is the width of the space.
  final double? padding;

  /// Internal flag to indicate this is a fixed space item.
  final bool _isFixedSpace;

  /// Internal flag to indicate this is a flexible space item.
  final bool _isFlexibleSpace;

  /// Returns true if this is a spacer (fixed or flexible).
  bool get isSpacer => _isFixedSpace || _isFlexibleSpace;

  /// Returns true if this is a fixed space item.
  bool get isFixedSpace => _isFixedSpace;

  /// Returns true if this is a flexible space item.
  bool get isFlexibleSpace => _isFlexibleSpace;
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
    this.titleSize,
    this.onTitlePressed,
    this.trailing,
    this.largeTitle = false,
    this.transparent = true,
    this.tint,
    this.height,
  })  : searchConfig = null,
        scrollableContent = null,
        _isSearchEnabled = false,
        _isScrollable = false;

  /// Creates a navigation bar with integrated search functionality.
  ///
  /// When the search icon is tapped, the navigation bar transforms to show a search bar.
  /// Search button is automatically added to trailing actions.
  ///
  /// Example:
  /// ```dart
  /// CNNavigationBar.search(
  ///   title: 'Contacts',
  ///   leading: [CNNavigationBarAction(icon: CNSymbol('plus'), onPressed: () {})],
  ///   searchConfig: CNSearchConfig(
  ///     placeholder: 'Search contacts',
  ///     onSearchTextChanged: (text) => print(text),
  ///     resultsBuilder: (context, text) => ContactResults(text),
  ///   ),
  /// )
  /// ```
  const CNNavigationBar.search({
    super.key,
    this.leading,
    this.title,
    this.titleSize,
    this.onTitlePressed,
    this.trailing,
    required this.searchConfig,
    this.largeTitle = false,
    this.transparent = true,
    this.tint,
    this.height,
  })  : scrollableContent = null,
        _isSearchEnabled = true,
        _isScrollable = false;

  /// Creates a navigation bar with native UINavigationController and scroll view.
  ///
  /// This enables proper iOS large title behavior where the title automatically
  /// collapses into the center when scrolling up. The navigation bar is embedded
  /// in a native UINavigationController with the provided content in a UIScrollView.
  ///
  /// **Note**: This is only available on iOS. On other platforms, it falls back
  /// to a standard navigation bar.
  ///
  /// Example:
  /// ```dart
  /// CNNavigationBar.scrollable(
  ///   title: 'Settings',
  ///   largeTitle: true,  // Will collapse on scroll
  ///   content: ListView(
  ///     children: [
  ///       // Your scrollable content
  ///     ],
  ///   ),
  ///   leading: [CNNavigationBarAction(icon: CNSymbol('chevron.left'), onPressed: () {})],
  /// )
  /// ```
  const CNNavigationBar.scrollable({
    super.key,
    this.leading,
    this.title,
    this.titleSize,
    this.onTitlePressed,
    this.trailing,
    required this.scrollableContent,
    this.largeTitle = true,
    this.transparent = false,
    this.tint,
    this.height,
  })  : searchConfig = null,
        _isSearchEnabled = false,
        _isScrollable = true;

  /// Leading actions (typically back button, can include multiple items).
  final List<CNNavigationBarAction>? leading;

  /// Title text for the navigation bar.
  final String? title;

  /// Font size for the title text in points.
  /// If null, uses the platform default title size.
  final double? titleSize;

  /// Callback when the title is tapped.
  /// If null, the title is not clickable.
  final VoidCallback? onTitlePressed;

  /// Trailing actions (buttons/icons on the right).
  /// For search-enabled navigation bar, search button is added automatically.
  final List<CNNavigationBarAction>? trailing;

  /// Use large title style (iOS 11+ style).
  final bool largeTitle;

  /// Use completely transparent background (no blur).
  final bool transparent;

  /// Tint color for buttons and icons.
  final Color? tint;

  /// Fixed height (if null, uses intrinsic platform height).
  final double? height;

  /// Search configuration (only for search-enabled navigation bar).
  final CNSearchConfig? searchConfig;

  /// Scrollable content widget (only for scrollable navigation bar with UINavigationController).
  /// This should be your page content that will be placed in a native scroll view.
  final Widget? scrollableContent;

  /// Internal flag to indicate search functionality is enabled.
  final bool _isSearchEnabled;

  /// Internal flag to indicate scrollable UINavigationController mode is enabled.
  final bool _isScrollable;

  @override
  State<CNNavigationBar> createState() {
    if (_isScrollable) {
      return _CNNavigationBarScrollableState();
    }
    if (_isSearchEnabled) {
      return _CNNavigationBarSearchState();
    }
    return _CNNavigationBarState();
  }
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
        widget.leading?.map((e) => e.isSpacer ? '' : (e.icon?.name ?? '')).toList() ?? [];
    final leadingLabels =
        widget.leading?.map((e) => e.isSpacer ? '' : (e.label ?? '')).toList() ?? [];
    final leadingPaddings =
        widget.leading?.map((e) => e.padding ?? 0.0).toList() ?? [];
    final leadingLabelSizes =
        widget.leading?.map((e) => e.labelSize ?? 0.0).toList() ?? [];
    final leadingIconSizes =
        widget.leading?.map((e) => e.iconSize ?? e.icon?.size ?? 0.0).toList() ?? [];
    final leadingSpacers =
        widget.leading?.map((e) => e.isFlexibleSpace ? 'flexible' : (e.isFixedSpace ? 'fixed' : '')).toList() ?? [];
    final trailingIcons =
        widget.trailing?.map((e) => e.isSpacer ? '' : (e.icon?.name ?? '')).toList() ?? [];
    final trailingLabels =
        widget.trailing?.map((e) => e.isSpacer ? '' : (e.label ?? '')).toList() ?? [];
    final trailingPaddings =
        widget.trailing?.map((e) => e.padding ?? 0.0).toList() ?? [];
    final trailingLabelSizes =
        widget.trailing?.map((e) => e.labelSize ?? 0.0).toList() ?? [];
    final trailingIconSizes =
        widget.trailing?.map((e) => e.iconSize ?? e.icon?.size ?? 0.0).toList() ?? [];
    final trailingSpacers =
        widget.trailing?.map((e) => e.isFlexibleSpace ? 'flexible' : (e.isFixedSpace ? 'fixed' : '')).toList() ?? [];

    final creationParams = <String, dynamic>{
      'title': widget.title ?? '',
      'titleSize': widget.titleSize ?? 0.0,
      'titleClickable': widget.onTitlePressed != null,
      'leadingIcons': leadingIcons,
      'leadingLabels': leadingLabels,
      'leadingPaddings': leadingPaddings,
      'leadingLabelSizes': leadingLabelSizes,
      'leadingIconSizes': leadingIconSizes,
      'leadingSpacers': leadingSpacers,
      'trailingIcons': trailingIcons,
      'trailingLabels': trailingLabels,
      'trailingPaddings': trailingPaddings,
      'trailingLabelSizes': trailingLabelSizes,
      'trailingIconSizes': trailingIconSizes,
      'trailingSpacers': trailingSpacers,
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
    } else if (call.method == 'titleTapped') {
      widget.onTitlePressed?.call();
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

/// State class for search-enabled navigation bar.
class _CNNavigationBarSearchState extends State<CNNavigationBar>
    with SingleTickerProviderStateMixin {
  bool _isSearchExpanded = false;
  String _searchText = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.searchConfig!.animationDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _expandSearch() {
    setState(() => _isSearchExpanded = true);
    _animationController.forward();
  }

  void _collapseSearch() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isSearchExpanded = false;
          _searchText = '';
        });
      }
    });
    widget.searchConfig!.onSearchCancelled?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearchExpanded) {
      return _buildSearchView();
    } else {
      return _buildNormalView();
    }
  }

  Widget _buildNormalView() {
    // Add search button to trailing actions
    final searchAction = CNNavigationBarAction(
      icon: widget.searchConfig!.searchIcon,
      onPressed: _expandSearch,
    );

    final trailingWithSearch = [
      ...?widget.trailing,
      searchAction,
    ];

    return CNNavigationBar(
      leading: widget.leading,
      title: widget.title,
      onTitlePressed: widget.onTitlePressed,
      trailing: trailingWithSearch,
      largeTitle: widget.largeTitle,
      transparent: widget.transparent,
      tint: widget.tint,
      height: widget.height,
    );
  }

  Widget _buildSearchView() {
    final config = widget.searchConfig!;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Search results overlay
          if (config.showResultsOverlay &&
              config.resultsBuilder != null &&
              _searchText.isNotEmpty)
            Positioned.fill(
              child: config.resultsBuilder!(context, _searchText),
            ),
          // Search bar
          SafeArea(
            top: false,
            child: CNSearchBar(
              placeholder: config.placeholder,
              showsCancelButton: config.showsCancelButton,
              onTextChanged: (text) {
                setState(() => _searchText = text);
                config.onSearchTextChanged?.call(text);
              },
              onSearchButtonClicked: (text) {
                config.onSearchSubmitted?.call(text);
              },
              onCancelButtonClicked: _collapseSearch,
              height: config.searchBarHeight,
            ),
          ),
        ],
      ),
    );
  }
}

/// State class for scrollable navigation bar with UINavigationController.
/// 
/// This creates a native UINavigationController with the navigation bar
/// and content in a UIScrollView, enabling proper large title collapse behavior.
class _CNNavigationBarScrollableState extends State<CNNavigationBar> {
  MethodChannel? _channel;
  
  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For scrollable mode on iOS, use CustomScrollView with CupertinoSliverNavigationBar
    // This provides authentic iOS large title behavior with automatic collapse on scroll
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Build leading widget if actions exist
      Widget? leadingWidget;
      if (widget.leading != null && widget.leading!.isNotEmpty) {
        final firstAction = widget.leading!.first;
        leadingWidget = CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: firstAction.onPressed,
          child: firstAction.icon != null
              ? CNIcon(symbol: firstAction.icon!)
              : Text(firstAction.label ?? ''),
        );
      }

      // Build trailing widget if actions exist
      Widget? trailingWidget;
      if (widget.trailing != null && widget.trailing!.isNotEmpty) {
        if (widget.trailing!.length == 1) {
          final action = widget.trailing!.first;
          trailingWidget = CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: action.onPressed,
            child: action.icon != null
                ? CNIcon(symbol: action.icon!)
                : Text(action.label ?? ''),
          );
        } else {
          // Multiple trailing actions
          trailingWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.trailing!.map((action) {
              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: action.onPressed,
                child: action.icon != null
                    ? CNIcon(symbol: action.icon!)
                    : Text(action.label ?? ''),
              );
            }).toList(),
          );
        }
      }

      return CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            if (widget.largeTitle)
              // Use CupertinoSliverNavigationBar for large title with collapse behavior
              CupertinoSliverNavigationBar(
                largeTitle: widget.title != null ? Text(widget.title!) : const Text(''),
                leading: leadingWidget,
                trailing: trailingWidget,
                backgroundColor: widget.transparent
                    ? CupertinoColors.transparent
                    : null,
                border: widget.transparent
                    ? null
                    : const Border(
                        bottom: BorderSide(
                          color: CupertinoColors.separator,
                          width: 0.0,
                        ),
                      ),
              )
            else
              // Use SliverPersistentHeader for small title only
              SliverPersistentHeader(
                pinned: true,
                delegate: _SmallNavigationBarDelegate(
                  title: widget.title,
                  leading: leadingWidget,
                  trailing: trailingWidget,
                  transparent: widget.transparent,
                  context: context,
                ),
              ),
            SliverToBoxAdapter(
              child: widget.scrollableContent ?? const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }

    // On non-iOS platforms, fall back to regular navigation bar + content
    return Column(
      children: [
        CNNavigationBar(
          leading: widget.leading,
          title: widget.title,
          onTitlePressed: widget.onTitlePressed,
          trailing: widget.trailing,
          largeTitle: widget.largeTitle,
          transparent: widget.transparent,
          tint: widget.tint,
          height: widget.height,
        ),
        Expanded(
          child: widget.scrollableContent ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Delegate for creating a small navigation bar in a sliver.
class _SmallNavigationBarDelegate extends SliverPersistentHeaderDelegate {
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final bool transparent;
  final BuildContext context;

  _SmallNavigationBarDelegate({
    this.title,
    this.leading,
    this.trailing,
    required this.transparent,
    required this.context,
  });

  @override
  double get minExtent => 44.0 + MediaQuery.of(context).padding.top;

  @override
  double get maxExtent => 44.0 + MediaQuery.of(context).padding.top;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final backgroundColor = transparent
        ? CupertinoColors.transparent
        : CupertinoTheme.of(context).barBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: transparent
            ? null
            : const Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.0,
                ),
              ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SizedBox(
          height: 44,
          child: Stack(
            children: [
              // Title in center
              if (title != null)
                Center(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              // Leading on left
              if (leading != null)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: leading!,
                  ),
                ),
              // Trailing on right
              if (trailing != null)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: trailing!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SmallNavigationBarDelegate oldDelegate) {
    return title != oldDelegate.title ||
        leading != oldDelegate.leading ||
        trailing != oldDelegate.trailing ||
        transparent != oldDelegate.transparent;
  }
}
