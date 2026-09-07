import SwiftUI
import Observation

@Observable
final class AgendaState {
    enum Section: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case notes = "Notes"
        case todo = "To-Do"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .day: "sun.max"
            case .week: "rectangle.split.3x1"
            case .month: "calendar"
            case .notes: "note.text"
            case .todo: "checklist"
            }
        }

        var accent: Color {
            switch self {
            case .day: .blue
            case .week: .red
            case .month: .green
            case .notes: .orange
            case .todo: .purple
            }
        }
    }

    var section: Section = .month
    var currentSpread: Int = 0
    var isFlipping = false

    func select(_ section: Section) {
        self.section = section
        currentSpread = 0
    }
}
