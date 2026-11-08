import SwiftUI

/// ViewModel for drafting a new task or editing an existing one.
@MainActor
final class TaskEditorViewModel: ObservableObject {
    let originalTask: TodoItem?

    @Published var title: String
    @Published var detail: String
    @Published var showDiscardAlert: Bool = false

    init(task: TodoItem?) {
        self.originalTask = task
        self.title = task?.title ?? ""
        self.detail = task?.detail ?? ""
    }

    var isNewTask: Bool {
        originalTask == nil
    }

    var hasChanges: Bool {
        title != (originalTask?.title ?? "") || detail != (originalTask?.detail ?? "")
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedDetail: String {
        detail.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isTitleValid: Bool {
        !trimmedTitle.isEmpty && title.count <= TodoItem.maxTitleLength
    }

    var isDetailValid: Bool {
        !trimmedDetail.isEmpty && detail.count <= TodoItem.maxDetailLength
    }

    var isValid: Bool {
        isTitleValid && isDetailValid
    }

    var titleCharCount: Int {
        title.count
    }

    var detailCharCount: Int {
        detail.count
    }

    var isTitleOverLimit: Bool {
        titleCharCount > TodoItem.maxTitleLength
    }

    var isDetailOverLimit: Bool {
        detailCharCount > TodoItem.maxDetailLength
    }

    func save(with appViewModel: AppViewModel) async -> Bool {
        guard isValid else { return false }
        return await appViewModel.save(
            id: originalTask?.id,
            title: trimmedTitle,
            detail: trimmedDetail
        )
    }
}
