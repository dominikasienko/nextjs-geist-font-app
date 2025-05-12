import Foundation

struct UserProfile: Codable {
    var id: String
    var email: String
    var displayName: String?
    var weight: Double?
    var height: Double?
    var activityLevel: String? // e.g., sedentary, active, etc.
    var preferredLanguage: String?
    var themePreference: String? // light, dark, system
    var favoriteRecipeIDs: [String]?
    var dietPreference: String? // e.g., vegan, keto, etc.
    var sex: String? // e.g., male, female, other
}
