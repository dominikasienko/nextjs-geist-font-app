import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enter your email address and we'll send you a link to reset your password.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.horizontal)
            
            Button(action: resetPassword) {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Send Reset Link")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(email.isEmpty || isProcessing)
            
            if isSuccess {
                Text("Reset link sent! Check your email.")
                    .foregroundColor(.green)
                    .padding(.top)
            }
        }
        .padding()
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert(isSuccess ? "Success" : "Error", isPresented: $showingAlert) {
            Button("OK") {
                if isSuccess {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func resetPassword() {
        guard !email.isEmpty else { return }
        
        isProcessing = true
        
        authViewModel.resetPassword(email: email) { error in
            isProcessing = false
            showingAlert = true
            
            if let error = error {
                isSuccess = false
                alertMessage = error.localizedDescription
            } else {
                isSuccess = true
                alertMessage = "Password reset link has been sent to your email."
            }
        }
    }
}

#Preview {
    NavigationView {
        ForgotPasswordView()
            .environmentObject(AuthViewModel())
    }
}
