import SwiftUI

/// Route for task editor sheet presentation.
struct EditorRoute: Identifiable {
    let id = UUID()
    let task: TodoItem?
}

/// Simple ViewModel managing task filtering, search, and editing/deletion dialogs.
@MainActor
final class TaskListViewModel: ObservableObject {
    @Published var filter: TaskFilter = .all
    @Published var searchQuery: String = ""
    @Published var editorRoute: EditorRoute?
    @Published var showAccountSheet: Bool = false
    @Published var pendingDeleteTask: TodoItem?

    // MARK: - Displayed Tasks
    func displayedTasks(from tasks: [TodoItem]) -> [TodoItem] {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        return tasks.filter { task in
            // Filter by completion status
            guard filter.matches(task) else { return false }

            // Filter by search query if provided
            if !trimmedQuery.isEmpty {
                return task.title.localizedCaseInsensitiveContains(trimmedQuery) ||
                       task.detail.localizedCaseInsensitiveContains(trimmedQuery)
            }

            return true
        }
    }

    // MARK: - Counts
    func completedCount(from tasks: [TodoItem]) -> Int {
        tasks.filter(\.completed).count
    }

    func openCount(from tasks: [TodoItem]) -> Int {
        tasks.count - completedCount(from: tasks)
    }

    // MARK: - Actions
    func openNewTaskEditor() {
        editorRoute = EditorRoute(task: nil)
    }

    func openEditTaskEditor(for task: TodoItem) {
        editorRoute = EditorRoute(task: task)
    }

    func requestDelete(for task: TodoItem) {
        pendingDeleteTask = task
    }

    func confirmDelete(with appViewModel: AppViewModel) async {
        guard let task = pendingDeleteTask else { return }
        _ = await appViewModel.delete(task)
        pendingDeleteTask = nil
    }

    func cancelDelete() {
        pendingDeleteTask = nil
    }
}
