import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    func fetchUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        db.collection("users")
            .document(userId)
            .getDocument { [weak self] document, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.error = error
                        return
                    }
                    
                    if let document = document,
                       let profile = try? document.data(as: UserProfile.self) {
                        self.userProfile = profile
                    } else {
                        // Create default profile if none exists
                        let defaultProfile = UserProfile(
                            id: userId,
                            displayName: Auth.auth().currentUser?.displayName ?? "User",
                            email: Auth.auth().currentUser?.email ?? "",
                            photoURL: Auth.auth().currentUser?.photoURL?.absoluteString,
                            preferences: UserPreferences()
                        )
                        self.saveUserProfile(defaultProfile)
                    }
                }
            }
    }
    
    func saveUserProfile(_ profile: UserProfile) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            try db.collection("users")
                .document(userId)
                .setData(from: profile) { [weak self] error in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        self.isLoading = false
                        if let error = error {
                            self.error = error
                        } else {
                            self.userProfile = profile
                        }
                    }
                }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.error = error
            }
        }
    }
    
    func updateProfile(displayName: String? = nil,
                      photoURL: String? = nil,
                      preferences: UserPreferences? = nil) {
        guard var updatedProfile = userProfile else { return }
        
        if let displayName = displayName {
            updatedProfile.displayName = displayName
        }
        
        if let photoURL = photoURL {
            updatedProfile.photoURL = photoURL
        }
        
        if let preferences = preferences {
            updatedProfile.preferences = preferences
        }
        
        saveUserProfile(updatedProfile)
    }
    
    func clearUserProfile() {
        userProfile = nil
        error = nil
    }
}

struct UserPreferences: Codable {
    var darkMode: Bool = false
    var notificationsEnabled: Bool = true
    var mealPlanReminders: Bool = true
    var shoppingListReminders: Bool = true
    var defaultServings: Int = 4
    var measurementSystem: MeasurementSystem = .metric
    
    enum MeasurementSystem: String, Codable {
        case metric
        case imperial
    }
}
