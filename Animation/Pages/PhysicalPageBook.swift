import SwiftUI
import UIKit
import AudioToolbox
import SwiftData

// MARK: - Physical Page Book

struct PhysicalPageBook: UIViewControllerRepresentable {

    let state: AgendaState

    @Binding var currentSpread: Int

    private let totalSpreads = 100

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(
        context: Context
    ) -> UIPageViewController {

        let controller = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: nil
        )

        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator

        // UIPageViewController'ın kendi page-curl pan gesture'ı, içerikteki
        // TextField/Button gibi etkileşimli SwiftUI kontrollerine giden
        // dokunuşu kendine alabiliyor (metin kutusuna dokunulduğunda klavye
        // yerine sayfanın çevrilmesi tam olarak bundandı). Bu gesture'lara
        // delegate atayıp, dokunuş etkileşimli bir kontrolün üzerindeyse
        // gesture'ın devreye girmesini engelliyoruz.
        for gestureRecognizer in controller.view.gestureRecognizers ?? [] {
            gestureRecognizer.delegate = context.coordinator
        }

        // PhysicalPageBook, sayfaları normal SwiftUI ağacının dışında elle
        // yaratıyor (UIHostingController olarak), bu yüzden .modelContainer
        // ile yukarıda kurulan modelContext buraya otomatik ulaşmaz — context
        // üzerinden elle yakalayıp Coordinator'a taşıyoruz.
        context.coordinator.modelContext = context.environment.modelContext

        let initialPage = context.coordinator.makePage(
            index: currentSpread
        )

        controller.setViewControllers(
            [initialPage],
            direction: .forward,
            animated: false
        )

        context.coordinator.displayedSpread = currentSpread

        return controller
    }

    func updateUIViewController(
        _ controller: UIPageViewController,
        context: Context
    ) {

        guard !context.coordinator.isTransitioning else {
            return
        }

        guard currentSpread != context.coordinator.displayedSpread else {
            return
        }

        context.coordinator.modelContext = context.environment.modelContext

        let direction: UIPageViewController.NavigationDirection =
            currentSpread > context.coordinator.displayedSpread
            ? .forward
            : .reverse

        let page = context.coordinator.makePage(
            index: currentSpread
        )

        context.coordinator.displayedSpread = currentSpread
        context.coordinator.isTransitioning = true

        controller.setViewControllers(
            [page],
            direction: direction,
            animated: true
        ) { _ in
            context.coordinator.isTransitioning = false
        }
    }

    // MARK: - Coordinator

    final class Coordinator:
        NSObject,
        UIPageViewControllerDataSource,
        UIPageViewControllerDelegate,
        UIGestureRecognizerDelegate {

        let parent: PhysicalPageBook

        var displayedSpread: Int = 0

        // Aynı spread index için AgendaSpreadController'ı tekrar tekrar
        // yaratmamak için önbellek. UIPageViewController, komşu sayfaları
        // (before/after) sıkça yeniden sorguladığı için bu, gereksiz
        // instance üretimini ve buna bağlı appearance-transition çakışmasını azaltır.
        //
        // Anahtar hem section hem index içerir: aynı sayısal spread farklı
        // section'larda farklı şey ifade ediyor (Day'de gün, Week'te hafta,
        // Month'ta ay). Sadece index ile anahtarlarsak, tab değiştiğinde
        // başka bir section'a ait eski içerikli controller yeniden
        // kullanılır ve page-curl animasyonu sırasında bir anlık eski
        // içerik görünebilirdi.
        var pageCache: [String: AgendaSpreadController] = [:]

        private func cacheKey(section: AgendaState.Section, index: Int) -> String {
            "\(section.rawValue)-\(index)"
        }

        // .modelContainer(for:) ile kurulan SwiftData context'i — normal
        // SwiftUI ağacının dışında yaratılan sayfalara elle taşımak için
        // makeUIViewController/updateUIViewController içinde güncelleniyor.
        var modelContext: ModelContext?

        // setViewControllers çağrısı devam ederken (özellikle kullanıcı
        // parmakla hızlı art arda sayfa çevirirken) ikinci bir programatik
        // çağrının araya girmesini engeller. Bu, "Unbalanced calls to
        // begin/end appearance transitions" uyarısının en olası sebebiydi.
        var isTransitioning = false

        init(_ parent: PhysicalPageBook) {
            self.parent = parent
        }

        // MARK: - Create Page

        func makePage(index: Int) -> AgendaSpreadController {

            let safeIndex = max(
                0,
                min(index, parent.totalSpreads - 1)
            )

            let key = cacheKey(section: parent.state.section, index: safeIndex)

            if let cached = pageCache[key] {
                return cached
            }

            let page = AgendaSpreadPage(
                state: parent.state,
                spread: safeIndex
            )

            let rootView: AnyView
            if let modelContext {
                rootView = AnyView(page.modelContext(modelContext))
            } else {
                rootView = AnyView(page)
            }

            let controller = AgendaSpreadController(
                spread: safeIndex,
                rootView: rootView
            )

            pageCache[key] = controller

            return controller
        }

        // MARK: - Previous Page

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {

            guard let page =
                viewController as? AgendaSpreadController
            else {
                return nil
            }

            let previous = page.spread - 1

            guard previous >= 0 else {
                return nil
            }

            return makePage(index: previous)
        }

        // MARK: - Next Page

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {

            guard let page =
                viewController as? AgendaSpreadController
            else {
                return nil
            }

            let next = page.spread + 1

            guard next < parent.totalSpreads else {
                return nil
            }

            return makePage(index: next)
        }

        // MARK: - Transition Completed

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {

            guard completed else {
                return
            }

            guard let visible =
                pageViewController.viewControllers?.first
                as? AgendaSpreadController
            else {
                return
            }

            displayedSpread = visible.spread

            // Her tamamlanan sayfa çevirişinde hafif bir dokunsal geri bildirim —
            // hem parmakla hem programatik (Today/tab) geçişlerde tetiklenir.
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            // iOS sistem sesi (ID 1104, "Tock") — resmi olmayan ama yaygın
            // kullanılan bir kısa tık sesi. Gerçek bir kağıt sesi asseti
            // eklendiğinde AVAudioPlayer ile kolayca değiştirilebilir.
            AudioServicesPlaySystemSound(1104)

            DispatchQueue.main.async {
                self.parent.currentSpread = visible.spread
            }
        }

        // MARK: - Gesture vs. Interactive Control

        // Dokunuş bir metin kutusu, buton gibi klavye/etkileşim isteyen bir
        // kontrolün üzerindeyse, page-curl gesture'ının bu dokunuşu
        // almasını engeller — böylece dokunuş normal şekilde SwiftUI
        // içeriğine (TextField, Button vb.) ulaşabilir.
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldReceive touch: UITouch
        ) -> Bool {

            guard let view = touch.view else {
                return true
            }

            return !isInteractiveControl(view)
        }

        private func isInteractiveControl(_ view: UIView) -> Bool {
            var current: UIView? = view

            while let v = current {
                if v is UIControl || v.canBecomeFirstResponder {
                    return true
                }
                current = v.superview
            }

            return false
        }
    }
}


