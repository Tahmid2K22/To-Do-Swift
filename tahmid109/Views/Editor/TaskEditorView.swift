import SwiftUI

/// Simple task editor modal for creating or editing tasks.
struct TaskEditorView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: TaskEditorViewModel
    @FocusState private var isTitleFocused: Bool

    init(task: TodoItem?) {
        _viewModel = StateObject(wrappedValue: TaskEditorViewModel(task: task))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Enter task title", text: $viewModel.title)
                        .focused($isTitleFocused)

                    HStack {
                        Spacer()
                        Text("\(viewModel.titleCharCount) / \(TodoItem.maxTitleLength)")
                            .font(.caption2)
                            .foregroundStyle(viewModel.isTitleOverLimit ? AppTheme.danger : AppTheme.secondaryText)
                    }
                } header: {
                    Text("Title")
                }

                Section {
                    TextEditor(text: $viewModel.detail)
                        .frame(minHeight: 140)

                    HStack {
                        Spacer()
                        Text("\(viewModel.detailCharCount) / \(TodoItem.maxDetailLength)")
                            .font(.caption2)
                            .foregroundStyle(viewModel.isDetailOverLimit ? AppTheme.danger : AppTheme.secondaryText)
                    }
                } header: {
                    Text("Notes / Description")
                }

                if let error = appViewModel.error {
                    Section {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(AppTheme.danger)
                    }
                }
            }
            .navigationTitle(viewModel.isNewTask ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if viewModel.hasChanges {
                            viewModel.showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .disabled(appViewModel.saving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isNewTask ? "Add" : "Save") {
                        isTitleFocused = false
                        Task {
                            let success = await viewModel.save(with: appViewModel)
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isValid || appViewModel.saving)
                }
            }
            .confirmationDialog(
                "Discard changes?",
                isPresented: $viewModel.showDiscardAlert,
                titleVisibility: .visible
            ) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            }
            .onAppear {
                if viewModel.isNewTask {
                    isTitleFocused = true
                }
            }
        }
    }
}
