import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var displayName: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var activityLevel: String = ""
    @State private var selectedLanguage: String = "en"
    @State private var selectedTheme: String = "system"
    @State private var errorMessage: String?
    @State private var showDeleteAlert = false

    let languages = ["en": "English", "it": "Italian", "fr": "French", "es": "Spanish"]
    let themes = ["light": "Light", "dark": "Dark", "system": "System"]

    var body: some View {
        Form {
Section(header: Text("Profile")) {
    TextField("Display Name", text: $displayName)
    TextField("Weight (kg)", text: $weight)
        .keyboardType(.decimalPad)
    TextField("Height (cm)", text: $height)
        .keyboardType(.decimalPad)
    TextField("Activity Level", text: $activityLevel)
    Picker("Diet Preference", selection: $dietPreference) {
        Text("None").tag("none")
        Text("Vegan").tag("vegan")
        Text("Keto").tag("keto")
        Text("Vegetarian").tag("vegetarian")
        Text("Paleo").tag("paleo")
    }
    Picker("Sex", selection: $sex) {
        Text("Male").tag("male")
        Text("Female").tag("female")
        Text("Other").tag("other")
    }
}

            Section(header: Text("Preferences")) {
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(languages.keys.sorted(), id: \.self) { key in
                        Text(languages[key] ?? key).tag(key)
                    }
                }
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(themes.keys.sorted(), id: \.self) { key in
                        Text(themes[key] ?? key).tag(key)
                    }
                }
            }

            Section {
                Button("Change Password") {
                    // Navigate to change password view or trigger password change flow
                }
                Button("Logout") {
                    do {
                        try authViewModel.logout()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
                Button("Delete Account") {
                    showDeleteAlert = true
                }
                .foregroundColor(.red)
            }

            if let errorMessage = errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear(perform: loadUserProfile)
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteAccount()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func loadUserProfile() {
        if let profile = userProfileVM.userProfile {
            displayName = profile.displayName ?? ""
            weight = profile.weight != nil ? String(profile.weight!) : ""
            height = profile.height != nil ? String(profile.height!) : ""
            activityLevel = profile.activityLevel ?? ""
            selectedLanguage = profile.preferredLanguage ?? "en"
            selectedTheme = profile.themePreference ?? "system"
        }
    }

    private func deleteAccount() {
        authViewModel.deleteAccount { result in
            switch result {
            case .success:
                // Handle post-deletion UI update or navigation
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
