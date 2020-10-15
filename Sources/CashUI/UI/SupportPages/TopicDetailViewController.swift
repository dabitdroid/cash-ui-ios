
import Foundation
import UIKit
import CashCore

public class TopicDetailViewController: UIViewController {
    
    public var topic: Support.Topic?
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.primaryBackground
        
        self.contentTextView.textColor = UIColor(white: 1, alpha: 0.65)
        self.titleLabel.textColor = .white
        self.contentTextView.text = topic?.content
        self.titleLabel.text = topic?.title
    }
}
