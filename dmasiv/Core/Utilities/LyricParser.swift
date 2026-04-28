import Foundation

// MARK: - Lyric Parser
class LyricParser {
    static func parse(fileName: String) -> [LyricLine] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "lrc") else {
            print("LyricParser: File \(fileName).lrc tidak ditemukan.")
            return []
        }
        
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            var parsedLyrics: [LyricLine] = []
            
            for line in lines {
                guard !line.isEmpty else { continue }
                let parts = line.components(separatedBy: "]")
                
                if parts.count >= 2 {
                    let timeString = parts[0].replacingOccurrences(of: "[", with: "")
                    let text = parts[1...].joined(separator: "]").trimmingCharacters(in: .whitespaces)
                    guard !text.isEmpty else { continue }
                    
                    let timeParts = timeString.components(separatedBy: ":")
                    if timeParts.count == 2,
                       let min = TimeInterval(timeParts[0]),
                       let sec = TimeInterval(timeParts[1]) {
                        
                        let totalSeconds = (min * 60) + sec
                        parsedLyrics.append(LyricLine(text: text, timestamp: totalSeconds))
                    }
                }
            }
            return parsedLyrics
        } catch {
            print("LyricParser: Gagal membaca file - \(error)")
            return []
        }
    }
}
