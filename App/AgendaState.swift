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

        // Ekranda gösterilen Türkçe ad. rawValue kasıtlı olarak İngilizce/sabit
        // bırakıldı çünkü PhysicalPageBook'taki page cache anahtarında kullanılıyor.
        var displayName: String {
            switch self {
            case .day: "Gün"
            case .week: "Hafta"
            case .month: "Ay"
            case .notes: "Notlar"
            case .todo: "Yapılacaklar"
            }
        }

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
    var isFlipping = false

    // Her section kendi son bulunduğu spread'i (sayfa konumunu) ayrı hatırlar.
    // Örn: Day'de 15. günde iken Week'e geçip geri dönersen, Day yine 15'te kalır.
    private var spreadsBySection: [Section: Int] = [:]

    var currentSpread: Int {
        get { spreadsBySection[section] ?? 0 }
        set { spreadsBySection[section] = newValue }
    }

    func select(_ section: Section) {
        self.section = section
        // NOT: currentSpread burada artık resetlenmiyor — her section
        // kendi son konumunu spreadsBySection üzerinden korur.
    }

    // Aktif section'ı kendi "anchor"ına döndürür: Day → bugün,
    // Week → bu hafta, Month → bu ay (hepsi spread = 0'a karşılık gelir).
    func goToToday() {
        spreadsBySection[section] = 0
    }
}
