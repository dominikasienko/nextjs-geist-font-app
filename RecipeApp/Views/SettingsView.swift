import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var userProfileVM = UserProfileViewModel()
    
    // Image picker state
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var profileImage: Image?
    
    // User info state
    @State private var displayName: String = ""
    @State private var email: String = ""
    
    // Alert state
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    VStack(alignment: .center) {
                        if let profileImage = profileImage {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        Button("Change Photo") {
                            showingImagePicker = true
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)

                    TextField("Display Name", text: $displayName)
                    TextField("Email", text: $email)
                        .disabled(true)
                }

                Section(header: Text("Account")) {
                    Button("Logout") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(.red)

                    Button("Delete Account") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    authViewModel.deleteAccount()
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
            .onAppear {
                if let user = authViewModel.currentUser {
                    email = user.email ?? ""
                    userProfileVM.fetchUserProfile()
                }
            }
        }
    }

    private func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
        
        if let userId = authViewModel.currentUser?.uid {
            let imagePath = "profile_photos/\(userId).jpg"
            FirebaseService.shared.uploadImage(inputImage, path: imagePath) { result in
                switch result {
                case .success(let url):
                    FirebaseService.shared.saveUserProfilePhotoURL(userId: userId, url: url) { error in
                        if let error = error {
                            print("Failed to save profile photo URL: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    print("Failed to upload profile photo: \(error.localizedDescription)")
                }
            }
        }
    }
}
