//
//  TutorialViewModel.swift
//  TutorialPresentation
//
//  Created by 선민재 on 10/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public final class TutorialViewModel {

    public struct Action {
        public let tutorialDidFinish: () -> Void

        public init(tutorialDidFinish: @escaping () -> Void) {
            self.tutorialDidFinish = tutorialDidFinish
        }
    }

    struct Input {
        let nextButtonDidTap: Observable<Void>
        let skipButtonDidTap: Observable<Void>
        let pageDidScroll: Observable<Int>
    }

    struct Output {
        let currentPage: Driver<Int>
        let scrollToPage: Signal<Int>
    }

    // MARK: - Properties

    let pages: [TutorialPage] = TutorialPage.all

    private let action: Action
    private let currentPageRelay: BehaviorRelay<Int> = .init(value: 0)
    private let scrollToPageRelay: PublishRelay<Int> = .init()
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - Init

    public init(action: Action) {
        self.action = action
    }

    // MARK: - Binding

    func translation(_ input: Input) -> Output {
        input.pageDidScroll
            .distinctUntilChanged()
            .bind(to: currentPageRelay)
            .disposed(by: disposeBag)

        input.nextButtonDidTap
            .withUnretained(self)
            .subscribe { (self, _) in
                self.moveToNextPage()
            }
            .disposed(by: disposeBag)

        input.skipButtonDidTap
            .withUnretained(self)
            .subscribe { (self, _) in
                self.action.tutorialDidFinish()
            }
            .disposed(by: disposeBag)

        return Output(
            currentPage: currentPageRelay.asDriver(),
            scrollToPage: scrollToPageRelay.asSignal()
        )
    }

    private func moveToNextPage() {
        let nextPage = currentPageRelay.value + 1

        guard nextPage < pages.count else {
            action.tutorialDidFinish()
            return
        }

        scrollToPageRelay.accept(nextPage)
    }
}
