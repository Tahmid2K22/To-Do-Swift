import SwiftUI

/// ViewModel for managing the authentication screen state and user interactions.
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isRegister: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showPassword: Bool = false
    @Published var resetEmailSent: Bool = false

    // MARK: - Validation
    var cleanEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isEmailValid: Bool {
        cleanEmail.contains("@") && cleanEmail.contains(".") && cleanEmail.count >= 5
    }

    var isPasswordValid: Bool {
        password.count >= 6
    }

    var canSubmit: Bool {
        isEmailValid && isPasswordValid
    }

    // MARK: - Actions
    func toggleMode() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isRegister.toggle()
        }
    }

    func togglePasswordVisibility() {
        showPassword.toggle()
    }

    func submit(with appViewModel: AppViewModel) async {
        guard canSubmit else { return }
        await appViewModel.authenticate(
            email: cleanEmail,
            password: password,
            register: isRegister
        )
    }

    func resetPassword(with appViewModel: AppViewModel) async {
        guard isEmailValid else { return }
        let success = await appViewModel.resetPassword(email: cleanEmail)
        if success {
            resetEmailSent = true
        }
    }
}
