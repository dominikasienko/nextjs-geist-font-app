import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var displayName: String
    var email: String
    var photoURL: String?
    var preferences: UserPreferences
    var favoriteRecipes: [String] = []
    var lastLoginDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case email
        case photoURL
        case preferences
        case favoriteRecipes
        case lastLoginDate
    }
    
    init(id: String? = nil,
         displayName: String,
         email: String,
         photoURL: String? = nil,
         preferences: UserPreferences = UserPreferences(),
         favoriteRecipes: [String] = [],
         lastLoginDate: Date? = Date()) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.photoURL = photoURL
        self.preferences = preferences
        self.favoriteRecipes = favoriteRecipes
        self.lastLoginDate = lastLoginDate
    }
}

extension UserProfile {
    static var mock: UserProfile {
        UserProfile(
            id: "mock-user-id",
            displayName: "Test User",
            email: "test@example.com",
            photoURL: nil,
            preferences: UserPreferences(),
            favoriteRecipes: [],
            lastLoginDate: Date()
        )
    }
}
