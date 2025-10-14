import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class ToolbarDemoPage extends StatefulWidget {
  const ToolbarDemoPage({super.key});

  @override
  State<ToolbarDemoPage> createState() => _ToolbarDemoPageState();
}

class _ToolbarDemoPageState extends State<ToolbarDemoPage> {
  bool _isTransparent = true;
  CNToolbarMiddleAlignment _middleAlignment = CNToolbarMiddleAlignment.center;
  bool _isSearchExpanded = false;
  String _searchText = '';

  // Remember the toolbar state before search expansion
  bool _lastTransparentState = true;
  CNToolbarMiddleAlignment _lastMiddleAlignment =
      CNToolbarMiddleAlignment.center;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CupertinoColors.label,
                  CupertinoColors.systemPurple,
                  CupertinoColors.systemTeal,
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 80,
                bottom: 80,
              ),
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground
                        .resolveFrom(context)
                        .withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Liquid Glass Toolbar',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'The toolbar above uses native UINavigationBar (iOS) and NSToolbar (macOS) with translucent blur effects.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground
                        .resolveFrom(context)
                        .withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('Transparent Mode'),
                          const Spacer(),
                          CupertinoSwitch(
                            value: _isTransparent,
                            onChanged: (v) =>
                                setState(() => _isTransparent = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Middle Alignment',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          CupertinoSlidingSegmentedControl<
                            CNToolbarMiddleAlignment
                          >(
                            groupValue: _middleAlignment,
                            children: const {
                              CNToolbarMiddleAlignment.leading: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text('Leading'),
                              ),
                              CNToolbarMiddleAlignment.center: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text('Center'),
                              ),
                              CNToolbarMiddleAlignment.trailing: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text('Trailing'),
                              ),
                            },
                            onValueChanged: (value) {
                              if (value != null) {
                                setState(() => _middleAlignment = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Top toolbar
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: _isSearchExpanded
                  ? _buildExpandedSearchToolbar()
                  : _buildNormalToolbar(),
            ),
          ),
          // Bottom toolbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: CNToolbar(
                middleAlignment: _middleAlignment,
                tint: CupertinoColors.label,

                leading: [
                  CNToolbarAction(
                    label: 'Edit',
                    onPressed: () => print('Edit tapped'),
                  ),
                  const CNToolbarAction.fixedSpace(
                    12,
                  ), // Fixed space between text labels
                  CNToolbarAction(
                    label: 'Share',
                    padding: 2,
                    onPressed: () => print('Share tapped'),
                  ),
                ],

                middle: [
                  CNToolbarAction(
                    icon: CNSymbol('pencil', size: 30),
                    onPressed: () => print('pencil tapped'),
                  ),
                  // const CNToolbarAction.fixedSpace(1),
                  // const CNToolbarAction.flexibleSpace(),
                  CNToolbarAction(
                    icon: CNSymbol('trash', size: 30),
                    onPressed: () => print('Delete tapped'),
                  ),
                ],

                trailing: [
                  CNToolbarAction(
                    icon: CNSymbol('ellipsis', size: 30),
                    onPressed: () => print('More tapped'),
                  ),
                  const CNToolbarAction.flexibleSpace(),
                  CNToolbarAction(
                    icon: CNSymbol('play', size: 30),
                    onPressed: () => print('Play tapped'),
                  ),
                ],

                transparent: _isTransparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalToolbar() {
    return CNToolbar(
      middleAlignment: _middleAlignment,
      leading: [
        CNToolbarAction(
          icon: CNSymbol('chevron.left'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        CNToolbarAction(
          icon: CNSymbol('square.and.arrow.up'),
          onPressed: () => print('Share tapped'),
        ),
      ],
      middle: [
        CNToolbarAction(
          icon: CNSymbol('pencil', size: 40),
          onPressed: () => print('Edit tapped'),
        ),
        CNToolbarAction(
          icon: CNSymbol('trash', size: 40),
          onPressed: () => print('Delete tapped'),
        ),
      ],
      trailing: [
        CNToolbarAction(
          icon: CNSymbol('magnifyingglass'),
          onPressed: () {
            setState(() {
              // Save current state before expanding search
              _lastTransparentState = _isTransparent;
              _lastMiddleAlignment = _middleAlignment;
              _isSearchExpanded = true;
            });
          },
        ),
        CNToolbarAction(
          icon: CNSymbol('plus'),
          onPressed: () => print('Add tapped'),
        ),
      ],
      tint: CupertinoColors.label,
      transparent: _isTransparent,
    );
  }

  Widget _buildExpandedSearchToolbar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Show a mini toolbar with the back icon on the left
          // Using 'trailing' for single-item toolbar positions it naturally
          SizedBox(
            width: 80,
            height: 44,
            child: CNToolbar(
              trailing: [
                CNToolbarAction(
                  icon: CNSymbol('chevron.left', size: 22),
                  onPressed: () {
                    // Return to normal toolbar state
                    setState(() {
                      _isSearchExpanded = false;
                      _isTransparent = _lastTransparentState;
                      _middleAlignment = _lastMiddleAlignment;
                      _searchText = '';
                    });
                  },
                ),
              ],
              transparent: _lastTransparentState,
              tint: CupertinoColors.label,
            ),
          ),
          const SizedBox(width: 8),
          // Expanded search bar
          Expanded(
            child: CNSearchBar(
              placeholder: 'Search',
              showsCancelButton: true,
              onTextChanged: (text) {
                setState(() => _searchText = text);
                print('Searching: $text');
              },
              onSearchButtonClicked: (text) {
                print('Search submitted: $text');
              },
              onCancelButtonClicked: () {
                setState(() {
                  _isSearchExpanded = false;
                  _isTransparent = _lastTransparentState;
                  _middleAlignment = _lastMiddleAlignment;
                  _searchText = '';
                });
              },
              height: 40,
            ),
          ),
        ],
      ),
    );
  }
}
