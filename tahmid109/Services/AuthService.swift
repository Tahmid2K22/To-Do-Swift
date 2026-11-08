import Foundation
import FirebaseAuth
import FirebaseCore

/// Protocol defining authentication operations.
protocol AuthServiceProtocol: AnyObject {
    var isConfigured: Bool { get }
    var currentUser: User? { get }
    func addStateChangeListener(_ handler: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle?
    func removeStateChangeListener(_ handle: AuthStateDidChangeListenerHandle)
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() throws
    func sendPasswordReset(email: String) async throws
}

/// Firebase implementation of authentication service.
final class FirebaseAuthService: AuthServiceProtocol {
    static let shared = FirebaseAuthService()

    var isConfigured: Bool {
        FirebaseApp.app() != nil
    }

    var currentUser: User? {
        guard isConfigured else { return nil }
        return Auth.auth().currentUser
    }

    func addStateChangeListener(_ handler: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle? {
        guard isConfigured else { return nil }
        return Auth.auth().addStateDidChangeListener { _, user in
            handler(user)
        }
    }

    func removeStateChangeListener(_ handle: AuthStateDidChangeListenerHandle) {
        guard isConfigured else { return }
        Auth.auth().removeStateDidChangeListener(handle)
    }

    func signIn(email: String, password: String) async throws -> User {
        guard isConfigured else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase is not configured."])
        }
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }

    func signUp(email: String, password: String) async throws -> User {
        guard isConfigured else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase is not configured."])
        }
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user
    }

    func signOut() throws {
        guard isConfigured else { return }
        try Auth.auth().signOut()
    }

    func sendPasswordReset(email: String) async throws {
        guard isConfigured else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase is not configured."])
        }
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
