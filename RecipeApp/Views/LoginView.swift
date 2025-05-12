import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegistration = false
    @State private var showingForgotPassword = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo or App Name
            Text("Recipe App")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                // Email Field
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                // Password Field
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
                
                // Login Button
                Button(action: login) {
                    if authViewModel.isAuthenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(authViewModel.isAuthenticating)
                
                // Forgot Password
                Button("Forgot Password?") {
                    showingForgotPassword = true
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            // Register Button
            Button(action: { showingRegistration = true }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .sheet(isPresented: $showingRegistration) {
            NavigationView {
                RegistrationView()
            }
        }
        .sheet(isPresented: $showingForgotPassword) {
            NavigationView {
                ForgotPasswordView()
            }
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
    
    private func login() {
        guard !email.isEmpty && !password.isEmpty else { return }
        authViewModel.signIn(email: email, password: password)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
