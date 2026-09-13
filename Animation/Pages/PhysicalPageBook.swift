import SwiftUI
import UIKit

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

        guard currentSpread != context.coordinator.displayedSpread else {
            return
        }

        let direction: UIPageViewController.NavigationDirection =
            currentSpread > context.coordinator.displayedSpread
            ? .forward
            : .reverse

        let page = context.coordinator.makePage(
            index: currentSpread
        )

        controller.setViewControllers(
            [page],
            direction: direction,
            animated: true
        )

        context.coordinator.displayedSpread = currentSpread
    }

    // MARK: - Coordinator

    final class Coordinator:
        NSObject,
        UIPageViewControllerDataSource,
        UIPageViewControllerDelegate {

        let parent: PhysicalPageBook

        var displayedSpread: Int = 0

        init(_ parent: PhysicalPageBook) {
            self.parent = parent
        }

        // MARK: - Create Page

        func makePage(index: Int) -> AgendaSpreadController {

            let safeIndex = max(
                0,
                min(index, parent.totalSpreads - 1)
            )

            let page = AgendaSpreadPage(
                state: parent.state,
                spread: safeIndex
            )

            return AgendaSpreadController(
                spread: safeIndex,
                rootView: page
            )
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

            DispatchQueue.main.async {
                self.parent.currentSpread = visible.spread
            }
        }
    }
}


// MARK: - Agenda Spread Controller

final class AgendaSpreadController:
    UIHostingController<AgendaSpreadPage> {

    let spread: Int

    init(
        spread: Int,
        rootView: AgendaSpreadPage
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

            let pageSize = CGSize(
                width: max(
                    (proxy.size.width - 46) / 2,
                    180
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