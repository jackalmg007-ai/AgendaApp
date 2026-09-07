import SwiftUI

struct PageFlipEngine<Front: View, Back: View>: View {
    let progress: CGFloat
    let front: Front
    let back: Back

    init(progress: CGFloat, @ViewBuilder front: () -> Front, @ViewBuilder back: () -> Back) {
        self.progress = progress
        self.front = front()
        self.back = back()
    }

    var body: some View {
        let angle = Double(progress) * 180.0
        let showBack = progress > 0.5

        ZStack {
            if showBack {
                back
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            } else {
                front
            }
        }
        .rotation3DEffect(
            .degrees(angle),
            axis: (x: 0, y: 1, z: 0),
            anchor: .leading,
            perspective: 0.62
        )
        .overlay {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.black.opacity(showBack ? 0.02 : 0.0), .black.opacity(0.20)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .opacity(Double(abs(progress - 0.5) * 1.3))
                .allowsHitTesting(false)
        }
        .clipped()
    }
}

struct PageTurnGesture: ViewModifier {
    @Binding var progress: CGFloat
    let onCommit: (_ forward: Bool) -> Void

    func body(content: Content) -> some View {
        content.gesture(
            DragGesture(minimumDistance: 12)
                .onChanged { value in
                    let width = max(value.startLocation.x * 0 + 1, 1)
                    let raw = -value.translation.width / max(width, 320)
                    progress = min(max(raw, 0), 1)
                }
                .onEnded { value in
                    let shouldFlip = -value.translation.width > 110 || -value.predictedEndTranslation.width > 150
                    withAnimation(.easeOut(duration: 0.34)) {
                        progress = shouldFlip ? 1 : 0
                    }
                    if shouldFlip {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
                            onCommit(true)
                            progress = 0
                        }
                    }
                }
        )
    }
}
