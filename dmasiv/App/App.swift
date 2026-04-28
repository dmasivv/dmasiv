import SwiftUI

@main
struct Application: App {
    var body: some Scene {
        WindowGroup {
//          SongListView()
            RecordView(song: .Januari) // Langsung Build Ke Page 2
        }
    }
}
