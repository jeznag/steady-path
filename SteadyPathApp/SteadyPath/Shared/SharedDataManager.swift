import Foundation

class SharedDataManager {
    static let shared = SharedDataManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.steadypath.shared")
    
    private init() {}
    
    var takingMedicine: Bool {
        get {
            userDefaults?.bool(forKey: "takingMedicine") ?? false
        }
        set {
            userDefaults?.set(newValue, forKey: "takingMedicine")
            userDefaults?.synchronize()
        }
    }
    
    var lastMedicationDate: Date {
        get {
            userDefaults?.object(forKey: "lastMedicationDate") as? Date ?? Date()
        }
        set {
            userDefaults?.set(newValue, forKey: "lastMedicationDate")
            userDefaults?.synchronize()
        }
    }
}