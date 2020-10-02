
import Foundation
import UIKit
import CashCore

class TopicDetailViewController: UIViewController {
    
    public var topic: Support.Topic?
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.primaryBackground
//        setUpNavBar()
//        navigationController?.navigationBar.barTintColor = Theme.primaryBackground
//        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.contentTextView.textColor = UIColor(white: 1, alpha: 0.65)
        self.titleLabel.textColor = .white
        self.contentTextView.text = topic?.content
        self.titleLabel.text = topic?.title
    }
    
    func setUpNavBar(){
        //For title in navigation bar
//        self.navigationController?.view.backgroundColor = UIColor.white
        self.navigationController?.view.tintColor = UIColor(white: 1, alpha: 0.65)

        //For back button in navigation bar
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
}
