
import Foundation
import SafariServices

public class Utilities {
    private static func presentURL(string: String, from controller: UIViewController) {
        let vc = SFSafariViewController(url: URL(string: string)!)
        controller.present(vc, animated: true, completion: nil)
    }
    
    public static func presentPrivacyPolicy(controller: UIViewController) {
        self.presentURL(string: "https://www.just.cash/privacy-policy.html", from: controller)
    }
}
