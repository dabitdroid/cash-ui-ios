
import UIKit
import CashCore

class VerifyCashCodeViewController: ActionViewController {
    
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
        CoreSessionManager.shared.client!.createCashCode((atm?.atmId)!, amount!, tokenTextView.text!, result: { (result) in
            switch result {
            case .success(let response):
                let cashCode = (response.data?.items?.first)!
                self.actionCallback?.withdrawal(requested: cashCode)
                
                let transaction = CoreTransaction(status: .SendPending,
                                                 atm: self.atm,
                                                 code: cashCode)
                CoreTransactionManager.store(transaction)
                break
            case .failure(let error):
                self.showAlert(title: "Error", message: error.message!, completion: nil)
                break
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
