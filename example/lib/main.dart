import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'demos/slider.dart';
import 'demos/switch.dart';
import 'demos/segmented_control.dart';
import 'demos/tab_bar.dart';
import 'demos/icon.dart';
import 'demos/popup_menu_button.dart';
import 'demos/button.dart';
import 'demos/navigation_bar.dart';
import 'demos/navigation_bar_scrollable.dart';
import 'demos/toolbar.dart';
import 'demos/native_search_bar.dart';
import 'demos/action_sheet.dart';
import 'demos/native_sheet_demo.dart';
import 'demos/custom_sheet_demo.dart';
import 'demos/sheet_custom_content.dart';
import 'demos/sheet_uikit_view.dart';
import 'demos/sheet_custom_styling.dart';
import 'demos/simple_search_demo.dart';
import 'demos/tabbar_only_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  Color _accentColor = CupertinoColors.systemBlue;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _setAccentColor(Color color) {
    setState(() {
      _accentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: _accentColor,
      ),
      home: HomePage(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
        accentColor: _accentColor,
        onSelectAccentColor: _setAccentColor,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.accentColor,
    required this.onSelectAccentColor,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Color accentColor;
  final ValueChanged<Color> onSelectAccentColor;

  static const _systemColors = <MapEntry<String, Color>>[
    MapEntry('Red', CupertinoColors.systemRed),
    MapEntry('Orange', CupertinoColors.systemOrange),
    MapEntry('Yellow', CupertinoColors.systemYellow),
    MapEntry('Green', CupertinoColors.systemGreen),
    MapEntry('Teal', CupertinoColors.systemTeal),
    MapEntry('Blue', CupertinoColors.systemBlue),
    MapEntry('Indigo', CupertinoColors.systemIndigo),
    MapEntry('Purple', CupertinoColors.systemPurple),
    MapEntry('Pink', CupertinoColors.systemPink),
    MapEntry('Gray', CupertinoColors.systemGrey),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        border: null,
        // middle: const Text('Cupertino Native'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CNPopupMenuButton.icon(
              buttonIcon: CNSymbol(
                'paintpalette.fill',
                size: 18,
                mode: CNSymbolRenderingMode.multicolor,
              ),
              tint: accentColor,
              items: [
                for (final entry in _systemColors)
                  CNPopupMenuItem(
                    label: entry.key,
                    icon: CNSymbol('circle.fill', size: 18, color: entry.value),
                  ),
              ],
              onSelected: (index) {
                if (index >= 0 && index < _systemColors.length) {
                  onSelectAccentColor(_systemColors[index].value);
                }
              },
            ),
            const SizedBox(width: 8),
            CNButton.icon(
              icon: CNSymbol(isDarkMode ? 'sun.max' : 'moon', size: 18),
              onPressed: onToggleTheme,
            ),
          ],
        ),
      ),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          CupertinoListSection.insetGrouped(
            header: Text('Components'),
            children: [
              CupertinoListTile(
                title: Text('Slider'),
                leading: CNIcon(
                  symbol: CNSymbol('slider.horizontal.3', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const SliderDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Switch'),
                leading: CNIcon(
                  symbol: CNSymbol('switch.2', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const SwitchDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Segmented Control'),
                leading: CNIcon(
                  symbol: CNSymbol('rectangle.split.3x1', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const SegmentedControlDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Icon'),
                leading: CNIcon(symbol: CNSymbol('app', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const IconDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Popup Menu Button'),
                leading: CNIcon(
                  symbol: CNSymbol('ellipsis.circle', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const PopupMenuButtonDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Button'),
                leading: CNIcon(
                  symbol: CNSymbol('hand.tap', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const ButtonDemoPage()),
                  );
                },
              ),
            ],
          ),
          CupertinoListSection.insetGrouped(
            header: Text('Navigation'),
            children: [
              CupertinoListTile(
                title: Text('Toolbar'),
                leading: CNIcon(
                  symbol: CNSymbol(
                    'wrench.and.screwdriver',
                    color: accentColor,
                  ),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const ToolbarDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Navigation Bar'),
                leading: CNIcon(
                  symbol: CNSymbol('menubar.rectangle', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const NavigationBarDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('NavigationBar Scrollable'),
                leading: CNIcon(
                  symbol: CNSymbol('square.grid.2x2', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => NavigationBarScrollableDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Tab Bar'),
                leading: CNIcon(
                  symbol: CNSymbol('square.grid.2x2', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const TabBarDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Native Search Bar'),
                leading: CNIcon(
                  symbol: CNSymbol(
                    'magnifyingglass.circle',
                    color: accentColor,
                  ),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const NativeSearchBarDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Search Integration'),
                subtitle: Text('CNToolbar / CNNavigationBar / CNTabBar'),
                leading: CNIcon(
                  symbol: CNSymbol('magnifyingglass', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const SimpleSearchDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Tab Bar Only (Debug)'),
                subtitle: Text('Isolated CNTabBar.search() test'),
                leading: CNIcon(
                  symbol: CNSymbol('square.grid.2x2', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const TabBarOnlyDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Action Sheet'),
                leading: CNIcon(
                  symbol: CNSymbol('list.bullet.rectangle', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const ActionSheetDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Native Sheets'),
                subtitle: Text('UIKit rendering'),
                leading: CNIcon(
                  symbol: CNSymbol(
                    'rectangle.on.rectangle',
                    color: accentColor,
                  ),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const NativeSheetDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Custom Widget Sheets'),
                subtitle: Text('Flutter overlay rendering'),
                leading: CNIcon(
                  symbol: CNSymbol(
                    'square.stack.3d.down.right',
                    color: accentColor,
                  ),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const CustomSheetDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Custom Content Sheet'),
                subtitle: Text('Non-modal sheet with Flutter widgets'),
                leading: CNIcon(
                  symbol: CNSymbol(
                    'pencil.and.list.clipboard',
                    color: accentColor,
                  ),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const SheetCustomContentDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text(
                  '🎉 Ultimate Goal - Native chrome + Flutter content',
                ),
                leading: CNIcon(
                  symbol: CNSymbol(
                    'star.circle.fill',
                    color: CupertinoColors.systemGreen,
                  ),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const SheetUiKitViewDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Sheet Custom Styling'),
                subtitle: Text('Advanced customization options'),
                leading: CNIcon(
                  symbol: CNSymbol(
                    'paintbrush.fill',
                    color: CupertinoColors.systemPurple,
                  ),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const SheetCustomStylingDemoPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
