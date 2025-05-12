import Foundation
import FirebaseFirestore
import FirebaseStorage

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {}
    
    // MARK: - Nutrition Info Methods
    func saveNutritionInfo(recipeId: String, nutritionInfo: NutritionalInfo, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        do {
            try db.collection("users").document(userId)
                .collection("recipes").document(recipeId)
                .collection("nutrition").document("info")
                .setData(from: nutritionInfo) { error in
                    completion(error)
                }
        } catch {
            completion(error)
        }
    }
    
    func fetchNutritionInfo(recipeId: String, completion: @escaping (Result<NutritionalInfo, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        db.collection("users").document(userId)
            .collection("recipes").document(recipeId)
            .collection("nutrition").document("info")
            .getDocument { document, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = document,
                      let nutritionInfo = try? document.data(as: NutritionalInfo.self) else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode nutrition info"])))
                    return
                }
                
                completion(.success(nutritionInfo))
            }
    }
    
    // MARK: - Image Upload Methods
    func uploadImage(_ image: UIImage, path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let storageRef = storage.reference().child(path)
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    return
                }
                
                completion(.success(downloadURL))
            }
        }
    }
    
    func saveUserProfilePhotoURL(userId: String, url: URL, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId)
            .updateData(["photoURL": url.absoluteString]) { error in
                completion(error)
            }
    }
}
