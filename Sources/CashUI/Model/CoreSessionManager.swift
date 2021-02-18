
import Foundation
import UIKit
import CashCore
import FirebaseFunctions
import Firebase
import FirebaseMessaging


public protocol CoreSessionManagerDelegate {
    func sendCoin(amount: String, address: String, completion: @escaping (() -> Void))
}

public class CoreSessionManager: NSObject, MessagingDelegate {
    
    public static let shared: CoreSessionManager = {
        let instance = CoreSessionManager()
        return instance
    }()
    
    public var delegate: CoreSessionManagerDelegate?
    public var client: ServerEndpoints? = nil
    lazy var functions = Functions.functions()
    
    public override init() {}
    
    public func start(url: EnvironmentUrl = .Production) {
        client = ServerEndpoints.init(url: url)
        if FirebaseApp.app() == nil { FirebaseApp.configure() }
        initFirebaseMessaging()
        client!.createSession(self)
        CoreTransactionManager.startPolling()
    }
    
    func initFirebaseMessaging() {
        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
            let version = nsObject as! String
            print("FCM registration token: \(token)")
            self.functions.httpsCallable("registerToken").call([
                "fcmToken": token,
                "deviceId" : UIDevice.current.identifierForVendor!.uuidString,
                "phone" : "",
                "appVersion" : version,
                "deviceModel": UIDevice.current.modelName,
                "createdAt" : DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
            ]) { (result, error) in
              if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                  let code = FunctionsErrorCode(rawValue: error.code)
                  let message = error.localizedDescription
                  let details = error.userInfo[FunctionsErrorDetailsKey]
                    print("\(code): \(message) \(details)")
                }
              }
            }
          }
        }
    }
}

extension CoreSessionManager: SessionCallback {

    public func onSessionCreated(_ sessionKey: String) {
        NotificationCenter.default.post(name: .CoreSessionDidStart, object: nil)
    }

    public func onError(_ error: CashCoreError?) {
        NotificationCenter.default.post(name: .CoreSessionDidFail, object: error)
    }

}

extension Notification.Name {

    public static let CoreSessionDidStart = Notification.Name(rawValue: "CoreSessionDidStart")
    public static let CoreSessionDidFail = Notification.Name(rawValue: "CoreSessionDidFail")
}
