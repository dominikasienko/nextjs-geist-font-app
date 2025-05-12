import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Authentication

    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                completion(.success(user))
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                completion(.success(user))
            }
        }
    }

    func signOut() throws {
        try auth.signOut()
    }

    func sendPasswordReset(email: String, completion: @escaping (Error?) -> Void) {
        auth.sendPasswordReset(withEmail: email, completion: completion)
    }

    var currentUser: User? {
        auth.currentUser
    }

    // MARK: - Firestore User Data

    func saveUserProfile(userId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).setData(data, merge: true, completion: completion)
    }

    func fetchUserProfile(userId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = document?.data() {
                completion(.success(data))
            } else {
                completion(.success([:]))
            }
        }
    }

    // Additional Firestore methods for recipes, meal plans, shopping lists, favorites can be added here
}
