import Foundation

class HistoryViewModel: ObservableObject {
    @Published var recordings: [RecordingItem] = []
    
    init() {
        fetchRecordings()
    }
    
    // Mengambil data dari memori/storage
    func fetchRecordings() {
        self.recordings = RecordAudio.getRecordings()
    }
    
    // Menghapus data dan langsung memperbarui list
    func deleteRecording(_ recording: RecordingItem) {
        RecordAudio.deleteRecording(at: recording.url)
        fetchRecordings() // Refresh data setelah dihapus
    }
}
