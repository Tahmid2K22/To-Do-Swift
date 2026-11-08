import SwiftUI

/// Simple workspace dashboard for TodoApp109.
struct WorkspaceView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = TaskListViewModel()

    private var displayedTasks: [TodoItem] {
        viewModel.displayedTasks(from: appViewModel.tasks)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Demo Mode notification banner if active
                if appViewModel.isDemo {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                        Text("Demo Mode • Changes are temporary")
                            .font(.caption.weight(.medium))
                        Spacer()
                    }
                    .foregroundStyle(AppTheme.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.primary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                }

                // Filter Segmented Control
                Picker("Filter", selection: $viewModel.filter) {
                    Text("All (\(appViewModel.tasks.count))").tag(TaskFilter.all)
                    Text("Open (\(viewModel.openCount(from: appViewModel.tasks)))").tag(TaskFilter.open)
                    Text("Done (\(viewModel.completedCount(from: appViewModel.tasks)))").tag(TaskFilter.done)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                // Search Bar
                SearchBarView(text: $viewModel.searchQuery, placeholder: "Search tasks...")
                    .padding(.horizontal, 16)

                // Task List or Loading / Empty State
                if appViewModel.loading {
                    Spacer()
                    ProgressView("Loading tasks...")
                    Spacer()
                } else if displayedTasks.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(Array(displayedTasks.enumerated()), id: \.element.id) { index, task in
                            TaskCardView(
                                task: task,
                                displayIndex: index + 1,
                                isSaving: appViewModel.saving,
                                onToggle: {
                                    Task {
                                        await appViewModel.toggle(task)
                                    }
                                },
                                onEdit: {
                                    viewModel.openEditTaskEditor(for: task)
                                },
                                onDelete: {
                                    viewModel.requestDelete(for: task)
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.requestDelete(for: task)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    Task {
                                        await appViewModel.toggle(task)
                                    }
                                } label: {
                                    Label(task.completed ? "Reopen" : "Done",
                                          systemImage: task.completed ? "arrow.uturn.backward" : "checkmark")
                                }
                                .tint(task.completed ? .orange : .green)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("TodoApp109")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showAccountSheet = true
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.text)
                    }
                    .accessibilityLabel("Account")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.openNewTaskEditor()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(AppTheme.primary)
                    }
                    .accessibilityLabel("Add task")
                }
            }
            .sheet(item: $viewModel.editorRoute) { route in
                TaskEditorView(task: route.task)
                    .environmentObject(appViewModel)
            }
            .sheet(isPresented: $viewModel.showAccountSheet) {
                AccountSheetView()
                    .environmentObject(appViewModel)
            }
            .confirmationDialog(
                "Delete task?",
                isPresented: Binding(
                    get: { viewModel.pendingDeleteTask != nil },
                    set: { if !$0 { viewModel.cancelDelete() } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete Task", role: .destructive) {
                    Task {
                        await viewModel.confirmDelete(with: appViewModel)
                    }
                }
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDelete()
                }
            } message: {
                Text("This permanently removes the task from your collection.")
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "checkmark.circle")
                .font(.system(size: 50))
                .foregroundStyle(AppTheme.secondaryText.opacity(0.5))

            Text(viewModel.searchQuery.isEmpty ? "No Tasks" : "No Matching Tasks")
                .font(.headline)
                .foregroundStyle(AppTheme.text)

            Text(viewModel.searchQuery.isEmpty ? "Tap the + button above to create a task." : "Try a different search keyword.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.openNewTaskEditor()
                } label: {
                    Label("Add Task", systemImage: "plus")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppTheme.primary, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                        .foregroundStyle(.white)
                }
                .padding(.top, 10)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
