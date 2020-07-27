// 
//  AtmLocationsViewController.swift
//
//  Created by Giancarlo Pacheco on 5/14/20.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import CashCore

enum ActionStrings: String {
    case list = "List"
    case map = "Map"
    case send = "Send"
    case details = "Details"
}

public enum Action {
    case sendVerificationCode
    case cashCodeVerification
}

protocol ActionProtocol {
    func actiondDidComplete(action: Action?)
    func withdraw(amount: String)
    func withdrawal(requested cashCode: CashCore.CashCode)
    func sendCashCode(_ cashCode: CashCore.CashCode)
}

class AtmLocationsViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var containerView: UIView!
    private var rightBarbuttonItem: UIBarButtonItem?
    
    var sendVerificationVC: SendVerificationCodeViewController?
    var verifyCashCodeVC: VerifyCashCodeViewController?
    
    var currentContainerViewVC: UIViewController?
    
    private lazy var mapVC: MapViewController = {
        var viewController = MapViewController()
        return viewController
    }()
    
    private lazy var listVC: ListViewController = {
        let bundle = Bundle.init(for: ListViewController.self)
        var viewController = ListViewController.init(nibName: "ListView", bundle: bundle)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        addToggleNavigationItem()
        add(asChildViewController: mapVC)
        
        self.title = "ATM Cash Locations"
        view.backgroundColor = Theme.primaryBackground
        
        // By now, we should already have a session
        getAtmList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addSendVerificationView()
        addVerifyCashCodeView()
    }
    
    @objc func toggleTapped() {
        if (rightBarbuttonItem?.title == ActionStrings.list.rawValue) {
            // Show tableview
            rightBarbuttonItem?.title = ActionStrings.map.rawValue
            remove(asChildViewController: mapVC)
            add(asChildViewController: listVC)
        }
        else {
            // Show Map
            rightBarbuttonItem?.title = ActionStrings.list.rawValue
            remove(asChildViewController: listVC)
            add(asChildViewController: mapVC)
        }
    }
    
    func addToggleNavigationItem() {
        rightBarbuttonItem = UIBarButtonItem(title: ActionStrings.list.rawValue, style: .plain, target: self, action: #selector(toggleTapped))
        self.navigationItem.rightBarButtonItem = rightBarbuttonItem
    }
    
    func setupSearchBar() {
        searchBar.backgroundColor = Theme.tertiaryBackground
        searchBar.layer.cornerRadius = 2.0
        searchBar.textField.textColor = .white
    }
    
    func doSearch(search: String) {
        self.mapVC.doSearch(search: search)
        self.listVC.doSearch(search: search)
    }
    
    func getAtmList() {
        CoreSessionManager.shared.client!.getAtmList(result: { (result) in
            switch result {
            case .success(let response):
                if let items = response.data?.items {
                    self.mapVC.atmList = items
                    self.listVC.atmList = items
                }
                break
            case .failure(_):
                break
            }
        })
    }
    
    func addSheetView(controller: UIViewController) {
        self.addChild(controller)
        self.view.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        if (controller.isKind(of: ActionViewController.self)) {
            (controller as! ActionViewController).actionCallback = self
        }

        let height = controller.view.frame.height
        let width  = view.frame.width
        controller.view.frame = CGRect(x: 0, y: self.view.frame.size.height, width: width, height: height)
    }
    
    func addSendVerificationView() {
        let bundle = Bundle.init(for: SendVerificationCodeViewController.self)
        sendVerificationVC = SendVerificationCodeViewController.init(nibName: "SendVerificationView", bundle: bundle)
        addSheetView(controller: sendVerificationVC!)
    }
    
    func addVerifyCashCodeView() {
        let bundle = Bundle.init(for: VerifyCashCodeViewController.self)
        verifyCashCodeVC = VerifyCashCodeViewController.init(nibName: "VerifyCashCodeView", bundle: bundle)
        addSheetView(controller: verifyCashCodeVC!)
    }
}

extension AtmLocationsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        doSearch(search: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.listVC.doSearch(search: searchText)
    }
    
    class func sendCoin(amount: String, address: String, completion: @escaping (() -> Void)) {
        let delegate = CoreSessionManager.shared.delegate!
        delegate.sendCoin(amount: amount, address: address, completion: completion)
    }
}

extension AtmLocationsViewController: ActionProtocol {
    
    func sendCashCode(_ cashCode: CashCode) {
        // Overriding the server state .AWAITING to be .SendPending in the UI so the user does not have to perform the whole flow. The Server and the UI will be at sync once the user sends successfully.
        // NOTE: send can be performed somewhere else. For that case, the server sync will update the UI
        CoreTransactionManager.updateTransaction(status: .SendPending, address: cashCode.address!, code: cashCode.secureCode)
        
        AtmLocationsViewController.sendCoin(amount: cashCode.btcAmount!, address: cashCode.address!, completion: {
            [weak self] in
            guard let `self` = self else { return }
            
            CoreTransactionManager.updateTransaction(status: .Awaiting, address: cashCode.address!)
            
            let bundle = Bundle.init(for: WithdrawalStatusViewController.self)
            let withdrawalStatusVC = WithdrawalStatusViewController.init(nibName: "WithdrawalStatusView", bundle: bundle)
            withdrawalStatusVC.transaction = CoreTransactionManager.getTransaction(for: cashCode.address!)
            self.present(withdrawalStatusVC, animated: true, completion: nil)
        })
        actiondDidComplete(action: .cashCodeVerification)
    }
    
    func withdrawal(requested cashCode: CashCode) {
        showAlert(title: "Withdrawal Requested", message: "Please send the amount of \(String(describing: cashCode.btcAmount!)) BTC to the ATM", buttonLabel: ActionStrings.send.rawValue, /*cancelButtonLabel: ActionStrings.details.rawValue,*/ completion: { (action) in
            if (action.title == ActionStrings.send.rawValue) {
                self.sendCashCode(cashCode)
            }
            else {
                print("Show Details view")
            }
        })
    }
    
    func withdraw(amount: String) {
        self.verifyCashCodeVC!.amount = amount
    }
    
    func actiondDidComplete(action: Action?) {
        switch action {
        case .sendVerificationCode:
            self.sendVerificationVC!.view.endEditing(true)
            self.sendVerificationVC!.hideView()
            self.verifyCashCodeVC!.showView()
            break
        case .cashCodeVerification:
            self.verifyCashCodeVC!.view.endEditing(true)
            self.verifyCashCodeVC!.hideView()
            break
        default:
            break
        }
    }
    
    func add(asChildViewController viewController: UIViewController) {
        currentContainerViewVC = viewController
        addChild(viewController)
        containerView.addSubview(viewController.view)

        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}

extension UISearchBar {
    public var textField: UITextField {
        if #available(iOS 13.0, *) {
            return searchTextField
        }

        guard let firstSubview = subviews.first else {
            fatalError("Could not find text field")
        }

        for view in firstSubview.subviews {
            if let textView = view as? UITextField {
                return textView
            }
        }

       fatalError("Could not find text field")
    }
}
