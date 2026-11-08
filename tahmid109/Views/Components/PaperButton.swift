import SwiftUI

/// Simple action button with loading state.
struct PaperButton: View {
    let title: String
    var icon: String = "arrow.right"
    var busy: Bool = false
    var backgroundColor: Color = AppTheme.primary
    var foregroundColor: Color = .white
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if busy {
                    ProgressView()
                        .tint(foregroundColor)
                }

                Text(title)
                    .font(.headline)

                if !busy && !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
        .disabled(busy)
    }
}
