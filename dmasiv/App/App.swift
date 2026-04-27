import SwiftUI

@main
struct Application: App {
    // Inject global dependencies if needed
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel())
        }
    }
}
