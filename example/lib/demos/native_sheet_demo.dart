import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demo page showing native iOS Sheet examples
///
/// Demonstrates Apple HIG best practices for native sheets:
/// - Sheets for scoped, contextual tasks
/// - Resizable with detents (medium/large/custom)
/// - Grabber for visual affordance
/// - Nonmodal sheets for Notes-style interaction
/// - Uses native UIKit rendering
class NativeSheetDemoPage extends StatefulWidget {
  const NativeSheetDemoPage({super.key});

  @override
  State<NativeSheetDemoPage> createState() => _NativeSheetDemoPageState();
}

class _NativeSheetDemoPageState extends State<NativeSheetDemoPage> {
  String _lastAction = 'No action taken';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Native Sheets'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info section
            _buildInfoSection(),
            const SizedBox(height: 24),

            // ===== NATIVE SHEETS SECTION =====
            _buildMainSectionHeader('Native Sheet Examples', icon: CupertinoIcons.rectangle_on_rectangle),
            const SizedBox(height: 12),

            // Sheet Example 1: Settings Sheet (Medium Detent)
            _buildSectionHeader('Settings Sheet - Medium Detent'),
            _buildExampleCard(
              title: 'Display Settings',
              description: 'Sheet with medium detent (50% height)',
              onTap: () => _showSettingsSheet(),
            ),
            const SizedBox(height: 16),

            // Sheet Example 2: Photo Editor (Large Detent)
            _buildSectionHeader('Edit Sheet - Full Height'),
            _buildExampleCard(
              title: 'Edit Photo',
              description: 'Full height sheet for complex tasks',
              onTap: () => _showEditPhotoSheet(),
            ),
            const SizedBox(height: 16),

            // Sheet Example 3: Resizable with Grabber
            _buildSectionHeader('Resizable Sheet'),
            _buildExampleCard(
              title: 'Resizable Content',
              description: 'Sheet with both medium and large detents + grabber',
              onTap: () => _showResizableSheet(),
            ),
            const SizedBox(height: 16),

            // Sheet Example 4: Nonmodal Sheet (like Notes app)
            _buildSectionHeader('Nonmodal Sheet - Background Interaction'),
            _buildExampleCard(
              title: 'Text Formatter (Native)',
              description: 'True nonmodal - tap styles without closing! Background stays interactive.',
              onTap: () => _showNonmodalSheet(),
            ),
            const SizedBox(height: 24),

            // Status display
            _buildStatusSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.info_circle_fill,
                color: CupertinoColors.systemBlue.resolveFrom(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Native Sheet Best Practices',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• Use sheets for scoped, contextual tasks\n'
            '• Medium detent (~50%) for quick selections\n'
            '• Large detent (full height) for complex tasks\n'
            '• Grabber provides visual affordance\n'
            '• Nonmodal sheets allow background interaction\n'
            '• Native rendering uses UISheetPresentationController',
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
          letterSpacing: -0.08,
        ),
      ),
    );
  }

  Widget _buildExampleCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.separator.resolveFrom(context),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_forward,
              size: 20,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last Action',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _lastAction,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSectionHeader(String title, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: CupertinoColors.activeBlue.resolveFrom(context),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ===== NATIVE SHEET METHODS =====

  /// Example 1: Settings sheet with medium detent
  Future<void> _showSettingsSheet() async {
    await CNSheet.show(
      context: context,
      title: 'Display Settings',
      message: 'Sheet with medium detent (50% height)',
      items: [
        CNSheetItem(title: 'Brightness', icon: 'sun.max'),
        CNSheetItem(title: 'Text Size', icon: 'textformat.size'),
        CNSheetItem(title: 'Appearance', icon: 'moon'),
        CNSheetItem(title: 'Display Zoom', icon: 'magnifyingglass'),
      ],
      detents: [CNSheetDetent.medium],
      prefersGrabberVisible: true,
    );
    setState(() => _lastAction = 'Settings sheet dismissed');
  }

  /// Example 2: Full height edit photo sheet
  Future<void> _showEditPhotoSheet() async {
    await CNSheet.show(
      context: context,
      title: 'Edit Photo',
      message: 'Full height sheet for complex editing tasks',
      items: [
        CNSheetItem(title: 'Crop', icon: 'crop'),
        CNSheetItem(title: 'Adjust', icon: 'slider.horizontal.3'),
        CNSheetItem(title: 'Filters', icon: 'camera.filters'),
        CNSheetItem(title: 'Enhance', icon: 'wand.and.stars'),
        CNSheetItem(title: 'Markup', icon: 'pencil.tip.crop.circle'),
        CNSheetItem(title: 'Retouch', icon: 'bandage'),
      ],
      detents: [CNSheetDetent.large],
      prefersGrabberVisible: true,
    );
    setState(() => _lastAction = 'Photo editing dismissed');
  }

  /// Example 3: Resizable sheet with both detents
  Future<void> _showResizableSheet() async {
    await CNSheet.show(
      context: context,
      title: 'Resizable Content',
      message: 'Drag the grabber or scroll to resize',
      items: List.generate(
        10,
        (index) => CNSheetItem(title: 'Item ${index + 1}', icon: 'square.fill'),
      ),
      detents: [CNSheetDetent.medium, CNSheetDetent.large],
      prefersGrabberVisible: true,
    );
    setState(() => _lastAction = 'Resizable sheet dismissed');
  }

  /// Example 4: Nonmodal sheet - allows background interaction like Notes app
  /// Uses NATIVE rendering with simple items for true nonmodal behavior
  Future<void> _showNonmodalSheet() async {
    final result = await CNSheet.showWithCustomHeader(
      context: context,
      title: 'Format',
      message: 'Tap styles to apply formatting. Background remains interactive!',
      items: [
        CNSheetItem(title: 'Bold', icon: 'bold', dismissOnTap: false),
        CNSheetItem(title: 'Italic', icon: 'italic', dismissOnTap: false),
        CNSheetItem(title: 'Underline', icon: 'underline', dismissOnTap: false),
        CNSheetItem(title: 'Strikethrough', icon: 'strikethrough', dismissOnTap: false),
        CNSheetItem(title: 'Highlight', icon: 'paintbrush', dismissOnTap: false),
      ],
      detents: [CNSheetDetent.custom(360)],
      prefersGrabberVisible: false,
      isModal: false,
      preferredCornerRadius: 36,
      headerHeight: 52,
      headerBackgroundColor: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.92),
      showHeaderDivider: false,
      headerTitleWeight: FontWeight.w600,
      closeButtonIcon: 'xmark',
      closeButtonColor: CupertinoColors.label.resolveFrom(context),
      itemBackgroundColor: CupertinoColors.secondarySystemBackground.resolveFrom(context),
      itemTextColor: CupertinoColors.label.resolveFrom(context),
      itemTintColor: CupertinoColors.activeBlue.resolveFrom(context),
    );

    if (result != null) {
      final actions = ['Bold', 'Italic', 'Underline', 'Strikethrough', 'Highlight'];
      setState(() => _lastAction = '${actions[result]} applied');
    } else {
      setState(() => _lastAction = 'Format sheet closed');
    }
  }
}
