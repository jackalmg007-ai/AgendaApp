import SwiftUI

struct BindingView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(AgendaDesign.leatherDark)
                .frame(width: 34)
                .shadow(radius: 7)

            VStack(spacing: 28) {
                ForEach(0..<6, id: \.self) { _ in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.35), AgendaDesign.brass, .black.opacity(0.35)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 20, height: 74)
                        .overlay(Capsule().stroke(.black.opacity(0.35), lineWidth: 1))
                }
            }
        }
    }
}
