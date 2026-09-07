import SwiftUI

struct AgendaSpread: View {
    @Environment(AgendaState.self) private var state
    @State private var flipProgress: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let pageSize = CGSize(width: max((proxy.size.width - 46) / 2, 180), height: max(proxy.size.height - 36, 260))

            ZStack {
                HStack(spacing: 12) {
                    currentPage(isLeft: true)
                    currentPage(isLeft: false)
                }
                .frame(width: pageSize.width * 2 + 12, height: pageSize.height)

                if flipProgress > 0.001 {
                    PageFlipEngine(progress: flipProgress) {
                        page(isLeft: false, section: state.section, spread: state.currentSpread)
                    } back: {
                        page(isLeft: false, section: state.section, spread: state.currentSpread + 1)
                    }
                    .frame(width: pageSize.width, height: pageSize.height)
                    .position(x: proxy.size.width / 2 + pageSize.width / 2 + 6,
                              y: proxy.size.height / 2)
                    .zIndex(4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 18)
                    .onChanged { value in
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        let p = min(max(-value.translation.width / max(pageSize.width, 1), 0), 1)
                        flipProgress = p
                    }
                    .onEnded { value in
                        guard abs(value.translation.width) > abs(value.translation.height) else {
                            flipProgress = 0
                            return
                        }
                        let forward = value.translation.width < -90 || value.predictedEndTranslation.width < -150
                        withAnimation(.easeOut(duration: 0.36)) {
                            flipProgress = forward ? 1 : 0
                        }
                        if forward {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
                                state.currentSpread += 1
                                flipProgress = 0
                            }
                        }
                    }
            )
        }
    }

    @ViewBuilder
    private func currentPage(isLeft: Bool) -> some View {
        page(isLeft: isLeft, section: state.section, spread: state.currentSpread)
    }

    @ViewBuilder
    private func page(isLeft: Bool, section: AgendaState.Section, spread: Int) -> some View {
        switch section {
        case .day:
            DayPage(isLeft: isLeft, spread: spread)
        case .week:
            WeekPage(isLeft: isLeft, spread: spread)
        case .month:
            MonthPage(isLeft: isLeft, spread: spread)
        case .notes:
            NotesPage(isLeft: isLeft, spread: spread)
        case .todo:
            TodoPage(isLeft: isLeft, spread: spread)
        }
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

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
    private let numbers = Array(1...30)

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
                        ForEach(["M","T","W","T","F","S","S"], id: \.self) {
                            Text($0).font(.caption2.bold())
                        }
                        ForEach(numbers, id: \.self) { day in
                            Text("\(day)")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 31)
                                .background(day == 7 ? Color.green.opacity(0.20) : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
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
