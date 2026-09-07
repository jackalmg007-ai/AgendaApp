import SwiftUI

enum AgendaDesign {
    static let leatherDark = Color(red: 0.12, green: 0.035, blue: 0.018)
    static let leatherMid = Color(red: 0.30, green: 0.085, blue: 0.035)
    static let leatherLight = Color(red: 0.50, green: 0.18, blue: 0.065)
    static let paper = Color(red: 0.955, green: 0.925, blue: 0.835)
    static let paperShadow = Color.black.opacity(0.25)
    static let ink = Color(red: 0.13, green: 0.12, blue: 0.095)
    static let brass = Color(red: 0.62, green: 0.48, blue: 0.22)
    static let pageRadius: CGFloat = 10
    static let shellRadius: CGFloat = 24
}

struct LeatherBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AgendaDesign.leatherLight, AgendaDesign.leatherMid, AgendaDesign.leatherDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Canvas { context, size in
                for i in 0..<1300 {
                    let x = CGFloat((i * 73) % 1000) / 1000 * size.width
                    let y = CGFloat((i * 137) % 1000) / 1000 * size.height
                    let r = CGFloat((i % 4) + 1)
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                        with: .color(.black.opacity(0.035))
                    )
                }
            }
            .blendMode(.multiply)

            RoundedRectangle(cornerRadius: AgendaDesign.shellRadius)
                .stroke(.white.opacity(0.14), lineWidth: 1)
                .padding(1)
        }
    }
}
