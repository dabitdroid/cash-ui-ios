
import Foundation

protocol Persistable {
    func setObject<CoreTransaction>(_ object: CoreTransaction) throws where CoreTransaction: Encodable
    func setObjects(_ objects: [CoreTransaction]) throws
    func getAllObjects() throws -> [CoreTransaction]
    func updateObject(_ object: CoreTransaction) throws
    func removeAllObjects()
    func setUser<CoreUser>(_ user: CoreUser) throws where CoreUser: Encodable
    func getUser<CoreUser>() throws -> CoreUser where CoreUser: Decodable
}

enum PersistableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}

extension UserDefaults: Persistable {
    
    static let defaultKey = Keys.Transactions.rawValue
    
    enum Keys: String, CaseIterable {
        case Transactions
        case Hello
        case User
    }
    
    func removeAllObjects() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }
    
    func setObjects(_ objects: [CoreTransaction]) throws {
        do {
            let data = try JSONEncoder().encode(objects)
            set(data, forKey: UserDefaults.defaultKey)
        }
        catch {
            throw PersistableError.unableToEncode
        }
    }
    
    func setObject<CoreTransaction>(_ object: CoreTransaction) throws where CoreTransaction: Encodable {
        let encoder = JSONEncoder()
        do {
            var allObjects: [CoreTransaction] = try getAllObjects() as! [CoreTransaction]
            allObjects.append(object)
            let data = try encoder.encode(allObjects)
            set(data, forKey: UserDefaults.defaultKey)
        } catch {
            throw PersistableError.unableToEncode
        }
    }
    
    func convertTransaction(_ transaction: WACTransaction) -> CoreTransaction {
        var migratedTransaction = CoreTransaction(status: transaction.status, atm: transaction.atm, code: transaction.code)
        migratedTransaction.timestamp = transaction.timestamp
        migratedTransaction.pCode = transaction.pCode
        return migratedTransaction
    }
    
    func migrateTransactions() -> [CoreTransaction]  {
        guard let data = value(forKey: Keys.Hello.rawValue) as? Data else { return [] }
        let decoder = JSONDecoder()
        do {
            let objects = try decoder.decode([WACTransaction].self, from: data)
            
            var newObjects: [CoreTransaction] = []
            for transaction in objects {
                let newTransaction = convertTransaction(transaction)
                newObjects.append(newTransaction)
            }
            if newObjects.count > 0 {
                removeObject(forKey: Keys.Hello.rawValue)
                try setObjects(newObjects)
            }
            return newObjects
        } catch {
            return []
        }
    }
    
    func getAllObjects() throws -> [CoreTransaction] {
        let oldData = value(forKey: Keys.Hello.rawValue) as? Data
        if oldData == nil {
            guard let data = value(forKey: UserDefaults.defaultKey) as? Data else { return [] }
            let decoder = JSONDecoder()
            do {
                let objects = try decoder.decode([CoreTransaction].self, from: data)
                return objects
            } catch {
                throw PersistableError.unableToDecode
            }
        } else {
            return migrateTransactions()
        }
    }
    
    func updateObject(_ object: CoreTransaction) throws {
        let encoder = JSONEncoder()
        do {
            var allObjects: [CoreTransaction] = try getAllObjects()
            for (index, transaction) in allObjects.enumerated() {
                if transaction == object {
                    allObjects[index] = transaction
                }
            }
            let data = try encoder.encode(allObjects)
            set(data, forKey: UserDefaults.defaultKey)
        } catch {
            throw PersistableError.unableToEncode
        }
    }
    
    func setUser<CoreUser>(_ user: CoreUser) throws where CoreUser: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(user)
            set(data, forKey: Keys.User.rawValue)
        } catch {
            throw PersistableError.unableToEncode
        }
    }
    
    func getUser<CoreUser>() throws -> CoreUser where CoreUser: Decodable {
        guard let data = data(forKey: Keys.User.rawValue) else { throw PersistableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(CoreUser.self, from: data)
            return object
        } catch {
            throw PersistableError.unableToDecode
        }
    }
}
