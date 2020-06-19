
import UIKit
import WacSDK

class WACVerifyCashCodeViewController: WACActionViewController {
    
    @IBOutlet weak var atmMachineTitleLabel: UILabel!
    @IBOutlet weak var tokenTextView: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    public var amount: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.confirmButton.isEnabled = false
    }
    
    @IBAction func sendCashCode(_ sender: Any) {
        self.view.endEditing(true)
        WACSessionManager.shared.client!.createCashCode((atm?.atmId)!, amount!, tokenTextView.text!, completion: { (response: CashCodeResponse) in
            if response.result == "error" {
                let message = response.error?.message
                self.showAlert(title: "Error", message: message!, completion: nil)
            }
            else {
                let cashCode = (response.data?.items?.first)!
                self.actionCallback?.withdrawal(requested: cashCode)
                
                let transaction = WACTransaction(status: .SendPending,
                                                 atm: self.atm,
                                                 code: cashCode)
                WACTransactionManager.store(transaction)
            }
            self.view.hideAnimated()
            
            self.actionCallback?.actiondDidComplete(action: .cashCodeVerification)
            self.clearViews()
        })
    }
    
    override public func clearViews() {
        super.clearViews()
        self.tokenTextView.text = ""
    }
    
    override func showView() {
        super.showView()
        self.listenForKeyboard = true
    }
    
    @IBAction override func textDidChange(_ sender: Any) {
        let code = self.tokenTextView.text
        if (code != "") {
            self.confirmButton.isEnabled = true
        }
        else {
            self.confirmButton.isEnabled = false
        }
    }
}
