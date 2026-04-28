import Foundation

// Menyimpan data riwayat nada user
struct PitchPoint: Identifiable {
    let id = UUID()
    let time: TimeInterval
    let midiNote: Float
}

// Menyimpan data nada ideal dari lagu (Midi) yang akan dicompare dengan user sebagai sistem scoring
struct MIDINote: Identifiable {
    let id = UUID()
    let start: TimeInterval
    let duration: TimeInterval
    let number: Int
}
