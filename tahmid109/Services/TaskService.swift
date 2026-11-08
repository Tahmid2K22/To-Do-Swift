import Foundation
import FirebaseFirestore

/// Protocol defining CRUD operations for tasks in Firestore.
protocol TaskServiceProtocol: AnyObject {
    func observeTasks(uid: String, onChange: @escaping (Result<[TodoItem], Error>) -> Void) -> ListenerRegistration?
    func createTask(uid: String, title: String, detail: String) async throws -> String
    func updateTask(uid: String, id: String, title: String, detail: String) async throws
    func toggleTaskCompletion(uid: String, id: String, currentStatus: Bool) async throws
    func deleteTask(uid: String, id: String) async throws
}

/// Firestore implementation of task data access.
final class FirestoreTaskService: TaskServiceProtocol {
    static let shared = FirestoreTaskService()

    private var db: Firestore {
        Firestore.firestore()
    }

    private func tasksCollection(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("tasks")
    }

    func observeTasks(uid: String, onChange: @escaping (Result<[TodoItem], Error>) -> Void) -> ListenerRegistration? {
        return tasksCollection(uid: uid)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onChange(.failure(error))
                    return
                }

                let items: [TodoItem] = (snapshot?.documents ?? []).compactMap { doc in
                    let data = doc.data()
                    guard let title = data["title"] as? String,
                          let detail = data["description"] as? String,
                          let completed = data["completed"] as? Bool else {
                        return nil
                    }

                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? .distantPast
                    let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()

                    return TodoItem(
                        id: doc.documentID,
                        title: title,
                        detail: detail,
                        completed: completed,
                        createdAt: createdAt,
                        updatedAt: updatedAt
                    )
                }

                onChange(.success(items))
            }
    }

    func createTask(uid: String, title: String, detail: String) async throws -> String {
        let collection = tasksCollection(uid: uid)
        let docRef = collection.document()

        // Strict adherence to firestore.rules:
        // Must contain keys: ['title', 'description', 'completed', 'createdAt', 'updatedAt'] and no other keys.
        let data: [String: Any] = [
            "title": title,
            "description": detail,
            "completed": false,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        try await docRef.setData(data)
        return docRef.documentID
    }

    func updateTask(uid: String, id: String, title: String, detail: String) async throws {
        let docRef = tasksCollection(uid: uid).document(id)

        // firestore.rules requirement: updatedAt == request.time
        let data: [String: Any] = [
            "title": title,
            "description": detail,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        try await docRef.updateData(data)
    }

    func toggleTaskCompletion(uid: String, id: String, currentStatus: Bool) async throws {
        let docRef = tasksCollection(uid: uid).document(id)

        let data: [String: Any] = [
            "completed": !currentStatus,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        try await docRef.updateData(data)
    }

    func deleteTask(uid: String, id: String) async throws {
        let docRef = tasksCollection(uid: uid).document(id)
        try await docRef.delete()
    }
}
