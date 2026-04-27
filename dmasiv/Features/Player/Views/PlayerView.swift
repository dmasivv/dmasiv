import SwiftUI

struct PlayerView: View {
    @StateObject private var viewModel = PlayerViewModel()
    
    var body: some View {
        VStack {
            Text("Karaoke Player")
            Text("Scrolling lyrics will appear here based on TimeInterval")
        }
    }
}
