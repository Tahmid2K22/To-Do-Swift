import SwiftUI
import FirebaseCore

@main
struct tahmid109App: App {
    @StateObject private var appViewModel: AppViewModel

    init() {
        // Configure Firebase if GoogleService-Info.plist is present in the bundle
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: path) {
            FirebaseApp.configure(options: options)
        }
        _appViewModel = StateObject(wrappedValue: AppViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}
