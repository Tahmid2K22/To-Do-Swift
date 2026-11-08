import SwiftUI

/// Root view of TodoApp109, conditionally routing between Auth and Workspace based on session state.
struct ContentView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        Group {
            if appViewModel.signedIn {
                WorkspaceView()
            } else {
                AuthView()
            }
        }
        .tint(AppTheme.primary)
        .foregroundStyle(AppTheme.text)
        .alert(
            "Notice",
            isPresented: Binding(
                get: { appViewModel.error != nil },
                set: { if !$0 { appViewModel.error = nil } }
            )
        ) {
            Button("OK") {
                appViewModel.error = nil
            }
        } message: {
            Text(appViewModel.error ?? "An unexpected error occurred.")
        }
    }
}
