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

To show the menu view (this view is the initial triggering point for all the flow)

````
let vc = WACMenuViewController()
navigationController.pushViewController(vc, animated: true)
````


Implementation of the WACSessionManagerDelegate is mandatory, as the framework needs the wallet's implementation to send coin. 

````
extension AppDelegate: WACSessionManagerDelegate {
    
    func sendCoin(amount: String, address: String, completion: @escaping (() -> Void)) {
        <Wallet Send function>
    }
}
````


Any other views can also be shown like

````
func presentActivity() {
    let vc = WACActivityViewController()
    self.topViewController?.present(vc, animated: true, completion: nil)
}
````

For any other information please refer to the Sample App located within the package