import Flutter
import UIKit
import ObjectiveC

class CupertinoNavigationBarPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let container: UIView
  private let navigationBar: UINavigationBar
  private let navigationItem: UINavigationItem
  private var currentTitle: String = ""
  private var currentTint: UIColor? = nil
  private var isTransparent: Bool = false

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeNavigationBar_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    self.navigationBar = UINavigationBar(frame: .zero)
    self.navigationItem = UINavigationItem()

    var title: String = ""
    var titleSize: Double = 0
    var titleClickable: Bool = false
    var leadingIcons: [String] = []
    var leadingLabels: [String] = []
    var leadingPaddings: [Double] = []
    var leadingLabelSizes: [Double] = []
    var leadingIconSizes: [Double] = []
    var leadingSpacers: [String] = []
    var middleIcons: [String] = []
    var middleLabels: [String] = []
    var middlePaddings: [Double] = []
    var middleSpacers: [String] = []
    var middleAlignment: String = "center"
    var trailingIcons: [String] = []
    var trailingLabels: [String] = []
    var trailingPaddings: [Double] = []
    var trailingLabelSizes: [Double] = []
    var trailingIconSizes: [Double] = []
    var trailingSpacers: [String] = []
    var largeTitle: Bool = false
    var transparent: Bool = false
    var isDark: Bool = false
    var tint: UIColor? = nil
    var pillHeight: Double? = nil

    if let dict = args as? [String: Any] {
      title = (dict["title"] as? String) ?? ""
      titleSize = (dict["titleSize"] as? Double) ?? 0
      titleClickable = (dict["titleClickable"] as? Bool) ?? false
      leadingIcons = (dict["leadingIcons"] as? [String]) ?? []
      leadingLabels = (dict["leadingLabels"] as? [String]) ?? []
      leadingPaddings = (dict["leadingPaddings"] as? [Double]) ?? []
      leadingLabelSizes = (dict["leadingLabelSizes"] as? [Double]) ?? []
      leadingIconSizes = (dict["leadingIconSizes"] as? [Double]) ?? []
      leadingSpacers = (dict["leadingSpacers"] as? [String]) ?? []
      middleIcons = (dict["middleIcons"] as? [String]) ?? []
      middleLabels = (dict["middleLabels"] as? [String]) ?? []
      middlePaddings = (dict["middlePaddings"] as? [Double]) ?? []
      middleSpacers = (dict["middleSpacers"] as? [String]) ?? []
      middleAlignment = (dict["middleAlignment"] as? String) ?? "center"
      trailingIcons = (dict["trailingIcons"] as? [String]) ?? []
      trailingLabels = (dict["trailingLabels"] as? [String]) ?? []
      trailingPaddings = (dict["trailingPaddings"] as? [Double]) ?? []
      trailingLabelSizes = (dict["trailingLabelSizes"] as? [Double]) ?? []
      trailingIconSizes = (dict["trailingIconSizes"] as? [Double]) ?? []
      trailingSpacers = (dict["trailingSpacers"] as? [String]) ?? []
      pillHeight = dict["pillHeight"] as? Double
      if let v = dict["largeTitle"] as? NSNumber { largeTitle = v.boolValue }
      if let v = dict["transparent"] as? NSNumber { transparent = v.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber {
        tint = Self.colorFromARGB(n.intValue)
      }
    }

    super.init()

    container.backgroundColor = .clear
    if #available(iOS 13.0, *) {
      container.overrideUserInterfaceStyle = isDark ? .dark : .light
    }

    // Configure navigation bar with translucent blur effect
    navigationBar.translatesAutoresizingMaskIntoConstraints = false
    
    if #available(iOS 13.0, *) {
      let appearance = UINavigationBarAppearance()
      if transparent {
        appearance.configureWithTransparentBackground()
        // Remove ALL background effects so only our pill backgrounds show
        appearance.backgroundEffect = nil
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
      } else {
        appearance.configureWithDefaultBackground()
        // Enable blur effect with more translucent material for better liquid glass effect
        appearance.backgroundEffect = UIBlurEffect(style: isDark ? .systemThinMaterialDark : .systemThinMaterialLight)
      }
      
      // Configure title text attributes
      var titleAttributes: [NSAttributedString.Key: Any] = [:]
      var largeTitleAttributes: [NSAttributedString.Key: Any] = [:]
      
      if let tintColor = tint {
        titleAttributes[.foregroundColor] = tintColor
        largeTitleAttributes[.foregroundColor] = tintColor
      }
      
      if titleSize > 0 {
        titleAttributes[.font] = UIFont.systemFont(ofSize: CGFloat(titleSize))
        // For large titles, make them proportionally larger
        largeTitleAttributes[.font] = UIFont.systemFont(ofSize: CGFloat(titleSize * 1.5))
      }
      
      appearance.titleTextAttributes = titleAttributes
      appearance.largeTitleTextAttributes = largeTitleAttributes
      
      navigationBar.standardAppearance = appearance
      navigationBar.scrollEdgeAppearance = appearance
      navigationBar.compactAppearance = appearance
      if #available(iOS 15.0, *) {
        navigationBar.compactScrollEdgeAppearance = appearance
      }
    } else {
      if transparent {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
      } else {
        navigationBar.isTranslucent = true
      }
    }
    
    if #available(iOS 11.0, *) {
      navigationBar.prefersLargeTitles = largeTitle
      navigationItem.largeTitleDisplayMode = largeTitle ? .always : .never
    }

        // Leading buttons - group consecutive items, split on flexibleSpace
    if !leadingIcons.isEmpty || !leadingLabels.isEmpty {
      var barItems: [UIBarButtonItem] = []
      let count = max(leadingIcons.count, leadingLabels.count)
      
      var currentGroupIcons: [String] = []
      var currentGroupLabels: [String] = []
      var currentGroupPaddings: [Double] = []
      var currentGroupLabelSizes: [Double] = []
      var currentGroupIconSizes: [Double] = []
      var currentGroupIndices: [Int] = []
      var pendingSpacing: Double = 0.0  // Track spacing to add to next button
      
      func finalizeCurrentGroup() {
        if !currentGroupIcons.isEmpty || !currentGroupLabels.isEmpty {
          let buttonGroup = createButtonGroup(
            icons: currentGroupIcons,
            labels: currentGroupLabels,
            paddings: currentGroupPaddings,
            labelSizes: currentGroupLabelSizes,
            iconSizes: currentGroupIconSizes,
            pillHeight: pillHeight,
            tint: tint,
            isDark: isDark,
            target: self,
            action: #selector(leadingTapped(_:))
          )
          
          // Set tags for all buttons in the group
          let buttons = findAllButtons(in: buttonGroup)
          for (idx, button) in buttons.enumerated() {
            if idx < currentGroupIndices.count {
              button.tag = currentGroupIndices[idx]
            }
          }
          
          let barItem = UIBarButtonItem(customView: buttonGroup)
          barItems.append(barItem)
          
          currentGroupIcons = []
          currentGroupLabels = []
          currentGroupPaddings = []
          currentGroupLabelSizes = []
          currentGroupIconSizes = []
          currentGroupIndices = []
          pendingSpacing = 0.0
        }
      }
      
      for i in 0..<count {
        let spacerType = i < leadingSpacers.count ? leadingSpacers[i] : ""
        
        if spacerType == "flexible" {
          // Finalize current group and add flexible space
          finalizeCurrentGroup()
          let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
          barItems.append(flexibleSpace)
        } else if spacerType == "fixed" {
          // Fixed space - split between previous and next button
          let fixedSpaceWidth = i < leadingPaddings.count ? leadingPaddings[i] : 0
          let halfSpace = fixedSpaceWidth / 2.0
          
          // Add half to the previous button if it exists
          if !currentGroupPaddings.isEmpty {
            let lastIndex = currentGroupPaddings.count - 1
            currentGroupPaddings[lastIndex] += halfSpace
          }
          
          // Store the other half for the next button
          pendingSpacing = halfSpace
        } else {
          // Regular button - add to current group
          let icon = i < leadingIcons.count ? leadingIcons[i] : ""
          let label = i < leadingLabels.count ? leadingLabels[i] : ""
          var padding = i < leadingPaddings.count ? leadingPaddings[i] : 0.0
          let labelSize = i < leadingLabelSizes.count ? leadingLabelSizes[i] : 0.0
          let iconSize = i < leadingIconSizes.count ? leadingIconSizes[i] : 0.0
          
          // Add any pending spacing from a previous fixedSpace
          padding += pendingSpacing
          pendingSpacing = 0.0
          
          currentGroupIcons.append(icon)
          currentGroupLabels.append(label)
          currentGroupPaddings.append(padding)
          currentGroupLabelSizes.append(labelSize)
          currentGroupIconSizes.append(iconSize)
          currentGroupIndices.append(i)
        }
      }
      
      // Finalize any remaining group
      finalizeCurrentGroup()
      
      navigationItem.leftBarButtonItems = barItems
    }

    // Middle buttons - group consecutive items, split on flexibleSpace
    if !middleIcons.isEmpty || !middleLabels.isEmpty {
      var middleBarItems: [UIBarButtonItem] = []
      let count = max(middleIcons.count, middleLabels.count)
      
      var currentGroupIcons: [String] = []
      var currentGroupLabels: [String] = []
      var currentGroupPaddings: [Double] = []
      var currentGroupIndices: [Int] = []
      var pendingSpacing: Double = 0.0  // Track spacing to add to next button
      
      func finalizeCurrentGroup() {
        if !currentGroupIcons.isEmpty || !currentGroupLabels.isEmpty {
          let buttonGroup = createButtonGroup(
            icons: currentGroupIcons,
            labels: currentGroupLabels,
            paddings: currentGroupPaddings,
            labelSizes: [], // Middle section doesn't use custom sizes in navigation bar
            iconSizes: [], // Middle section doesn't use custom sizes in navigation bar
            pillHeight: pillHeight,
            tint: tint,
            isDark: isDark,
            target: self,
            action: #selector(middleTapped(_:))
          )
          
          // Set tags for all buttons in the group
          let buttons = findAllButtons(in: buttonGroup)
          for (idx, button) in buttons.enumerated() {
            if idx < currentGroupIndices.count {
              button.tag = 1000 + currentGroupIndices[idx]
            }
          }
          
          let barItem = UIBarButtonItem(customView: buttonGroup)
          middleBarItems.append(barItem)
          
          currentGroupIcons = []
          currentGroupLabels = []
          currentGroupPaddings = []
          currentGroupIndices = []
          pendingSpacing = 0.0
        }
      }
      
      for i in 0..<count {
        let spacerType = i < middleSpacers.count ? middleSpacers[i] : ""
        
        if spacerType == "flexible" {
          // Finalize current group and add flexible space
          finalizeCurrentGroup()
          let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
          middleBarItems.append(flexibleSpace)
        } else if spacerType == "fixed" {
          // Fixed space - split between previous and next button
          let fixedSpaceWidth = i < middlePaddings.count ? middlePaddings[i] : 0
          let halfSpace = fixedSpaceWidth / 2.0
          
          // Add half to the previous button if it exists
          if !currentGroupPaddings.isEmpty {
            let lastIndex = currentGroupPaddings.count - 1
            currentGroupPaddings[lastIndex] += halfSpace
          }
          
          // Store the other half for the next button
          pendingSpacing = halfSpace
        } else {
          // Regular button - add to current group
          let icon = i < middleIcons.count ? middleIcons[i] : ""
          let label = i < middleLabels.count ? middleLabels[i] : ""
          var padding = i < middlePaddings.count ? middlePaddings[i] : 0
          
          // Add any pending spacing from a previous fixedSpace
          padding += pendingSpacing
          pendingSpacing = 0.0
          
          currentGroupIcons.append(icon)
          currentGroupLabels.append(label)
          currentGroupPaddings.append(padding)
          currentGroupIndices.append(i)
        }
      }
      
      // Finalize any remaining group
      finalizeCurrentGroup()
      
      let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
      
      let hasLeading = navigationItem.leftBarButtonItems != nil && !navigationItem.leftBarButtonItems!.isEmpty
      let hasTrailing = !trailingIcons.isEmpty || !trailingLabels.isEmpty
      
      // Apply alignment based on middleAlignment parameter
      if middleAlignment == "leading" && hasLeading {
        // Position close to leading - append right after leading, then add flexible space
        navigationItem.leftBarButtonItems?.append(contentsOf: middleBarItems)
        navigationItem.leftBarButtonItems?.append(flexibleSpace)
      } else if middleAlignment == "trailing" && hasTrailing {
        // Position close to trailing - add flexible space first, then middle to right items
        if hasLeading {
          navigationItem.leftBarButtonItems?.append(flexibleSpace)
        } else {
          navigationItem.leftBarButtonItems = [flexibleSpace]
        }
        navigationItem.rightBarButtonItems = middleBarItems
      } else {
        // Center alignment (default) - flexible space on both sides
        // Also use center if alignment is leading/trailing but no leading/trailing exists
        let flexibleSpace2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        if hasLeading {
          navigationItem.leftBarButtonItems?.append(flexibleSpace)
          navigationItem.leftBarButtonItems?.append(contentsOf: middleBarItems)
          navigationItem.leftBarButtonItems?.append(flexibleSpace2)
        } else {
          navigationItem.leftBarButtonItems = [flexibleSpace] + middleBarItems + [flexibleSpace2]
        }
      }
    }
    
    // Clear title since we're using bar button items
    if !middleIcons.isEmpty || !middleLabels.isEmpty {
      navigationItem.title = nil
      navigationItem.titleView = nil
    } else if !title.isEmpty {
      if titleClickable {
        // Create a clickable title button
        let titleButton = UIButton(type: .system)
        titleButton.setTitle(title, for: .normal)
        titleButton.addTarget(self, action: #selector(titleTapped), for: .touchUpInside)
        titleButton.titleLabel?.textAlignment = .center
        titleButton.sizeToFit()
        
        // Apply custom title size and appearance if specified
        var titleAttributes: [NSAttributedString.Key: Any] = [:]
        if titleSize > 0 {
          titleAttributes[.font] = UIFont.systemFont(ofSize: CGFloat(titleSize), weight: .semibold)
        } else {
          titleAttributes[.font] = UIFont.systemFont(ofSize: 17, weight: .semibold)
        }
        
        // Apply tint color if specified
        if let tintColor = tint {
          titleButton.setTitleColor(tintColor, for: .normal)
        }
        
        // Set the attributed title
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        titleButton.setAttributedTitle(attributedTitle, for: .normal)
        
        navigationItem.titleView = titleButton
        navigationItem.title = nil
      } else {
        navigationItem.title = title
        navigationItem.titleView = nil
      }
    }
    
    currentTitle = title
    currentTint = tint
    isTransparent = transparent

    if let tintColor = tint {
      navigationBar.tintColor = tintColor
    }

    // Trailing buttons - group consecutive items, split on flexibleSpace
    if !trailingIcons.isEmpty || !trailingLabels.isEmpty {
      var trailingBarItems: [UIBarButtonItem] = []
      let count = max(trailingIcons.count, trailingLabels.count)
      
      var currentGroupIcons: [String] = []
      var currentGroupLabels: [String] = []
      var currentGroupPaddings: [Double] = []
      var currentGroupLabelSizes: [Double] = []
      var currentGroupIconSizes: [Double] = []
      var currentGroupIndices: [Int] = []
      var pendingSpacing: Double = 0.0  // Track spacing to add to next button
      
      func finalizeCurrentGroup() {
        if !currentGroupIcons.isEmpty || !currentGroupLabels.isEmpty {
          let buttonGroup = createButtonGroup(
            icons: currentGroupIcons,
            labels: currentGroupLabels,
            paddings: currentGroupPaddings,
            labelSizes: currentGroupLabelSizes,
            iconSizes: currentGroupIconSizes,
            pillHeight: pillHeight,
            tint: tint,
            isDark: isDark,
            target: self,
            action: #selector(trailingTapped(_:))
          )
          
          // Set tags for all buttons in the group
          let buttons = findAllButtons(in: buttonGroup)
          for (idx, button) in buttons.enumerated() {
            if idx < currentGroupIndices.count {
              button.tag = 2000 + currentGroupIndices[idx]
            }
          }
          
          let barItem = UIBarButtonItem(customView: buttonGroup)
          trailingBarItems.append(barItem)
          
          currentGroupIcons = []
          currentGroupLabels = []
          currentGroupPaddings = []
          currentGroupLabelSizes = []
          currentGroupIconSizes = []
          currentGroupIndices = []
          pendingSpacing = 0.0
        }
      }
      
      for i in 0..<count {
        let spacerType = i < trailingSpacers.count ? trailingSpacers[i] : ""
        
        if spacerType == "flexible" {
          // Finalize current group and add flexible space
          finalizeCurrentGroup()
          let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
          trailingBarItems.append(flexibleSpace)
        } else if spacerType == "fixed" {
          // Fixed space - split between previous and next button
          let fixedSpaceWidth = i < trailingPaddings.count ? trailingPaddings[i] : 0
          let halfSpace = fixedSpaceWidth / 2.0
          
          // Add half to the previous button if it exists
          if !currentGroupPaddings.isEmpty {
            let lastIndex = currentGroupPaddings.count - 1
            currentGroupPaddings[lastIndex] += halfSpace
          }
          
          // Store the other half for the next button
          pendingSpacing = halfSpace
        } else {
          // Regular button - add to current group
          let icon = i < trailingIcons.count ? trailingIcons[i] : ""
          let label = i < trailingLabels.count ? trailingLabels[i] : ""
          var padding = i < trailingPaddings.count ? trailingPaddings[i] : 0
          let labelSize = i < trailingLabelSizes.count ? trailingLabelSizes[i] : 0.0
          let iconSize = i < trailingIconSizes.count ? trailingIconSizes[i] : 0.0
          
          // Add any pending spacing from a previous fixedSpace
          padding += pendingSpacing
          pendingSpacing = 0.0
          
          currentGroupIcons.append(icon)
          currentGroupLabels.append(label)
          currentGroupPaddings.append(padding)
          currentGroupLabelSizes.append(labelSize)
          currentGroupIconSizes.append(iconSize)
          currentGroupIndices.append(i)
        }
      }
      
      // Finalize any remaining group
      finalizeCurrentGroup()
      
      if middleAlignment == "trailing" && navigationItem.rightBarButtonItems != nil {
        // Middle is positioned close to trailing, append trailing after middle
        navigationItem.rightBarButtonItems?.append(contentsOf: trailingBarItems)
      } else {
        // Standard trailing position
        navigationItem.rightBarButtonItems = trailingBarItems
      }
    }

    navigationBar.items = [navigationItem]
    container.addSubview(navigationBar)

    NSLayoutConstraint.activate([
      navigationBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      navigationBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      navigationBar.topAnchor.constraint(equalTo: container.topAnchor),
      navigationBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let height = self.navigationBar.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).height
        result(["height": Double(height)])
      case "setTitle":
        if let args = call.arguments as? [String: Any], let title = args["title"] as? String {
          self.navigationItem.title = title
          self.currentTitle = title
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing title", details: nil))
        }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let n = args["tint"] as? NSNumber {
            let tintColor = Self.colorFromARGB(n.intValue)
            self.navigationBar.tintColor = tintColor
            self.currentTint = tintColor
            if #available(iOS 13.0, *) {
              let appearance = self.navigationBar.standardAppearance
              appearance.titleTextAttributes = [.foregroundColor: tintColor]
              appearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
              self.navigationBar.standardAppearance = appearance
              self.navigationBar.scrollEdgeAppearance = appearance
              self.navigationBar.compactAppearance = appearance
            }
          }
          if let t = args["transparent"] as? NSNumber {
            self.isTransparent = t.boolValue
            if #available(iOS 13.0, *) {
              let appearance = UINavigationBarAppearance()
              if self.isTransparent {
                appearance.configureWithTransparentBackground()
              } else {
                appearance.configureWithDefaultBackground()
                let isDark = self.container.traitCollection.userInterfaceStyle == .dark
                appearance.backgroundEffect = UIBlurEffect(style: isDark ? .systemMaterialDark : .systemMaterialLight)
              }
              if let tint = self.currentTint {
                appearance.titleTextAttributes = [.foregroundColor: tint]
                appearance.largeTitleTextAttributes = [.foregroundColor: tint]
              }
              self.navigationBar.standardAppearance = appearance
              self.navigationBar.scrollEdgeAppearance = appearance
              self.navigationBar.compactAppearance = appearance
            }
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
        }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          if #available(iOS 13.0, *) {
            self.container.overrideUserInterfaceStyle = isDark ? .dark : .light
            // Update blur effect for new brightness
            let appearance = self.navigationBar.standardAppearance
            if !self.isTransparent {
              appearance.backgroundEffect = UIBlurEffect(style: isDark ? .systemMaterialDark : .systemMaterialLight)
            }
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
            self.navigationBar.compactAppearance = appearance
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }

  // Helper function to find a UIButton in a view hierarchy
  private func findButton(in view: UIView) -> UIButton? {
    if let button = view as? UIButton {
      return button
    }
    for subview in view.subviews {
      if let button = findButton(in: subview) {
        return button
      }
    }
    return nil
  }
  
  // Helper function to find all UIButtons in a view hierarchy
  private func findAllButtons(in view: UIView) -> [UIButton] {
    var buttons: [UIButton] = []
    if let button = view as? UIButton {
      buttons.append(button)
    }
    for subview in view.subviews {
      buttons.append(contentsOf: findAllButtons(in: subview))
    }
    return buttons
  }

  @objc private func leadingTapped(_ sender: UIButton) {
    channel.invokeMethod("leadingTapped", arguments: ["index": sender.tag])
  }

  @objc private func middleTapped(_ sender: UIButton) {
    channel.invokeMethod("middleTapped", arguments: ["index": sender.tag - 1000])
  }

  @objc private func trailingTapped(_ sender: UIButton) {
    channel.invokeMethod("trailingTapped", arguments: ["index": sender.tag - 2000])
  }
  
  @objc private func titleTapped() {
    channel.invokeMethod("titleTapped", arguments: [:])
  }
  
  @objc private func buttonTouchDown(_ sender: UIButton) {
    // Animate button press with scale and alpha like UIBarButtonItem
    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
      sender.alpha = 0.6
    })
  }
  
  @objc private func buttonTouchUp(_ sender: UIButton) {
    // Animate button release back to normal
    UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      sender.transform = .identity
      sender.alpha = 1.0
    })
  }
  
  private func createButtonGroup(
    icons: [String],
    labels: [String],
    paddings: [Double],
    labelSizes: [Double],
    iconSizes: [Double],
    pillHeight: Double?,
    tint: UIColor?,
    isDark: Bool,
    target: Any?,
    action: Selector
  ) -> UIView {
    let count = max(icons.count, labels.count)
    if count == 0 { return UIView(frame: .zero) }
    
    // Use custom pill height if provided, otherwise calculate from padding
    let customHeight = pillHeight != nil ? CGFloat(pillHeight!) : nil
    
    // Calculate widths and paddings
    var buttonWidths: [CGFloat] = []
    var buttonPaddings: [UIEdgeInsets] = []
    let defaultWidth: CGFloat = 36
    let defaultHeight: CGFloat = 36
    
    for i in 0..<count {
      let padding = i < paddings.count ? CGFloat(paddings[i]) : 0
      buttonWidths.append(defaultWidth + padding * 2)
      buttonPaddings.append(UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
    }
    
    let totalWidth = buttonWidths.reduce(0, +)
    
    // Calculate the blur view height - use custom height if provided, otherwise calculate from padding
    let blurViewHeight: CGFloat
    if let customHeight = customHeight {
      blurViewHeight = customHeight
    } else {
      let maxPadding = buttonPaddings.map { $0.top + $0.bottom }.max() ?? 0
      blurViewHeight = defaultHeight + maxPadding
    }
    
    // Create pill background view - all pills are identical and transparent
    // UIBarButtonItem will add its own background automatically
    let pillView = UIView()
    pillView.backgroundColor = .clear
    pillView.layer.cornerRadius = blurViewHeight / 2
    pillView.layer.masksToBounds = true
    
    // Create a container view to hold both pill background and content
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(pillView)
    pillView.translatesAutoresizingMaskIntoConstraints = false
    
    // Selection indicator removed - no longer showing highlight on tap
    
    // Create stack view for buttons
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 0
    stackView.distribution = .fill
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    // Create buttons
    var buttons: [UIButton] = []
    for i in 0..<count {
      let button = UIButton(type: .system)
      button.tag = i
      button.addTarget(target, action: action, for: .touchUpInside)
      
      // Add touch effect handlers for visual feedback
      button.addTarget(target, action: #selector(buttonTouchDown(_:)), for: .touchDown)
      button.addTarget(target, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
      
      if i < icons.count, !icons[i].isEmpty, let image = UIImage(systemName: icons[i]) {
        let iconSize = i < iconSizes.count && iconSizes[i] > 0 ? CGFloat(iconSizes[i]) : 17
        let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .semibold)
        button.setImage(image.withConfiguration(config), for: .normal)
      } else if i < labels.count, !labels[i].isEmpty {
        let labelSize = i < labelSizes.count && labelSizes[i] > 0 ? CGFloat(labelSizes[i]) : 17
        button.setTitle(labels[i], for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: labelSize, weight: .semibold)
      }
      
      if let tintColor = tint {
        button.tintColor = tintColor
      }
      
      // Ensure button has no background - only the pill blur view should show
      button.backgroundColor = .clear
      
      // Don't apply contentEdgeInsets - just make the button bigger
      // The icon/text will be centered automatically
      
      button.translatesAutoresizingMaskIntoConstraints = false
      stackView.addArrangedSubview(button)
      buttons.append(button)
      
      // Calculate button height - use custom height if provided, otherwise use default + padding
      let buttonHeight: CGFloat
      if let customHeight = customHeight {
        buttonHeight = customHeight
      } else {
        buttonHeight = defaultHeight + buttonPaddings[i].top + buttonPaddings[i].bottom
      }
      
      NSLayoutConstraint.activate([
        button.widthAnchor.constraint(equalToConstant: buttonWidths[i]),
        button.heightAnchor.constraint(equalToConstant: buttonHeight),
      ])
    }
    
    containerView.addSubview(stackView)  // Add to container, not blurView.contentView
    
    // Store button references (selection view removed)
    objc_setAssociatedObject(containerView, "buttons", buttons, .OBJC_ASSOCIATION_RETAIN)
    objc_setAssociatedObject(containerView, "buttonWidths", buttonWidths, .OBJC_ASSOCIATION_RETAIN)
    
    NSLayoutConstraint.activate([
      // Pill view fills the container
      pillView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      pillView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      pillView.topAnchor.constraint(equalTo: containerView.topAnchor),
      pillView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      
      // Stack view positioned within container
      stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      
      // Container size
      containerView.heightAnchor.constraint(equalToConstant: blurViewHeight),
      containerView.widthAnchor.constraint(equalToConstant: totalWidth),
    ])
    
    // Wrap in a centering container for vertical centering in navigation bar
    let wrapperView = UIView()
    wrapperView.translatesAutoresizingMaskIntoConstraints = false
    wrapperView.addSubview(containerView)
    
    NSLayoutConstraint.activate([
      containerView.centerYAnchor.constraint(equalTo: wrapperView.centerYAnchor),
      containerView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
      containerView.topAnchor.constraint(greaterThanOrEqualTo: wrapperView.topAnchor),
      containerView.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor),
    ])
    
    return wrapperView  // Return wrapper for proper vertical centering
  }

  private static func colorFromARGB(_ argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}
