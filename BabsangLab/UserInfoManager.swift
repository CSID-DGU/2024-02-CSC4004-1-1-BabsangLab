import Foundation

class UserInfoManager {
    static let shared = UserInfoManager()
    private init() {}

    var userId: String? {
        get { UserDefaults.standard.string(forKey: "userId") }
        set { UserDefaults.standard.set(newValue, forKey: "userId") }
    }

    var password: String? {
        get { UserDefaults.standard.string(forKey: "password") }
        set { UserDefaults.standard.set(newValue, forKey: "password") }
    }

    var name: String? {
        get { UserDefaults.standard.string(forKey: "name") }
        set { UserDefaults.standard.set(newValue, forKey: "name") }
    }

    var age: Int? {
        get { UserDefaults.standard.integer(forKey: "age") == 0 ? nil : UserDefaults.standard.integer(forKey: "age") }
        set { UserDefaults.standard.set(newValue, forKey: "age") }
    }

    var gender: String? {
        get { UserDefaults.standard.string(forKey: "gender") }
        set { UserDefaults.standard.set(newValue, forKey: "gender") }
    }

    var height: Double? {
        get { UserDefaults.standard.double(forKey: "height") == 0 ? nil : UserDefaults.standard.double(forKey: "height") }
        set { UserDefaults.standard.set(newValue, forKey: "height") }
    }

    var weight: Double? {
        get { UserDefaults.standard.double(forKey: "weight") == 0 ? nil : UserDefaults.standard.double(forKey: "weight") }
        set { UserDefaults.standard.set(newValue, forKey: "weight") }
    }

    var medHistory: String? {
        get { UserDefaults.standard.string(forKey: "medHistory") }
        set { UserDefaults.standard.set(newValue, forKey: "medHistory") }
    }

    var allergy: String? {
        get { UserDefaults.standard.string(forKey: "allergy") }
        set { UserDefaults.standard.set(newValue, forKey: "allergy") }
    }

    var weightGoal: String? {
        get { UserDefaults.standard.string(forKey: "weightGoal") }
        set { UserDefaults.standard.set(newValue, forKey: "weightGoal") }
    }

    func clearUserInfo() {
        let keys = [
            "userId", "password", "name", "age", "gender",
            "height", "weight", "medHistory", "allergy", "weightGoal"
        ]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
}

