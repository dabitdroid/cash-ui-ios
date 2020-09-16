//
//  Created by Giancarlo Pacheco on 8/21/20.
//

import UIKit

class CustomButton: UIButton {
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.withAlphaComponent(0.5).cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

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
