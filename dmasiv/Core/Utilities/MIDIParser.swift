import Foundation
import AudioToolbox

class MIDIParser {
    
    /// Membaca file .mid dan mengonversinya menjadi array MIDINote
    static func parse(fileName: String) -> [MIDINote] {
        // 1. Cari file MIDI di dalam Bundle aplikasi
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mid") else {
            print("MIDIParser: File \(fileName).mid tidak ditemukan di Bundle.")
            return []
        }
        
        // 2. Siapkan MusicSequence untuk membaca struktur binary MIDI
        var sequence: MusicSequence?
        NewMusicSequence(&sequence)
        guard let seq = sequence else { return [] }
        
        // Load file ke dalam sequence
        let status = MusicSequenceFileLoad(seq, url as CFURL, .midiType, MusicSequenceLoadFlags.smf_ChannelsToTracks)
        guard status == noErr else {
            print("MIDIParser: Gagal meload file MIDI (Error Code: \(status)).")
            return []
        }
        
        // 3. Persiapkan wadah untuk hasil parse
        var parsedNotes: [MIDINote] = []
        
        var tracksCount: UInt32 = 0
        MusicSequenceGetTrackCount(seq, &tracksCount)
        
        // 4. Telusuri setiap Track di dalam MIDI
        for i in 0..<tracksCount {
            var track: MusicTrack?
            MusicSequenceGetIndTrack(seq, i, &track)
            guard let currentTrack = track else { continue }
            
            var iterator: MusicEventIterator?
            NewMusicEventIterator(currentTrack, &iterator)
            guard let eventIterator = iterator else { continue }
            
            var hasNext: DarwinBoolean = false
            MusicEventIteratorHasCurrentEvent(eventIterator, &hasNext)
            
            // 5. Telusuri setiap Event (Nada) di dalam Track tersebut
            while hasNext.boolValue {
                var timestamp: MusicTimeStamp = 0 // Dalam format "Beats"
                var eventType: MusicEventType = 0
                var eventData: UnsafeRawPointer?
                var eventDataSize: UInt32 = 0
                
                MusicEventIteratorGetEventInfo(eventIterator, &timestamp, &eventType, &eventData, &eventDataSize)
                
                // Jika event ini adalah sebuah "Nada" (Note Message)
                if eventType == kMusicEventType_MIDINoteMessage {
                    let noteMessage = eventData!.bindMemory(to: MIDINoteMessage.self, capacity: 1).pointee
                    
                    // Konversi Waktu Mulai (Beats ke Detik)
                    var timeInSeconds: Float64 = 0.0
                    MusicSequenceGetSecondsForBeats(seq, timestamp, &timeInSeconds)
                    
                    // Konversi Durasi (Hitung waktu selesai, lalu kurangi waktu mulai)
                    var endSeconds: Float64 = 0.0
                    let endTimestamp = timestamp + MusicTimeStamp(noteMessage.duration)
                    MusicSequenceGetSecondsForBeats(seq, endTimestamp, &endSeconds)
                    
                    let durationInSeconds = endSeconds - timeInSeconds
                    
                    // Masukkan ke dalam Struct MIDINote kita
                    let note = MIDINote(
                        start: TimeInterval(timeInSeconds),
                        duration: TimeInterval(durationInSeconds),
                        number: Int(noteMessage.note)
                    )
                    
                    parsedNotes.append(note)
                }
                
                MusicEventIteratorNextEvent(eventIterator)
                MusicEventIteratorHasCurrentEvent(eventIterator, &hasNext)
            }
        }
        
        print("MIDIParser: Berhasil membaca \(parsedNotes.count) nada dari \(fileName).mid")
        
        // Urutkan nada berdasarkan waktu mulai agar UI menggambarnya dengan rapi
        return parsedNotes.sorted { $0.start < $1.start }
    }
}
