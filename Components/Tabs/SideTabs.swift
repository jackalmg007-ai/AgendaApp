import SwiftUI
import UIKit
import AudioToolbox

struct SideTabs: View {
    @Environment(AgendaState.self) private var state

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                VStack(spacing: 7) {
                    ForEach(AgendaState.Section.allCases) { item in
                        Button {
                            UISelectionFeedbackGenerator().selectionChanged()
                            // ID 1057 ("Tink") — sayfa çevirmeden (1104) daha hafif/ince,
                            // sekme geçişini ayırt etmek için.
                            AudioServicesPlaySystemSound(1057)
                            withAnimation(.easeInOut(duration: 0.20)) {
                                state.select(item)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: item.icon)
                                    .font(.system(size: 12, weight: .semibold))
                                Text(item.displayName)
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

                    // Aktif section'ı kendi anchor'ına (bugün / bu hafta / bu ay) döndürür.
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        AudioServicesPlaySystemSound(1057)
                        withAnimation(.easeInOut(duration: 0.20)) {
                            state.goToToday()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Bugün")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(.white.opacity(0.78))
                        .frame(width: 82, height: 34)
                        .background(
                            Capsule()
                                .fill(.black.opacity(0.20))
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 6)

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
