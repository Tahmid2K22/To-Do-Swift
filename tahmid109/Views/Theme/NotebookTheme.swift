import SwiftUI

/// Clean and simple color palette and styling constants for TodoApp109.
enum AppTheme {
    // Primary brand / tint
    static let primary = Color.blue
    static let accent = Color.blue

    // Clean system background colors
    static let background = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let inputBackground = Color(uiColor: .tertiarySystemGroupedBackground)
    static let separator = Color(uiColor: .separator).opacity(0.5)

    // Text colors
    static let text = Color.primary
    static let secondaryText = Color.secondary
    static let muted = Color(uiColor: .tertiaryLabel)

    // Status colors
    static let completed = Color.gray
    static let success = Color.green
    static let danger = Color.red

    // Radiuses
    static let cornerRadius: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusPill: CGFloat = 20
}

/// Compatibility alias to support existing references cleanly.
typealias NotebookTheme = AppTheme

extension AppTheme {
    // Backwards-compatible aliases mapping to clean modern styles
    static var paper: Color { background }
    static var ink: Color { text }
    static var orange: Color { primary }
    static var line: Color { separator }
    static var cardCompletedBackground: Color { cardBackground.opacity(0.7) }
    static var cornerRadiusMedium: CGFloat { cornerRadius }
    static var cornerRadiusCard: CGFloat { cornerRadius }
    static var cornerRadiusBanner: CGFloat { cornerRadiusLarge }
}
