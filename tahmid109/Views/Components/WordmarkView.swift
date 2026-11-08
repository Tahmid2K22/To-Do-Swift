import SwiftUI

/// Clean brand header for TodoApp109.
struct WordmarkView: View {
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.primary)
                .font(.system(size: 20, weight: .bold))

            Text("TodoApp109")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(AppTheme.text)

            if let subtitle = subtitle {
                Text("•")
                    .foregroundStyle(AppTheme.secondaryText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
    }
}
