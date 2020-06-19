
import Foundation
import UIKit
import WacSDK

public protocol WACSessionManagerDelegate {
    func sendCoin(amount: String, address: String, completion: @escaping (() -> Void))
}

public class WACSessionManager {
    
    public static let shared: WACSessionManager = {
        let instance = WACSessionManager()
        return instance
    }()
    
    public var delegate: WACSessionManagerDelegate?
    public var client: WAC? = nil
    
    public init() {}
    
    public func start(url: WacUrl = .Production) {
        client = WAC.init(url: url)
//        let listener = WACSessionManager.shared
        client!.createSession(self) {}
        WACTransactionManager.startPolling()
    }
}

extension WACSessionManager: SessionCallback {

    public func onSessionCreated(_ sessionKey: String) {
        NotificationCenter.default.post(name: .WACSessionDidStart, object: nil)
    }

    public func onError(_ errorMessage: WacError?) {
        NotificationCenter.default.post(name: .WACSessionDidFail, object: nil)
    }

}

extension Notification.Name {

    public static let WACSessionDidStart = Notification.Name(rawValue: "WACSessionDidStart")
    public static let WACSessionDidFail = Notification.Name(rawValue: "WACSessionDidFail")
}
