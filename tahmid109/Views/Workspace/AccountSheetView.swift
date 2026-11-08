import SwiftUI

/// Simple account information and settings sheet.
struct AccountSheetView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    private var totalTasks: Int {
        appViewModel.tasks.count
    }

    private var completedTasks: Int {
        appViewModel.tasks.filter(\.completed).count
    }

    private var openTasks: Int {
        totalTasks - completedTasks
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Account Information") {
                    LabeledContent("Email", value: appViewModel.email)
                    LabeledContent("Mode", value: appViewModel.isDemo ? "Local Demo" : "Firebase Account")
                }

                Section("Task Statistics") {
                    LabeledContent("Total Tasks", value: "\(totalTasks)")
                    LabeledContent("Open Tasks", value: "\(openTasks)")
                    LabeledContent("Completed Tasks", value: "\(completedTasks)")
                }

                Section {
                    Button(role: .destructive) {
                        dismiss()
                        appViewModel.signOut()
                    } label: {
                        HStack {
                            Spacer()
                            Text(appViewModel.isDemo ? "Leave Demo Mode" : "Sign Out")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
