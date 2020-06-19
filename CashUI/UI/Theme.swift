
import Foundation
import UIKit

class Theme {
    
    enum ColorHex: String {
        case primaryBackground = "#141233"
        case secondaryBackground = "#211F3F"
        case tertiaryBackground = "#312F4C"
        
        case text = "#FFFFFF"
        
        case accent = "#5B6DEE"
        case accentHighlighted = "#5667E0"
        case success = "#5BE081"
        case error = "#EA6654"
    }
    
    //
    // Colors
    //
    
    static var primaryBackground: UIColor {
        return color(.primaryBackground)
    }
    
    static var secondaryBackground: UIColor {
        return color(.secondaryBackground)
    }
    
    static var tertiaryBackground: UIColor {
        return color(.tertiaryBackground)
    }
    
    // returns a color with the given enum
    private static func color(_ hex: ColorHex) -> UIColor {
        return UIColor.fromHex(hex.rawValue)
    }
}
