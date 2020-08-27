//
//  Created by Giancarlo Pacheco on 8/21/20.
//

import UIKit

class CustomButton: UIButton {

    override open var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? Theme.color(.accent) : UIColor.gray
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.blue : Theme.color(.accent)
        }
    }
}
