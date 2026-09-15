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

    var body: some View {
        PaperPage(lined: isLeft) {
            VStack(alignment: .leading, spacing: 14) {
                Text(isLeft ? "MONDAY" : "TODAY")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(2)
                Text("7 September 2026")
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                Divider()
                if isLeft {
                    Text("Schedule")
                        .font(.headline)
                    ForEach(["08:00", "09:00", "10:00", "11:00", "12:00", "13:00"], id: \.self) { time in
                        HStack {
                            Text(time).font(.caption.monospaced())
                            Rectangle().fill(.black.opacity(0.12)).frame(height: 1)
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

    var body: some View {
        PaperPage(lined: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text(isLeft ? "WEEK 37" : "WEEK PLAN")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(2)
                Text("7–13 September 2026")
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

    private let numbers = Array(1...30)

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

        let dates = numbers.map {
            CalendarCell(
                id: "date-\($0)",
                title: "\($0)",
                isWeekday: false,
                dayNumber: $0
            )
        }

        return weekdays + dates
    }

    var body: some View {
        PaperPage(lined: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text(isLeft ? "SEPTEMBER" : "MONTHLY NOTES")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(2)

                Text(isLeft ? "2026" : "September 2026")
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
                                        cell.dayNumber == 7
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
