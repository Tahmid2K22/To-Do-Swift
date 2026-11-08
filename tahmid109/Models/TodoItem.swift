import Foundation

/// Represents a single task item in TodoApp109.
struct TodoItem: Identifiable, Equatable, Hashable, Codable {
    let id: String
    var title: String
    var detail: String
    var completed: Bool
    var createdAt: Date
    var updatedAt: Date?

    init(
        id: String = UUID().uuidString,
        title: String,
        detail: String,
        completed: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.completed = completed
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Validation Constants & Rules
    static let maxTitleLength = 120
    static let maxDetailLength = 5000

    var isTitleValid: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= Self.maxTitleLength
    }

    var isDetailValid: Bool {
        let trimmed = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= Self.maxDetailLength
    }

    var isValid: Bool {
        isTitleValid && isDetailValid
    }

    // MARK: - Formatted Strings
    var formattedCreationDate: String {
        createdAt.formatted(date: .abbreviated, time: .shortened)
    }

    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: .now)
    }

    // MARK: - Sample Data
    static var samples: [TodoItem] {
        [
            TodoItem(
                id: "sample-1",
                title: "Welcome to TodoApp109",
                detail: "Tap any task to edit notes. Tap the circle on the left to mark it as completed.",
                completed: false,
                createdAt: .now
            ),
            TodoItem(
                id: "sample-2",
                title: "Organize your daily tasks",
                detail: "Use the filter at the top to view All, Open, or Completed tasks.",
                completed: false,
                createdAt: .now.addingTimeInterval(-3600)
            ),
            TodoItem(
                id: "sample-3",
                title: "Completed sample task",
                detail: "This task is already finished. You can reopen it or delete it.",
                completed: true,
                createdAt: .now.addingTimeInterval(-86400)
            )
        ]
    }
}
