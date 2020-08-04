# cash-ui-ios

This is the UI framework for the Cash project.
This framework allows the redemption process as well as newly implemented features to be independent of any wallet integrations.

It is an approach to solve issues like:
* UI and unit tests of our flows without any other project dependency.
* Removes the dependency from any wallet. 
  * the code can be ported to any wallet without changing the UI and with the simplicity of jsut adding a few lines of code to make it work
  * avoids conflcts. If it was integrated with a parent project (currently to bread wallet).
  

## Usage

Right now the code that any wallet needs to implement is:

Setup the packages:
````
CoreSessionManager.shared.start()
CoreSessionManager.shared.delegate = self
````

To show the menu view (this view is the triggering point for all the flow)
````
let vc = CashUI.MenuViewController()
navigationController.pushViewController(vc, animated: true)
````

Implementation of the SessionManagerDelegate is mandatory, as the framework needs the wallet's implementation to send coin. 
````
extension AppDelegate: CoreSessionManagerDelegate {
    
    func sendCoin(amount: String, address: String, completion: @escaping (() -> Void)) {
        let applicationController = self.applicationController
        let modalPresenter = applicationController.modalPresenter
        
        let currencyId = Currencies.btc.uid
        modalPresenter!.presentModal(for: currencyId, amount: amount, address: address, completion: {
            completion()
        })
    }
}
````


Any other views can also be shown like
````
func presentActivity() {
    let vc = ActivityViewController()
    self.topViewController?.present(vc, animated: true, completion: nil)
}
````

The current version of the package does not allow Resources as the version of Swift used does not allow it. Once we move to Swift 5.3 all of the resources used but the package can be included within it. The list of Resources that need to be included in the wallet's UI are:

XIB's
````
SendVerificationView.xib
ActivityView.xib
AtmLocationsView.xib
VerifyCashCode.xib
WithdrawalStatusView.xib
ListView.xib
ActivityTableViewCell.xib
MenuView.xib
AtmInfoView.xib
````

Images - As part of a .xcassets file
````
atmGrey
atmWhite
Close
Help
````

Other Resources (like Strings) may also need to be included
