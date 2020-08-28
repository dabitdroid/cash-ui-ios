import Foundation
import CashCore

public struct WACTransaction: CustomStringConvertible, Codable, Equatable {
    
    public var id: String
    public var timestamp: Double
    public var status: CoreTransactionStatus
    public var atm: AtmMachine?
    public var code: CashCode?
    public var pCode: String?
    public var color: String {
        get {
            return color(for: status)
        }
    }
    
    public init(status: CoreTransactionStatus, atm: AtmMachine? = nil, code: CashCode? = nil) {
        self.id = UUID().uuidString
        self.timestamp = Date().timeIntervalSince1970
        self.status = status
        self.atm = atm
        self.code = code
        self.pCode = nil
    }
    
    public var description: String {
        return "\(timestamp) = \(status.rawValue)"
    }

    private func color(for status:CoreTransactionStatus) -> String {
        // Colors have to be 6 characters long
        switch status {
        case .VerifyPending:
            return "a65e93"
        case .SendPending:
            return "f2a900"
        case .Awaiting:
            return "67cbb"
        case .FundedNotConfirmed:
            return "a6955e"
        case .Funded:
            return "5ea671"
        case .Withdrawn:
            return "ff5193"
        case .Cancelled:
            return "5e6fa5"
        }
    }
    
    public static func == (lhs: WACTransaction, rhs: WACTransaction) -> Bool {
        return lhs.timestamp == rhs.timestamp
    }
}

