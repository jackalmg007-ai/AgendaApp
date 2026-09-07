import SwiftUI

struct SideTabs: View {
    @Environment(AgendaState.self) private var state

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                VStack(spacing: 7) {
                    ForEach(AgendaState.Section.allCases) { item in
                        Button {
                            withAnimation(.easeInOut(duration: 0.20)) {
                                state.select(item)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: item.icon)
                                    .font(.system(size: 12, weight: .semibold))
                                Text(item.rawValue)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(item == state.section ? .white : .white.opacity(0.78))
                            .frame(width: 82, height: 34)
                            .background(
                                Capsule()
                                    .fill(item == state.section ? item.accent.opacity(0.88) : .black.opacity(0.20))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .padding(.top, proxy.safeAreaInsets.top + 18)
                .padding(.leading, 10)

                Spacer()
            }
        }
        .allowsHitTesting(true)
    }
}
