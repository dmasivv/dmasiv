import Foundation
import SwiftUI

@MainActor
class RecordViewModel: ObservableObject {
    @Published private(set) var currentSong: Song?
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var recordingDuration: TimeInterval = 0

    // Stubs for recording controls
    func startRecording() {}
    func stopRecording() {}
}
