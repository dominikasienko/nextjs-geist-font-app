import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Button(action: login) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Login")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .disabled(isLoading)

                NavigationLink("Forgot Password?", destination: ForgotPasswordView())

                NavigationLink("Don't have an account? Register", destination: RegistrationView())
            }
            .padding()
        }
    }

    private func login() {
        isLoading = true
        errorMessage = nil
        authViewModel.login(email: email, password: password) { result in
            isLoading = false
            switch result {
            case .success:
                // Handle successful login, e.g., dismiss login view
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
