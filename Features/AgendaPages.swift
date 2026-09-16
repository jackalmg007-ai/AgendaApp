import SwiftUI

struct AgendaSpread: View {
    @Environment(AgendaState.self) private var state

    var body: some View {
        PhysicalPageBook(
            state: state,
            currentSpread: Binding(
                get: {
                    state.currentSpread
                },
                set: {
                    state.currentSpread = $0
                }
            )
        )
    }
}

struct DayPage: View {
    let isLeft: Bool
    let spread: Int

    private var pageDate: Date {
        let calendar = Calendar(identifier: .gregorian)

        let baseDate = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 9,
                day: 7
            )
        )!

        // Bir "spread" (sol+sağ sayfa çifti) tek bir günü temsil eder:
        // sol sayfa o günün programı, sağ sayfa o günün notlarıdır.
        // Bu yüzden offset isLeft'ten bağımsız, doğrudan spread'e eşittir.
        let offset = spread

        return calendar.date(
            byAdding: .day,
            value: offset,
            to: baseDate
        )!
    }

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE"

        return formatter.string(from: pageDate).uppercased()
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "d MMMM yyyy"

        return formatter.string(from: pageDate)
    }

    var body: some View {
        PaperPage(lined: isLeft) {
            VStack(alignment: .leading, spacing: 14) {

                Text(isLeft ? dayName : "TODAY")
                    .font(
                        .system(
                            size: 12,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .tracking(2)

                Text(formattedDate)
                    .font(
                        .system(
                            size: 26,
                            weight: .semibold,
                            design: .serif
                        )
                    )

                Divider()

                if isLeft {

                    Text("Schedule")
                        .font(.headline)

                    ForEach(
                        [
                            "08:00",
                            "09:00",
                            "10:00",
                            "11:00",
                            "12:00",
                            "13:00"
                        ],
                        id: \.self
                    ) { time in

                        HStack {
                            Text(time)
                                .font(.caption.monospaced())

                            Rectangle()
                                .fill(.black.opacity(0.12))
                                .frame(height: 1)
                        }
                    }

                } else {

                    Text("Notes")
                        .font(.headline)

                    Spacer()

                    Text("Page \(spread * 2 + 2)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct WeekPage: View {
    let isLeft: Bool
    let spread: Int
    let days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    // spread=0 → 7 Eylül 2026'yı içeren hafta (Pazartesi başlangıçlı).
    // Her spread bir hafta ileri/geri kaydırır.
    private var weekStartDate: Date {
        let calendar = Calendar(identifier: .gregorian)

        let baseMonday = calendar.date(
            from: DateComponents(year: 2026, month: 9, day: 7)
        )!

        return calendar.date(
            byAdding: .weekOfYear,
            value: spread,
            to: baseMonday
        )!
    }

    private var weekNumber: Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.component(.weekOfYear, from: weekStartDate)
    }

    private var weekRangeText: String {
        let calendar = Calendar(identifier: .gregorian)
        let start = weekStartDate
        let end = calendar.date(byAdding: .day, value: 6, to: start)!

        let sameMonth = calendar.component(.month, from: start) == calendar.component(.month, from: end)
        let sameYear = calendar.component(.year, from: start) == calendar.component(.year, from: end)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")

        if sameMonth && sameYear {
            formatter.dateFormat = "d"
            let startText = formatter.string(from: start)
            formatter.dateFormat = "d MMMM yyyy"
            let endText = formatter.string(from: end)
            return "\(startText)–\(endText)"
        } else {
            formatter.dateFormat = "d MMM"
            let startText = formatter.string(from: start)
            formatter.dateFormat = "d MMM yyyy"
            let endText = formatter.string(from: end)
            return "\(startText) – \(endText)"
        }
    }

    var body: some View {
        PaperPage(lined: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text(isLeft ? "WEEK \(weekNumber)" : "WEEK PLAN")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(2)
                Text(weekRangeText)
                    .font(.title3.weight(.semibold))
                if isLeft {
                    VStack(spacing: 0) {
                        ForEach(days, id: \.self) { day in
                            HStack {
                                Text(day).frame(width: 42, alignment: .leading).font(.caption.bold())
                                Rectangle().fill(.black.opacity(0.10)).frame(height: 1)
                            }
                            .frame(height: 34)
                        }
                    }
                } else {
                    Text("Priorities")
                        .font(.headline)
                    ForEach(1...6, id: \.self) { index in
                        HStack {
                            Image(systemName: "square")
                            Text("Priority item \(index)")
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

struct MonthPage: View {
    let isLeft: Bool
    let spread: Int

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 5),
        count: 7
    )

    // spread=0 → Eylül 2026. Her spread bir ay ileri/geri kaydırır.
    private var monthDate: Date {
        let calendar = Calendar(identifier: .gregorian)

        let baseMonth = calendar.date(
            from: DateComponents(year: 2026, month: 9, day: 1)
        )!

        return calendar.date(
            byAdding: .month,
            value: spread,
            to: baseMonth
        )!
    }

    private var monthNameText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: monthDate).uppercased()
    }

    private var yearText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: monthDate)
    }

    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: monthDate)
    }

    private var daysInMonth: Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 30
    }

    // Ayın 1'i haftanın hangi gününe denk geliyor (Pazartesi=0 ... Pazar=6),
    // grid'in başına o kadar boş hücre eklenir.
    private var leadingBlankCount: Int {
        let calendar = Calendar(identifier: .gregorian)
        let weekday = calendar.component(.weekday, from: monthDate) // 1=Pazar ... 7=Cumartesi
        return (weekday + 5) % 7
    }

    private struct CalendarCell: Identifiable {
        let id: String
        let title: String
        let isWeekday: Bool
        let dayNumber: Int?
    }

    private var calendarCells: [CalendarCell] {
        let weekdays = ["M", "T", "W", "T", "F", "S", "S"].enumerated().map {
            CalendarCell(
                id: "weekday-\($0.offset)",
                title: $0.element,
                isWeekday: true,
                dayNumber: nil
            )
        }

        let leading = (0..<leadingBlankCount).map {
            CalendarCell(
                id: "blank-\($0)",
                title: "",
                isWeekday: false,
                dayNumber: nil
            )
        }

        let dates = (1...daysInMonth).map {
            CalendarCell(
                id: "date-\($0)",
                title: "\($0)",
                isWeekday: false,
                dayNumber: $0
            )
        }

        return weekdays + leading + dates
    }

    var body: some View {
        PaperPage(lined: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text(isLeft ? monthNameText : "MONTHLY NOTES")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(2)

                Text(isLeft ? yearText : monthYearText)
                    .font(.title2.weight(.semibold))

                if isLeft {
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(calendarCells) { cell in
                            if cell.isWeekday {
                                Text(cell.title)
                                    .font(.caption2.bold())
                            } else {
                                Text(cell.title)
                                    .font(
                                        .system(
                                            size: 13,
                                            weight: .medium,
                                            design: .rounded
                                        )
                                    )
                                    .frame(
                                        maxWidth: .infinity,
                                        minHeight: 31
                                    )
                                    .background(
                                        (spread == 0 && cell.dayNumber == 7)
                                            ? Color.green.opacity(0.20)
                                            : .clear
                                    )
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 5)
                                    )
                            }
                        }
                    }
                } else {
                    Text("Focus")
                        .font(.headline)

                    Text("Use this page for monthly goals, ideas and appointments.")
                        .font(.callout)

                    Spacer()
                }
            }
        }
    }
}

struct NotesPage: View {
    let isLeft: Bool
    let spread: Int

    var body: some View {
        PaperPage(lined: true) {
            VStack(alignment: .leading, spacing: 12) {
                Text(isLeft ? "NOTES" : "IDEAS")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(2)
                Text("Notebook page")
                    .font(.title3.weight(.semibold))
                Spacer()
                Text("Tap here later to edit this page.")
                    .foregroundStyle(.secondary)
                Text("Spread \(spread + 1)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct TodoPage: View {
    let isLeft: Bool
    let spread: Int

    var body: some View {
        PaperPage(lined: false) {
            VStack(alignment: .leading, spacing: 13) {
                Text(isLeft ? "TO-DO" : "CHECKLIST")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(2)
                Text("Things to do")
                    .font(.title3.weight(.semibold))
                ForEach(0..<7, id: \.self) { index in
                    HStack(spacing: 10) {
                        Image(systemName: index < 2 ? "checkmark.square" : "square")
                            .font(.title3)
                        Text(["Call Mehmet", "Review project", "Prepare report", "Pay bill", "Buy supplies", "Write notes", "Plan tomorrow"][index])
                            .strikethrough(index < 2)
                    }
                }
                Spacer()
            }
        }
    }
}
