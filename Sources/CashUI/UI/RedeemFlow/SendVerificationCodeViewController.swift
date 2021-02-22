// 
//  SendVerificationCodeViewController.swift
//
//  Created by Giancarlo Pacheco on 5/12/20.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import CashCore
import Firebase
import UserNotifications
import FirebaseMessaging
import SwiftUI
import CountryPicker

extension UIDevice {
       var modelName: String {
           var systemInfo = utsname()
           uname(&systemInfo)
           let machineMirror = Mirror(reflecting: systemInfo.machine)
           let identifier = machineMirror.children.reduce("") { identifier, element in
               guard let value = element.value as? Int8, value != 0 else { return identifier }
               return identifier + String(UnicodeScalar(UInt8(value)))
           }
           return identifier
       }
   }

class SendVerificationCodeViewController: ActionViewController {
    
    // IBOutlets
    @IBOutlet weak var atmMachineTitleLabel: UILabel!
    @IBOutlet weak var amountToWithdrawTextField: CustomTextField!
    @IBOutlet weak var infoAboutMachineLabel: UILabel!
    
    @IBOutlet weak var countryCodeTextField: CustomTextField!
    @IBOutlet weak var phoneNumberTextField: CustomTextField!
    
    @IBOutlet weak var firstNameTextField: CustomTextField!
    @IBOutlet weak var lastNameTextField: CustomTextField!
    @IBOutlet weak var getAtmCodeButton: CustomButton!

    var validFields: Bool {
        return amountToWithdrawTextField.isValid && phoneNumberTextField.isValid && firstNameTextField.isValid && lastNameTextField.isValid && countryCodeTextField.isValid
    }

    static let defaultMinAmountLimit: Int = 20
    static let defaultMaxAmountLimit: Int = 300
    static let defaultAllowedBills: Int = 20
    
    var minAmountLimit = defaultMinAmountLimit
    var maxAmountLimit = defaultMaxAmountLimit
    var allowedBills = defaultAllowedBills

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAtmCodeButton.isEnabled = false
        
        setupPickerViewForTextField()
        
        amountToWithdrawTextField.placeholder = "some test text"
    }
    
    private func setupPickerViewForTextField() {

        let picketView = CountryPickerView.loadPickerView { [weak self] (country) in

                  guard let self = self,
                      let digitCountrycode = country.digitCountrycode else {
                      return
                  }
                  let text = "\(digitCountrycode) \(country.countryCode)"
                  self.countryCodeTextField.text = text
              }

              // Set pick list menually.
              picketView.setPickList(codes: "US", "MX", "CA")
              countryCodeTextField.inputView = picketView

              let toolBar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
              toolBar.barStyle = .default
              toolBar.sizeToFit()

              // Adding Button ToolBar
              let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
              toolBar.items = [doneButton]
              toolBar.isUserInteractionEnabled = true
              countryCodeTextField.inputAccessoryView = toolBar
          }

    @objc func doneButtonTapped() -> Bool {
              self.countryCodeTextField.resignFirstResponder()
            return false
          }
    
    @IBAction func getVerificationCodeAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let firstName = firstNameTextField.text!
        let lastName = self.lastNameTextField.text!
        let phoneNumber = self.phoneNumberTextField.text!
        CoreSessionManager.shared.client!.sendVerificationCode(first: firstName,
                                                               surname: lastName,
                                                               phoneNumber: phoneNumber,
                                                               email: "",
                                                               result: { (result) in
            self.hideAnimated()
            self.actionCallback?.withdraw(amount: self.amountToWithdrawTextField.text!)
            self.actionCallback?.actiondDidComplete(action: .sendVerificationCode)
            self.clearViews()
        })
        
        saveUserInfo(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
    }

    public func setAtmInfo(_ atm: CashCore.AtmMachine) {
//        let transaction = CoreTransaction(status: .VerifyPending,
//                                         atm: atm)
//        CoreTransactionManager.shared.store(transaction)
        
        var value = (atm.min! as NSString).integerValue
        minAmountLimit = value > 0 ? value : SendVerificationCodeViewController.defaultMinAmountLimit
        value = (atm.max! as NSString).integerValue
        maxAmountLimit = value > 0 ? value : SendVerificationCodeViewController.defaultMaxAmountLimit
        value = (atm.bills! as NSString).integerValue
        allowedBills = value > 0 ? value : SendVerificationCodeViewController.defaultAllowedBills
        
        self.atmMachineTitleLabel.text = atm.addressDesc!
        self.atmMachineTitleLabel.setNeedsDisplay()
        self.infoAboutMachineLabel.text = "Min $\(String(describing: minAmountLimit)), Max $\(String(describing: maxAmountLimit)). Multiple of $\(String(describing: allowedBills))"

        self.infoAboutMachineLabel.setNeedsDisplay()
        self.listenForKeyboard = true
        
        populateUserInfo()
    }

    override public func clearViews() {
        super.clearViews()
        self.amountToWithdrawTextField.text = ""
        self.infoAboutMachineLabel.text = ""
        self.phoneNumberTextField.text = ""
        self.countryCodeTextField.text = ""
        self.firstNameTextField.text = ""
        self.lastNameTextField.text = ""
        self.view.setNeedsDisplay()
    }

    @IBAction func textFieldEditingDidChange(_ textField: UITextField) {
        let text = textField.text!
        switch textField {
        case amountToWithdrawTextField:
            if let errorMessage = text.validateAmount(lowerBound: minAmountLimit, upperBound: maxAmountLimit, allowedBills: allowedBills) {
                amountToWithdrawTextField.errorText = errorMessage
            }
        case phoneNumberTextField:
            if let errorMessage = text.validatePhoneNumber() {
                phoneNumberTextField.errorText = errorMessage
            }
        case countryCodeTextField:
            if let errorMessage = text.validatePhoneNumber() {
                countryCodeTextField.errorText = errorMessage
            }
        case firstNameTextField:
            if let errorMessage = text.validateName() {
                firstNameTextField.errorText = errorMessage
            }
        case lastNameTextField:
            if let errorMessage = text.validateName() {
                lastNameTextField.errorText = errorMessage
            }
        default: break
        }
        
        if validFields {
            getAtmCodeButton.isEnabled = true
        } else {
            getAtmCodeButton.isEnabled = false
        }
    }
}

extension SendVerificationCodeViewController {

    private func populateUserInfo() {
        do {
            let storedUser: CoreUser? = try UserDefaults.standard.getUser()
            if let user = storedUser {
                firstNameTextField.text = user.firstName
                lastNameTextField.text = user.lastName
                phoneNumberTextField.text = user.phoneNumber
            }
        } catch {}
    }
    
    private func saveUserInfo(firstName: String, lastName: String, phoneNumber: String) {
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
            let version = nsObject as! String
            print("FCM registration token: \(token)")
            Functions.functions().httpsCallable("registerToken").call([
                "fcmToken": token,
                "deviceId" : UIDevice.current.identifierForVendor!.uuidString,
                "phone" : phoneNumber,
                "appVersion" : version,
                "deviceModel": UIDevice.current.modelName,
                "updatedAt" : DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
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
        
        
        let user = CoreUser(firstName: firstName, lastName: lastName, phone: phoneNumber)
        do {
            try UserDefaults.standard.setUser(user)
            
        } catch {}
    }
    
}
