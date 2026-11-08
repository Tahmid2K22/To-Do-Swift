import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

/// Central ViewModel managing global authentication state, active session, and task repository synchronization.
@MainActor
final class AppViewModel: ObservableObject {
    // MARK: - Published States
    @Published private(set) var user: AppUser?
    @Published private(set) var tasks: [TodoItem] = []
    @Published private(set) var isDemo: Bool = false
    @Published private(set) var loading: Bool = false
    @Published private(set) var saving: Bool = false
    @Published var error: String?

    // MARK: - Dependencies
    private let authService: AuthServiceProtocol
    private let taskService: TaskServiceProtocol

    // MARK: - Internal Listeners & Session Tracking
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    private var taskListenerHandle: ListenerRegistration?
    private var currentSessionID = UUID()

    // MARK: - Initialization
    init(
        authService: AuthServiceProtocol = FirebaseAuthService.shared,
        taskService: TaskServiceProtocol = FirestoreTaskService.shared
    ) {
        self.authService = authService
        self.taskService = taskService

        setupAuthStateListener()
    }

    deinit {
        if let handle = authListenerHandle {
            authService.removeStateChangeListener(handle)
        }
        taskListenerHandle?.remove()
    }

    // MARK: - Convenience Properties
    var signedIn: Bool {
        user != nil || isDemo
    }

    var configured: Bool {
        authService.isConfigured
    }

    var email: String {
        if isDemo {
            return "Local demo workspace"
        }
        return user?.email ?? "Your workspace"
    }

    // MARK: - Authentication Setup
    private func setupAuthStateListener() {
        guard authService.isConfigured else { return }

        authListenerHandle = authService.addStateChangeListener { [weak self] firebaseUser in
            Task { @MainActor in
                guard let self else { return }
                if let firebaseUser = firebaseUser {
                    self.user = AppUser(
                        id: firebaseUser.uid,
                        email: firebaseUser.email ?? "",
                        isDemo: false
                    )
                    self.isDemo = false
                    self.observeTasks(uid: firebaseUser.uid)
                } else if !self.isDemo {
                    self.user = nil
                    self.tasks = []
                    self.taskListenerHandle?.remove()
                    self.taskListenerHandle = nil
                }
            }
        }
    }

    // MARK: - Authentication Actions
    func authenticate(email: String, password: String, register: Bool) async {
        guard configured else {
            self.error = "Firebase is not configured. Please add GoogleService-Info.plist."
            return
        }

        saving = true
        defer { saving = false }

        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            if register {
                _ = try await authService.signUp(email: cleanEmail, password: password)
            } else {
                _ = try await authService.signIn(email: cleanEmail, password: password)
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func resetPassword(email: String) async -> Bool {
        guard configured else {
            self.error = "Firebase is not configured. Please add GoogleService-Info.plist."
            return false
        }

        saving = true
        defer { saving = false }

        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try await authService.sendPasswordReset(email: cleanEmail)
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    func startDemo() {
        taskListenerHandle?.remove()
        taskListenerHandle = nil
        isDemo = true
        user = AppUser.demo
        tasks = TodoItem.samples
    }

    func signOut() {
        do {
            if !isDemo {
                try authService.signOut()
            }
            taskListenerHandle?.remove()
            taskListenerHandle = nil
            currentSessionID = UUID()
            user = nil
            isDemo = false
            tasks = []
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Task Observation
    private func observeTasks(uid: String) {
        loading = true
        currentSessionID = UUID()
        let sessionToken = currentSessionID

        taskListenerHandle?.remove()
        taskListenerHandle = taskService.observeTasks(uid: uid) { [weak self] result in
            Task { @MainActor in
                guard let self, self.currentSessionID == sessionToken else { return }
                self.loading = false
                switch result {
                case .success(let items):
                    // Sort primarily by createdAt descending
                    self.tasks = items.sorted {
                        $0.createdAt == $1.createdAt ? $0.id < $1.id : $0.createdAt > $1.createdAt
                    }
                case .failure(let error):
                    self.error = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Task Mutations
    func save(id: String?, title: String, detail: String) async -> Bool {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDetail = detail.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTitle.isEmpty, !cleanDetail.isEmpty,
              cleanTitle.count <= TodoItem.maxTitleLength,
              cleanDetail.count <= TodoItem.maxDetailLength else {
            error = "Add a title (up to \(TodoItem.maxTitleLength) characters) and notes (up to \(TodoItem.maxDetailLength) characters)."
            return false
        }

        saving = true
        defer { saving = false }

        if isDemo {
            if let id, let index = tasks.firstIndex(where: { $0.id == id }) {
                tasks[index].title = cleanTitle
                tasks[index].detail = cleanDetail
                tasks[index].updatedAt = .now
            } else {
                let newTask = TodoItem(
                    id: UUID().uuidString,
                    title: cleanTitle,
                    detail: cleanDetail,
                    completed: false,
                    createdAt: .now,
                    updatedAt: .now
                )
                tasks.insert(newTask, at: 0)
            }
            return true
        }

        guard let uid = user?.id else {
            error = "User session expired. Please sign in again."
            return false
        }

        do {
            if let id {
                try await taskService.updateTask(uid: uid, id: id, title: cleanTitle, detail: cleanDetail)
            } else {
                _ = try await taskService.createTask(uid: uid, title: cleanTitle, detail: cleanDetail)
            }
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    func toggle(_ task: TodoItem) async {
        guard !saving else { return }
        saving = true
        defer { saving = false }

        if isDemo {
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index].completed.toggle()
                tasks[index].updatedAt = .now
            }
            return
        }

        guard let uid = user?.id else { return }
        do {
            try await taskService.toggleTaskCompletion(uid: uid, id: task.id, currentStatus: task.completed)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func delete(_ task: TodoItem) async -> Bool {
        saving = true
        defer { saving = false }

        if isDemo {
            tasks.removeAll { $0.id == task.id }
            return true
        }

        guard let uid = user?.id else { return false }
        do {
            try await taskService.deleteTask(uid: uid, id: task.id)
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
}

/// Backward compatibility alias for existing views or configurations expecting TaskStore
typealias TaskStore = AppViewModel
