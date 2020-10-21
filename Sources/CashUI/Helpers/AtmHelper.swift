
import Foundation
import CashCore

public class AtmHelper {
    
    public static func cityStateZip(for atm: AtmMachine) -> String? {
        if let city = atm.city,
            let state = atm.state,
            let zip = atm.zip {
            var address = [city, state, zip]
            address = address.filter { $0 != ""}
            return address.joined(separator: ", ")
        }
        return nil
    }
}
