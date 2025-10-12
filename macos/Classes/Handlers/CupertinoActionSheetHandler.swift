import Cocoa
import FlutterMacOS

class CupertinoActionSheetHandler: NSObject {
    private let channel: FlutterMethodChannel
    
    init(messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(name: "cupertino_native_action_sheet", binaryMessenger: messenger)
        super.init()
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            switch call.method {
            case "showActionSheet":
                self.showActionSheet(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func showActionSheet(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        let title = args["title"] as? String ?? ""
        let message = args["message"] as? String ?? ""
        let actionsList = args["actions"] as? [[String: Any]] ?? []
        let cancelActionData = args["cancelAction"] as? [String: Any]
        
        // Create the alert
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        
        // Add actions as buttons
        // Destructive actions first (will appear more prominent)
        for actionData in actionsList {
            guard let actionTitle = actionData["title"] as? String else { continue }
            alert.addButton(withTitle: actionTitle)
        }
        
        // Add cancel button if provided
        if let cancelData = cancelActionData,
           let cancelTitle = cancelData["title"] as? String {
            alert.addButton(withTitle: cancelTitle)
        }
        
        // Show the alert
        DispatchQueue.main.async {
            let response = alert.runModal()
            
            // Calculate which button was pressed
            let buttonIndex = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
            
            // Check if cancel was pressed (last button if cancel action exists)
            if cancelActionData != nil && buttonIndex == actionsList.count {
                result(-1) // Cancel
            } else if buttonIndex >= 0 && buttonIndex < actionsList.count {
                result(buttonIndex)
            } else {
                result(-1)
            }
        }
    }
}
