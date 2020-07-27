
import Foundation

protocol Persistable {
    func setObject<CoreTransaction>(_ object: CoreTransaction) throws where CoreTransaction: Encodable
    func setObjects(_ objects: [CoreTransaction]) throws
    func getAllObjects() throws -> [CoreTransaction]
    func updateObject(_ object: CoreTransaction) throws
    func removeAllObjects()
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
    
    static let defaultKey = Keys.Hello.rawValue
    
    enum Keys: String, CaseIterable {
        case Hello
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
    
    func getAllObjects() throws -> [CoreTransaction] {
        guard let data = value(forKey: UserDefaults.defaultKey) as? Data else { return [] }
        let decoder = JSONDecoder()
        do {
            let objects = try decoder.decode([CoreTransaction].self, from: data)
            return objects
        } catch {
            throw PersistableError.unableToDecode
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
}