// MARK: - Agenda Spread Controller

final class AgendaSpreadController:
    UIHostingController<AnyView> {

    let spread: Int

    init(
        spread: Int,
        rootView: AnyView
    ) {
        self.spread = spread

        super.init(rootView: rootView)

        view.backgroundColor = .clear
    }

    @MainActor
    required dynamic init?(
        coder aDecoder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Physical Spread Content

struct AgendaSpreadPage: View {

    let state: AgendaState
    let spread: Int

    var body: some View {

        GeometryReader { proxy in

            // NOT: sayfa genişliğinde eskiden sabit bir "en az 180pt" alt
            // sınırı vardı. iPhone gibi dar ekranlarda bu, iki sayfanın
            // toplamının fiilen kullanılabilir genişlikten daha geniş
            // olmasına ve sağ sayfanın ekranın dışına taşıp görünmez/
            // dokunulmaz hale gelmesine sebep oluyordu. Alt sınırı,
            // gerçekten çok küçük/patolojik durumlar dışında devreye
            // girmeyecek kadar düşük (100pt) tutuyoruz.
            let pageSize = CGSize(
                width: max(
                    (proxy.size.width - 46) / 2,
                    100
                ),
                height: max(
                    proxy.size.height - 36,
                    260
                )
            )

            HStack(spacing: 12) {

                page(
                    isLeft: true,
                    section: state.section,
                    spread: spread
                )

                page(
                    isLeft: false,
                    section: state.section,
                    spread: spread
                )
            }
            .frame(
                width: pageSize.width * 2 + 12,
                height: pageSize.height
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 18)
        }
        .background(Color.clear)
    }

    @ViewBuilder
    private func page(
        isLeft: Bool,
        section: AgendaState.Section,
        spread: Int
    ) -> some View {

        switch section {

        case .day:
            DayPage(
                isLeft: isLeft,
                spread: spread
            )

        case .week:
            WeekPage(
                isLeft: isLeft,
                spread: spread
            )

        case .month:
            MonthPage(
                isLeft: isLeft,
                spread: spread
            )

        case .notes:
            NotesPage(
                isLeft: isLeft,
                spread: spread
            )

        case .todo:
            TodoPage(
                isLeft: isLeft,
                spread: spread
            )
        }
    }
}