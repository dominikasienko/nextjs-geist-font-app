import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var message: String?
    @State private var isLoading: Bool = false
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let message = message {
                Text(message)
                    .foregroundColor(.green)
            }

            Button(action: resetPassword) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Send Reset Link")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(isLoading)

            Spacer()
        }
        .padding()
    }

    private func resetPassword() {
        isLoading = true
        message = nil
        authViewModel.resetPassword(email: email) { error in
            isLoading = false
            if let error = error {
                message = "Error: \(error.localizedDescription)"
            } else {
                message = "Password reset link sent to your email."
            }
        }
    }
}
