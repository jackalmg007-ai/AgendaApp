import SwiftUI

struct AgendaShellView: View {
    @Environment(AgendaState.self) private var state

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LeatherBackground()
                    .ignoresSafeArea()

                RoundedRectangle(cornerRadius: AgendaDesign.shellRadius)
                    .fill(.black.opacity(0.16))
                    .padding(14)
                    .blur(radius: 2)

                HStack(spacing: 0) {
                    BindingView()
                        .frame(width: 34)
                        .padding(.vertical, 34)

                    AgendaSpread()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 18)
                }
                .padding(.leading, 96)
                .padding(.trailing, 18)

                SideTabs()
            }
        }
        .preferredColorScheme(.light)
        .statusBarHidden()
    }
}
