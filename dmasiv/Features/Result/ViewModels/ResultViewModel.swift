import Foundation
import SwiftUI

@MainActor
class ResultViewModel: ObservableObject {
    @Published private(set) var score: Int = 0
    @Published private(set) var song: Song?
}
