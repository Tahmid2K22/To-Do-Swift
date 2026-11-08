import Foundation

/// Filter options for viewing tasks in the workspace.
enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case open = "Open"
    case done = "Done"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .all: return "square.stack.fill"
        case .open: return "circle"
        case .done: return "checkmark.circle.fill"
        }
    }

    /// Determines if a task matches the current filter.
    func matches(_ task: TodoItem) -> Bool {
        switch self {
        case .all:
            return true
        case .open:
            return !task.completed
        case .done:
            return task.completed
        }
    }
}
