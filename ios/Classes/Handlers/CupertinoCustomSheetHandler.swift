import Flutter
import UIKit

class CupertinoCustomSheetHandler: NSObject {
    private let channel: FlutterMethodChannel
    private weak var viewController: UIViewController?
    private weak var flutterEngine: FlutterEngine?
    
    init(messenger: FlutterBinaryMessenger, viewController: UIViewController) {
        self.channel = FlutterMethodChannel(name: "cupertino_native_custom_sheet", binaryMessenger: messenger)
        self.viewController = viewController
        
        // Get the FlutterEngine from the root view controller
        if let flutterVC = viewController as? FlutterViewController {
            self.flutterEngine = flutterVC.engine
        }
        
        super.init()
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showSheet":
            showSheet(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func showSheet(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let viewController = self.viewController else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "View controller not available", details: nil))
                return
            }
            
            // Sheet presentation controller is only available in iOS 15.0+
            if #available(iOS 15.0, *) {
                // Create custom header sheet view controller
                let sheetVC = CupertinoCustomSheetViewController()
                
                // Ensure the sheet matches the presenting controller's appearance
                if #available(iOS 13.0, *) {
                    let resolvedStyle = viewController.view.window?.traitCollection.userInterfaceStyle ?? viewController.traitCollection.userInterfaceStyle
                    if resolvedStyle != .unspecified {
                        sheetVC.overrideUserInterfaceStyle = resolvedStyle
                    }
                }

                // Check if nonmodal
                let isModal = args["isModal"] as? Bool ?? true
                
                // Configure sheet properties
                if let title = args["title"] as? String {
                    sheetVC.sheetTitle = title
                }
                if let message = args["message"] as? String {
                    sheetVC.sheetMessage = message
                }
                if let items = args["items"] as? [[String: Any]] {
                    sheetVC.items = items
                }
                sheetVC.isSheetModal = isModal
                
                // Apply custom header styling
                if let size = args["headerTitleSize"] as? CGFloat {
                    sheetVC.headerTitleSize = size
                }
                if let weightString = args["headerTitleWeight"] as? String {
                    sheetVC.headerTitleWeight = Self.fontWeightFromString(weightString)
                }
                if let colorValue = args["headerTitleColor"] as? Int {
                    sheetVC.headerTitleColor = Self.colorFromARGB(colorValue)
                }
                if let height = args["headerHeight"] as? CGFloat {
                    sheetVC.headerHeight = height
                }
                if let colorValue = args["headerBackgroundColor"] as? Int {
                    sheetVC.headerBackgroundColor = Self.colorFromARGB(colorValue)
                }
                if let showDivider = args["showHeaderDivider"] as? Bool {
                    sheetVC.showHeaderDivider = showDivider
                }
                if let colorValue = args["headerDividerColor"] as? Int {
                    sheetVC.headerDividerColor = Self.colorFromARGB(colorValue)
                }
                if let position = args["closeButtonPosition"] as? String {
                    sheetVC.closeButtonPosition = position
                }
                if let icon = args["closeButtonIcon"] as? String {
                    sheetVC.closeButtonIcon = icon
                }
                if let size = args["closeButtonSize"] as? CGFloat {
                    sheetVC.closeButtonSize = size
                }
                if let colorValue = args["closeButtonColor"] as? Int {
                    sheetVC.closeButtonColor = Self.colorFromARGB(colorValue)
                }
                
                // Item styling
                if let colorValue = args["itemBackgroundColor"] as? Int {
                    sheetVC.itemBackgroundColor = Self.colorFromARGB(colorValue)
                }
                if let colorValue = args["itemTextColor"] as? Int {
                    sheetVC.itemTextColor = Self.colorFromARGB(colorValue)
                }
                if let colorValue = args["itemTintColor"] as? Int {
                    sheetVC.itemTintColor = Self.colorFromARGB(colorValue)
                }
                
                // Configure presentation style
                if let sheet = sheetVC.sheetPresentationController {
                    // Set delegate first for nonmodal behavior
                    if !isModal {
                        sheet.delegate = sheetVC
                        sheetVC.isModalInPresentation = false
                    }
                    
                    // Configure detents
                    var detents: [UISheetPresentationController.Detent] = []
                    var detentIdentifiers: [UISheetPresentationController.Detent.Identifier] = []
                    
                    if let detentArray = args["detents"] as? [[String: Any]] {
                        for detentInfo in detentArray {
                            if let type = detentInfo["type"] as? String {
                                switch type {
                                case "medium":
                                    detents.append(.medium())
                                    detentIdentifiers.append(.medium)
                                case "large":
                                    detents.append(.large())
                                    detentIdentifiers.append(.large)
                                case "custom":
                                    if let height = detentInfo["height"] as? Double {
                                        if #available(iOS 16.0, *) {
                                            let customIdentifier = UISheetPresentationController.Detent.Identifier("custom_\(height)")
                                            let customDetent = UISheetPresentationController.Detent.custom(identifier: customIdentifier) { context in
                                                return CGFloat(height)
                                            }
                                            detents.append(customDetent)
                                            detentIdentifiers.append(customIdentifier)
                                        } else {
                                            // Fallback to medium for iOS 15
                                            detents.append(.medium())
                                            detentIdentifiers.append(.medium)
                                        }
                                    }
                                default:
                                    break
                                }
                            }
                        }
                    } else if let detentStrings = args["detents"] as? [String] {
                        // Fallback for old string-based format
                        for detentString in detentStrings {
                            switch detentString {
                            case "medium":
                                detents.append(.medium())
                                detentIdentifiers.append(.medium)
                            case "large":
                                detents.append(.large())
                                detentIdentifiers.append(.large)
                            default:
                                break
                            }
                        }
                    }
                    
                    if detents.isEmpty {
                        detents = [.large()] // Default to large
                        detentIdentifiers = [.large]
                    }
                    sheet.detents = detents
                    
                    // CRITICAL: For nonmodal sheets, set largestUndimmedDetentIdentifier
                    // This is the UIKit equivalent of SwiftUI's presentationBackgroundInteraction
                    // It removes the dimming view for detents up to and including this identifier
                    // allowing background interaction (like in Notes app)
                    if !isModal {
                        // For nonmodal, we want to allow interaction at ALL detents
                        // So we set it to the largest detent in the array
                        if let largestDetent = detentIdentifiers.last {
                            sheet.largestUndimmedDetentIdentifier = largestDetent
                            print("✅ Nonmodal sheet: largestUndimmedDetentIdentifier set to \(largestDetent)")
                        }
                    } else {
                        print("🔒 Modal sheet: background interaction disabled")
                    }
                    
                    // Configure grabber
                    if let prefersGrabber = args["prefersGrabberVisible"] as? Bool {
                        sheet.prefersGrabberVisible = prefersGrabber
                    }
                    
                    // Configure dismiss behavior
                    if let prefersEdgeAttached = args["prefersEdgeAttachedInCompactHeight"] as? Bool {
                        sheet.prefersEdgeAttachedInCompactHeight = prefersEdgeAttached
                    }
                    
                    if let widthFollowsPreferred = args["widthFollowsPreferredContentSizeWhenEdgeAttached"] as? Bool {
                        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferred
                    }
                    
                    // Configure corner radius
                    if let cornerRadius = args["preferredCornerRadius"] as? Double {
                        sheet.preferredCornerRadius = CGFloat(cornerRadius)
                    }
                }
                
                // Set up dismiss callback
                sheetVC.onDismiss = { [weak self] selectedIndex in
                    self?.channel.invokeMethod("onDismiss", arguments: ["selectedIndex": selectedIndex ?? -1])
                }
                
                // Present the sheet
                viewController.present(sheetVC, animated: true) {
                    result(nil)
                }
            } else {
                // iOS 14 and below - sheet presentation controller not available
                result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Sheet presentation requires iOS 15.0 or later", details: nil))
            }
        }
    }
    
    // Helper to convert font weight string to UIFont.Weight
    private static func fontWeightFromString(_ weightString: String) -> UIFont.Weight {
        switch weightString.lowercased() {
        case "ultralight": return .ultraLight
        case "thin": return .thin
        case "light": return .light
        case "regular": return .regular
        case "medium": return .medium
        case "semibold": return .semibold
        case "bold": return .bold
        case "heavy": return .heavy
        case "black": return .black
        default: return .regular
        }
    }
    
    // Helper to convert ARGB int to UIColor
    private static func colorFromARGB(_ argb: Int) -> UIColor {
        let alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
        let red = CGFloat((argb >> 16) & 0xFF) / 255.0
        let green = CGFloat((argb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(argb & 0xFF) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}


// MARK: - Custom Sheet View Controller (with custom header)
@available(iOS 15.0, *)
class CupertinoCustomSheetViewController: UIViewController, UISheetPresentationControllerDelegate, UIGestureRecognizerDelegate {
    var sheetTitle: String?
    var sheetMessage: String?
    var items: [[String: Any]] = []
    var onDismiss: ((Int?) -> Void)?
    var isSheetModal: Bool = true
    var flutterViewController: FlutterViewController?
    
    // Header styling properties
    var headerTitleSize: CGFloat = 20
    var headerTitleWeight: UIFont.Weight = .semibold
    var headerTitleColor: UIColor?
    var headerHeight: CGFloat = 56
    var headerBackgroundColor: UIColor?
    var showHeaderDivider: Bool = true
    var headerDividerColor: UIColor?
    var closeButtonPosition: String = "trailing" // "leading" or "trailing"
    var closeButtonIcon: String = "xmark"
    var closeButtonSize: CGFloat = 17
    var closeButtonColor: UIColor?
    
    // Item styling properties
    var itemBackgroundColor: UIColor?
    var itemTextColor: UIColor?
    var itemTintColor: UIColor?
    
    private var selectedIndex: Int?
    private var scrollView: UIScrollView!
    
    private func syncAppearanceWithPresentingController() {
        guard #available(iOS 13.0, *) else { return }
        let presentingStyle = presentingViewController?.traitCollection.userInterfaceStyle
        let screenStyle = UIScreen.main.traitCollection.userInterfaceStyle
        let resolvedStyle = presentingStyle.flatMap { $0 == .unspecified ? nil : $0 } ?? (screenStyle == .unspecified ? nil : screenStyle)

        if let style = resolvedStyle {
            overrideUserInterfaceStyle = style
            view.overrideUserInterfaceStyle = style
            view.window?.overrideUserInterfaceStyle = style
        } else {
            overrideUserInterfaceStyle = .unspecified
            view.overrideUserInterfaceStyle = .unspecified
            view.window?.overrideUserInterfaceStyle = .unspecified
        }
    }

    // UISheetPresentationControllerDelegate methods
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return !isSheetModal
    }
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        // This is called when detent changes
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if !isSheetModal {
            if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
                let velocity = panGesture.velocity(in: view)
                let contentOffset = scrollView.contentOffset.y
                let maxOffset = scrollView.contentSize.height - scrollView.bounds.height
                
                if (contentOffset <= 0 && velocity.y > 0) || (contentOffset >= maxOffset && velocity.y < 0) {
                    return true
                }
            }
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use system background color that automatically adapts to light/dark mode
        view.backgroundColor = .systemBackground
        
        // If we have a FlutterViewController for custom content, use it
        if let flutterVC = flutterViewController {
            addChild(flutterVC)
            flutterVC.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(flutterVC.view)
            
            NSLayoutConstraint.activate([
                flutterVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                flutterVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                flutterVC.view.topAnchor.constraint(equalTo: view.topAnchor),
                flutterVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            flutterVC.didMove(toParent: self)
            return
        }
        
        // Create custom header with title and close button
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.backgroundColor = headerBackgroundColor ?? .systemBackground
        view.addSubview(headerView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = sheetTitle ?? "Sheet"
        titleLabel.font = .systemFont(ofSize: headerTitleSize, weight: headerTitleWeight)
        titleLabel.textColor = headerTitleColor ?? .label
        headerView.addSubview(titleLabel)
        
        // Close button
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        if let closeImage = UIImage(systemName: closeButtonIcon) {
            let config = UIImage.SymbolConfiguration(pointSize: closeButtonSize, weight: .regular)
            closeButton.setImage(closeImage.withConfiguration(config), for: .normal)
        }
        closeButton.tintColor = closeButtonColor ?? .label
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        headerView.addSubview(closeButton)
        
        // Separator line
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = headerDividerColor ?? .separator
        separator.isHidden = !showHeaderDivider
        headerView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            // Header view constraints
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
            
            // Title label constraints (position depends on closeButtonPosition)
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: closeButtonPosition == "leading" ? 56 : 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Close button constraints (position depends on closeButtonPosition)
            closeButtonPosition == "leading" ?
                closeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16) :
                closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Separator constraints
            separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        // Create scroll view for content
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self as? UIScrollViewDelegate
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        // Add message if present
        if let message = sheetMessage {
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = .systemFont(ofSize: 15)
            messageLabel.textColor = .secondaryLabel
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            contentStack.addArrangedSubview(messageLabel)
        }
        
        // Add items (custom header sheet controller)
        for (index, item) in items.enumerated() {
            if let title = item["title"] as? String {
                let button = UIButton(type: .system)
                button.setTitle(title, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 17)
                button.contentHorizontalAlignment = .leading
                button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
                button.backgroundColor = itemBackgroundColor ?? .clear
                button.layer.cornerRadius = 10
                button.tag = index
                button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
                
                // Apply text color if specified
                if let textColor = itemTextColor {
                    button.setTitleColor(textColor, for: .normal)
                }
                
                // Apply tint color if specified
                if let tintColor = itemTintColor {
                    button.tintColor = tintColor
                }
                
                if let iconName = item["icon"] as? String, let icon = UIImage(systemName: iconName) {
                    button.setImage(icon, for: .normal)
                    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
                }
                
                contentStack.addArrangedSubview(button)
                
                NSLayoutConstraint.activate([
                    button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
                ])
            }
        }
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // ScrollView below header
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content stack
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        syncAppearanceWithPresentingController()
        
        if !isSheetModal, let presentationController = presentationController,
           let containerView = presentationController.containerView {
            containerView.isUserInteractionEnabled = true
        }
    }
    
    @objc private func itemTapped(_ sender: Any) {
        if let button = sender as? UIButton {
            selectedIndex = button.tag
        } else if let gesture = sender as? UITapGestureRecognizer, let view = gesture.view {
            selectedIndex = view.tag
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?(nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            onDismiss?(selectedIndex)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncAppearanceWithPresentingController()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        syncAppearanceWithPresentingController()
    }
}
