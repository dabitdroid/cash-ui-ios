
import UIKit

extension UISearchBar {
    
    public var textFld: UITextField? {
        if #available(iOS 13, *) {
            return searchTextField
        }
        let subViews = subviews.flatMap { $0.subviews }
        guard let textFld = (subViews.filter { $0 is UITextField }).first as? UITextField else {
            return nil
        }
        return textFld
    }

    public func clearBackgroundColor() {
        guard let UISearchBarBackground: AnyClass = NSClassFromString("UISearchBarBackground") else { return }

        for view in subviews {
            for subview in view.subviews where subview.isKind(of: UISearchBarBackground) {
                subview.alpha = 0
            }
        }
        setBackgroundColor()
    }
    
    public func setBackgroundColor() {
        guard let UISearchBarSearchFieldBackgroundView: AnyClass = NSClassFromString("_UISearchBarSearchFieldBackgroundView") else { return }

        for subview in textFld!.subviews where subview.isKind(of: UISearchBarSearchFieldBackgroundView) {
            for view in subview.subviews where subview.isKind(of: UISearchBarSearchFieldBackgroundView) {
                view.removeFromSuperview()
            }
            let image = ImageHelper.ovalImage(with: subview.bounds)
            subview.layer.borderColor = UIColor.clear.cgColor
            subview.layer.backgroundColor = UIColor.clear.cgColor
            subview.layer.contents = image.cgImage
        }
    }
}
