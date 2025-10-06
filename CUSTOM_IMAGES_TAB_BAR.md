# Custom Images in CNTabBar

The `CNTabBar` component now supports custom images in addition to SF Symbols, with full size control!

## Usage

You can use custom images by providing an `ImageProvider` to the `image` parameter of `CNTabBarItem`. You can also specify the size using the `imageSize` parameter:

```dart
CNTabBar(
  items: const [
    // Using SF Symbol
    CNTabBarItem(
      label: 'Home',
      icon: CNSymbol('house.fill'),
    ),
    
    // Using custom asset image with size control
    CNTabBarItem(
      label: 'Profile',
      image: AssetImage('assets/my_profile_icon.png'),
      imageSize: 28, // Size in points (optional)
    ),
    
    // Using network image
    CNTabBarItem(
      label: 'Settings',
      image: NetworkImage('https://example.com/icon.png'),
      imageSize: 24,
    ),
    
    // Using memory image with default size
    CNTabBarItem(
      label: 'Custom',
      image: MemoryImage(imageBytes),
      // imageSize not specified - will use intrinsic size
    ),
  ],
  currentIndex: selectedIndex,
  onTap: (index) {
    // Handle tab change
  },
)
```

## Image Size Control

The `imageSize` parameter controls the size of custom images:

- **Specified**: When `imageSize` is provided (e.g., `28`), the image will be scaled to that size in points
- **Not specified**: When `imageSize` is omitted, the image uses its intrinsic size or is scaled to fit the tab bar
- **Points, not pixels**: Size is measured in points (like SF Symbols), automatically scaled for device pixel density

### Recommended Sizes

For best appearance, use these sizes to match SF Symbols:
- **Small**: 20-22 points
- **Regular**: 24-28 points (default for tab bars)
- **Large**: 30-34 points

## Notes

- You cannot use both `icon` and `image` in the same `CNTabBarItem` - an assertion will fail if you try
- Custom images are loaded asynchronously and sent to the native side as PNG data
- The images will be automatically sized to fit the tab bar (unless `imageSize` is specified)
- On iOS, images are displayed in `UITabBarItem`s
- On macOS, images are displayed in `NSSegmentedControl` segments
- Custom images support tinting when selected (similar to SF Symbols)
- Image scaling maintains aspect ratio and centers the image within the target size

## Example

```dart
class MyTabBar extends StatefulWidget {
  @override
  State<MyTabBar> createState() => _MyTabBarState();
}

class _MyTabBarState extends State<MyTabBar> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return CNTabBar(
      items: const [
        CNTabBarItem(
          label: 'Home',
          image: AssetImage('assets/home_icon.png'),
          imageSize: 26, // Controlled size
        ),
        CNTabBarItem(
          label: 'Profile',
          image: AssetImage('assets/profile_icon.png'),
          imageSize: 26, // Match size for consistency
        ),
        CNTabBarItem(
          label: 'Settings',
          icon: CNSymbol('gearshape.fill'), // Mix with SF Symbols
        ),
      ],
      currentIndex: _index,
      onTap: (i) => setState(() => _index = i),
    );
  }
}
```
