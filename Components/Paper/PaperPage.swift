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
            RoundedRectangle(cornerRadius: AgendaDesign.pageRadius)
                .fill(AgendaDesign.paper)
                .shadow(color: .black.opacity(0.32), radius: 12, x: 5, y: 8)

            if lined {
                PaperLines()
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
