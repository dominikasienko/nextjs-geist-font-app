import SwiftUI
import FirebaseAuth

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Image Selection
                Button(action: { showingImagePicker = true }) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(spacing: 15) {
                    // Display Name Field
                    TextField("Display Name", text: $displayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.name)
                    
                    // Email Field
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    // Password Field
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.newPassword)
                    
                    // Confirm Password Field
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.newPassword)
                }
                .padding(.horizontal)
                
                // Register Button
                Button(action: register) {
                    if authViewModel.isAuthenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Create Account")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(authViewModel.isAuthenticating || !isValidForm)
            }
            .padding(.vertical)
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Error", isPresented: .constant(authViewModel.error != nil)) {
            Button("OK") {
                authViewModel.error = nil
            }
        } message: {
            if let error = authViewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
    
    private var isValidForm: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        !displayName.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func register() {
        guard isValidForm else {
            showingError = true
            errorMessage = "Please check your input and try again."
            return
        }
        
        authViewModel.signUp(email: email, password: password, displayName: displayName)
    }
}

#Preview {
    NavigationView {
        RegistrationView()
            .environmentObject(AuthViewModel())
    }
}
