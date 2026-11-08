import SwiftUI

/// Simple task card row displaying completion status, title, details, and actions.
struct TaskCardView: View {
    let task: TodoItem
    let displayIndex: Int
    var isSaving: Bool
    var onToggle: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Checkmark Toggle Button
            Button(action: onToggle) {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(task.completed ? AppTheme.success : AppTheme.secondaryText)
            }
            .buttonStyle(.plain)
            .disabled(isSaving)
            .accessibilityLabel(task.completed ? "Mark \(task.title) as incomplete" : "Complete \(task.title)")

            // Task Content
            Button(action: onEdit) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.completed)
                        .foregroundStyle(task.completed ? AppTheme.secondaryText : AppTheme.text)
                        .multilineTextAlignment(.leading)

                    if !task.detail.isEmpty {
                        Text(task.detail)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(task.relativeTimeString)
                            .font(.caption2)
                    }
                    .foregroundStyle(AppTheme.secondaryText.opacity(0.8))
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens task editor")

            // Context Menu
            Menu {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button {
                    onToggle()
                } label: {
                    Label(task.completed ? "Mark Open" : "Mark Done", systemImage: task.completed ? "circle" : "checkmark.circle")
                }

                Button {
                    UIPasteboard.general.string = "\(task.title)\n\n\(task.detail)"
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }

                Divider()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .disabled(isSaving)
            .accessibilityLabel("Options for \(task.title)")
        }
        .padding(14)
        .background(
            task.completed ? AppTheme.cardCompletedBackground : AppTheme.cardBackground,
            in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.separator, lineWidth: 1)
        )
    }
}
