import Cocoa
import FlutterMacOS

/// Handler for native alert dialogs using NSAlert.
class CupertinoAlertHandler: NSObject {
    private let channel: FlutterMethodChannel
    
    init(messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(
            name: "cupertino_native_alert",
            binaryMessenger: messenger
        )
        super.init()
        
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showAlert":
            showAlert(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func showAlert(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let title = args["title"] as? String,
              let actionsData = args["actions"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGS",
                              message: "Invalid arguments for showAlert",
                              details: nil))
            return
        }
        
        let message = args["message"] as? String
        let preferredActionIndex = args["preferredActionIndex"] as? Int
        
        // Create the alert
        let alert = NSAlert()
        alert.messageText = title
        if let message = message {
            alert.informativeText = message
        }
        
        // Track button responses
        var buttonResponses: [Int] = []
        
        // Add actions as buttons
        for (index, actionData) in actionsData.enumerated() {
            guard let actionTitle = actionData["title"] as? String,
                  let styleIndex = actionData["style"] as? Int else {
                continue
            }
            
            // Add button
            let button = alert.addButton(withTitle: actionTitle)
            buttonResponses.append(index)
            
            // Set style based on action style
            switch styleIndex {
            case 2: // destructive
                // macOS doesn't have a destructive style, but we can use critical alert style
                if index == 0 || styleIndex == 2 {
                    alert.alertStyle = .critical
                }
            default:
                break
            }
        }
        
        // Run the alert and get response
        DispatchQueue.main.async {
            let response = alert.runModal()
            
            // Convert NSApplication.ModalResponse to our action index
            // NSAlertFirstButtonReturn = 1000, NSAlertSecondButtonReturn = 1001, etc.
            let buttonIndex = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
            
            if buttonIndex >= 0 && buttonIndex < buttonResponses.count {
                result(buttonResponses[buttonIndex])
            } else {
                result(nil)
            }
        }
    }
}
