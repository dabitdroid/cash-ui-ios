
import Foundation

extension String {
    var boolValue: Bool {
        return (self as NSString).boolValue
        
    }
    
    var isValidPhoneNumber: Bool {
        guard !isEmpty else { return false }
        
        let phoneNumberRegex = "[(]?\\d{3}[)]?[(\\s)?-]?\\d{3}[\\s-]?\\d{4}"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        
        return phoneNumberPredicate.evaluate(with: self)
    }
}
