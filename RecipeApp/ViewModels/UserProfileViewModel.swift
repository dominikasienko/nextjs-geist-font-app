import Foundation
import Combine
import FirebaseAuth

class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        FirebaseService.shared.fetchUserProfile(userId: userId) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let profile = try JSONDecoder().decode(UserProfile.self, from: jsonData)
                    DispatchQueue.main.async {
                        self?.userProfile = profile
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Failed to decode user profile."
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func updateUserProfile(_ profile: UserProfile) {
        FirebaseService.shared.saveUserProfile(userId: profile.id, data: profile.dictionary) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.userProfile = profile
                }
            }
        }
    }
}

private extension UserProfile {
    var dictionary: [String: Any] {
        [
            "email": email,
            "displayName": displayName ?? "",
            "weight": weight ?? 0,
            "height": height ?? 0,
            "activityLevel": activityLevel ?? "",
            "preferredLanguage": preferredLanguage ?? "en",
            "themePreference": themePreference ?? "system",
            "favoriteRecipeIDs": favoriteRecipeIDs ?? [],
            "dietPreference": dietPreference ?? "",
            "sex": sex ?? ""
        ]
    }
}
