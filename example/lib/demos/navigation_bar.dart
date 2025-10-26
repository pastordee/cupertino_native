import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class NavigationBarDemoPage extends StatefulWidget {
  const NavigationBarDemoPage({super.key});

  @override
  State<NavigationBarDemoPage> createState() => _NavigationBarDemoPageState();
}

class _NavigationBarDemoPageState extends State<NavigationBarDemoPage> {
  bool _isTransparent = true;
  bool _showLargeTitle = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Background gradient to show translucent effect
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CupertinoColors.systemBlue,
                  CupertinoColors.systemPurple,
                  CupertinoColors.systemPink,
                ],
              ),
            ),
          ),

          // Scrollable content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 60,
                bottom: 16,
              ),
              children: [
                const SizedBox(height: 20),

                // Demo card
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
                        'Liquid Glass Navigation Bar',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'The navigation bar above uses native UINavigationBar (iOS) and NSToolbar (macOS) with translucent blur effects. Scroll up to see the liquid glass effect as content passes behind it.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Controls
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
                      Row(
                        children: [
                          const Text('Large Title'),
                          const Spacer(),
                          CupertinoSwitch(
                            value: _showLargeTitle,
                            onChanged: (v) =>
                                setState(() => _showLargeTitle = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Features list
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground
                        .resolveFrom(context)
                        .withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeature(
                        '🌊',
                        'Liquid Glass Effect',
                        'Translucent blur that adapts to content',
                      ),
                      _buildFeature(
                        '🎨',
                        'Native Appearance',
                        'True iOS/macOS navigation bar',
                      ),
                      _buildFeature(
                        '🔘',
                        'Custom Actions',
                        'Back button and trailing actions',
                      ),
                      _buildFeature(
                        '🎨',
                        'Action Colors',
                        'Individual tint colors per action',
                      ),
                      _buildFeature('🎯', 'SF Symbols', 'Native icon support'),
                      _buildFeature(
                        '🌓',
                        'Dark Mode',
                        'Automatic theme adaptation',
                      ),
                    ],
                  ),
                ),

                // Add more content to enable scrolling
                const SizedBox(height: 400),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground
                        .resolveFrom(context)
                        .withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Scroll up to see the translucent blur effect! ☝️',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // Native translucent navigation bar positioned on top
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: CNNavigationBar(
                leading: [
                  CNNavigationBarAction(
                    icon: CNSymbol('chevron.left'),
                    iconSize: 20,
                    tint: CupertinoColors.systemBlue,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CNNavigationBarAction.fixedSpace(5),
                  CNNavigationBarAction(
                    label: 'Back',
                    labelSize: 14,
                    padding: 2,
                    tint: CupertinoColors.systemBlue,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
                title: 'Native Nav Bar',
                titleSize: 20,
                onTitlePressed: () {
                  print('Title tapped!');
                  // Show a simple alert to demonstrate the tap
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Title Tapped'),
                      content: const Text('The navigation bar title was tapped!'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                },
                trailing: [
                  CNNavigationBarAction(
                    icon: CNSymbol('gear'),
                    iconSize: 22,
                    tint: CupertinoColors.systemGrey,
                    onPressed: () {
                      print('Settings tapped');
                    },
                  ),
                  CNNavigationBarAction.flexibleSpace(),
                  CNNavigationBarAction(
                    icon: CNSymbol('plus'),
                    iconSize: 18,
                    tint: CupertinoColors.systemGreen,
                    onPressed: () {
                      print('Add tapped');
                    },
                  ),
                ],
                tint: CupertinoColors.label,
                transparent: _isTransparent,
                largeTitle: _showLargeTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    // fontWeight: FontWeight.semibold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
