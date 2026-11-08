import Foundation

/// Represents the active user profile or demo identity in TodoApp109.
struct AppUser: Equatable, Identifiable {
    let id: String
    let email: String
    let isDemo: Bool

    var displayName: String {
        if isDemo {
            return "Demo User"
        }
        if let username = email.split(separator: "@").first {
            return String(username).capitalized
        }
        return "User"
    }

    static var demo: AppUser {
        AppUser(id: "demo-session-user", email: "demo@todoapp109.local", isDemo: true)
    }
}
