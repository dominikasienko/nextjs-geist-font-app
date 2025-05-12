import Foundation
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticating = false
    @Published var error: Error?
    
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        currentUser = Auth.auth().currentUser
    }
    
    func signIn(email: String, password: String) {
        isAuthenticating = true
        error = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isAuthenticating = false
                
                if let error = error {
                    self.error = error
                    return
                }
                
                self.currentUser = result?.user
            }
        }
    }
    
    func signUp(email: String, password: String, displayName: String) {
        isAuthenticating = true
        error = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.error = error
                    self.isAuthenticating = false
                    return
                }
                
                if let user = result?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { [weak self] error in
                        DispatchQueue.main.async {
                            self?.isAuthenticating = false
                            if let error = error {
                                self?.error = error
                                return
                            }
                            self?.currentUser = user
                        }
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
        } catch {
            self.error = error
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func updateEmail(to newEmail: String, completion: @escaping (Error?) -> Void) {
        currentUser?.updateEmail(to: newEmail) { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func updatePassword(to newPassword: String, completion: @escaping (Error?) -> Void) {
        currentUser?.updatePassword(to: newPassword) { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
}
