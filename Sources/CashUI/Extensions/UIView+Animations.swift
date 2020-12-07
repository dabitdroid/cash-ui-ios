// 
//  UIView+Animations.swift
//
//  Created by Giancarlo Pacheco on 5/13/20.
//

import UIKit

extension UIView {
    func close(to yCoordinate: CGFloat) {
        UIView.animate(withDuration: 0.3, animations: {
            let frame = self.frame
            self.frame = CGRect(x: 0, y: yCoordinate, width: frame.width, height: frame.height)
        })
    }
    
    func constrain(_ constraints: [NSLayoutConstraint?]) {
        guard superview != nil else { assert(false, "Superview cannot be nil when adding contraints"); return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints.compactMap { $0 })
    }
}

