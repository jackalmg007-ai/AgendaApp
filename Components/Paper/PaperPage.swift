import SwiftUI

struct PaperPage<Content: View>: View {
    let content: Content
    var lined: Bool = false

    init(lined: Bool = false, @ViewBuilder content: () -> Content) {
        self.lined = lined
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Arkada birkaç sayfa daha varmış hissi veren, hafifçe kaydırılmış
            // ve soluklaştırılmış "alt sayfa" katmanları.
            PageStack()

            RoundedRectangle(cornerRadius: AgendaDesign.pageRadius)
                .fill(AgendaDesign.paper)
                .overlay(
                    PaperGrain()
                        .clipShape(RoundedRectangle(cornerRadius: AgendaDesign.pageRadius))
                )
                .shadow(color: .black.opacity(0.30), radius: 14, x: 5, y: 9)
                .shadow(color: .black.opacity(0.12), radius: 2, x: 1, y: 2)

            if lined {
                PaperLines()
                    .clipShape(RoundedRectangle(cornerRadius: AgendaDesign.pageRadius))

                MarginLine()
                    .clipShape(RoundedRectangle(cornerRadius: AgendaDesign.pageRadius))
            }

            content
                .padding(22)
        }
        .overlay {
            RoundedRectangle(cornerRadius: AgendaDesign.pageRadius)
                .stroke(.black.opacity(0.08), lineWidth: 1)
        }
        .foregroundStyle(AgendaDesign.ink)
    }
}

// MARK: - Page Stack Illusion

private struct PageStack: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AgendaDesign.pageRadius)
                .fill(AgendaDesign.paper.opacity(0.85))
                .offset(x: 3, y: 4)
                .shadow(color: .black.opacity(0.16), radius: 4, x: 2, y: 3)

            RoundedRectangle(cornerRadius: AgendaDesign.pageRadius)
                .fill(AgendaDesign.paper.opacity(0.65))
                .offset(x: 6, y: 8)
                .shadow(color: .black.opacity(0.12), radius: 4, x: 2, y: 3)
        }
    }
}

// MARK: - Paper Grain

private struct PaperGrain: View {
    var body: some View {
        Canvas { context, size in
            for i in 0..<900 {
                let x = CGFloat((i * 61) % 997) / 997 * size.width
                let y = CGFloat((i * 149) % 997) / 997 * size.height
                let r = CGFloat((i % 3) + 1) * 0.5
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                    with: .color(.black.opacity(0.025))
                )
            }
        }
        .blendMode(.multiply)
    }
}

struct PaperLines: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 24
            var y: CGFloat = 34
            while y < size.height - 18 {
                var path = Path()
                path.move(to: CGPoint(x: 18, y: y))
                path.addLine(to: CGPoint(x: size.width - 18, y: y))
                context.stroke(path, with: .color(.blue.opacity(0.10)), lineWidth: 0.7)
                y += spacing
            }
        }
    }
}

// MARK: - Margin Line

private struct MarginLine: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: 40, y: 10))
            path.addLine(to: CGPoint(x: 40, y: size.height - 10))
            context.stroke(path, with: .color(.red.opacity(0.18)), lineWidth: 1)
        }
    }
}
