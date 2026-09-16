//
//  TicketListViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 9/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import BaseDomain
import HomeDomain

public final class TicketListViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    private enum Constant {
        static let pageSize: Int = 20
    }

    public struct Action {
        public let moveToBack: () -> Void
        public let moveToTicket: (_ capsuleId: Int) -> Void

        public init(
            moveToBack: @escaping () -> Void,
            moveToTicket: @escaping (_ capsuleId: Int) -> Void
        ) {
            self.moveToBack = moveToBack
            self.moveToTicket = moveToTicket
        }
    }

    public let action: Action
    public let kind: HomeSectionKind

    private let homeUseCase: HomeUseCase

    private let ticketList: BehaviorRelay<[TimeCapsuleEntity]> = .init(value: [])
    private var loadGeneration: Int = 0
    private var currentPage: Int = 0
    private var isLastPage: Bool = true
    private var isLoading: Bool = false

    struct Input {
        let rxViewWillAppear: PublishRelay<Void>
        let didTapItem: ControlEvent<IndexPath>
        let didReachBottom: PublishRelay<Void>
        let backButtonDidTap: ControlEvent<Void>
    }

    struct Output {
        let ticketList: BehaviorRelay<[TimeCapsuleEntity]>
    }

    func translation(_ input: Input) -> Output {

        input.rxViewWillAppear
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.loadFirstPage()
            })
            .disposed(by: disposeBag)

        input.didReachBottom
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.loadNextPage()
            })
            .disposed(by: disposeBag)

        input.didTapItem
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPath) in
                guard indexPath.item < self.ticketList.value.count else { return }
                let entity = self.ticketList.value[indexPath.item]
                self.action.moveToTicket(entity.timeCapsuleId)
            })
            .disposed(by: disposeBag)

        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToBack()
            })
            .disposed(by: disposeBag)

        return Output(ticketList: ticketList)
    }

    private var status: TimeCapsuleStatus {
        switch kind {
        case .upcoming:
            return .buried
        case .banner, .hero, .timeTicket:
            return .beforeBuried
        }
    }

    private func loadFirstPage() {
        loadGeneration += 1
        let generation = loadGeneration
        isLoading = true

        Task {
            do {
                let page = try await self.homeUseCase.fetchTimeCapsules(
                    status: self.status,
                    page: 0,
                    size: Constant.pageSize
                )
                await MainActor.run {
                    guard generation == self.loadGeneration else { return }
                    self.currentPage = page.currentPage
                    self.isLastPage = page.isLast
                    self.isLoading = false
                    self.ticketList.accept(page.timeCapsules)
                }
            } catch {
                await MainActor.run {
                    guard generation == self.loadGeneration else { return }
                    self.currentPage = 0
                    self.isLastPage = true
                    self.isLoading = false
                    self.ticketList.accept([])
                }
            }
        }
    }

    private func loadNextPage() {
        guard !isLoading, !isLastPage else { return }

        let generation = loadGeneration
        let nextPage = currentPage + 1
        isLoading = true

        Task {
            do {
                let page = try await self.homeUseCase.fetchTimeCapsules(
                    status: self.status,
                    page: nextPage,
                    size: Constant.pageSize
                )
                await MainActor.run {
                    guard generation == self.loadGeneration else { return }
                    self.currentPage = page.currentPage
                    self.isLastPage = page.isLast
                    self.isLoading = false
                    self.ticketList.accept(self.ticketList.value + page.timeCapsules)
                }
            } catch {
                await MainActor.run {
                    guard generation == self.loadGeneration else { return }
                    self.isLoading = false
                }
            }
        }
    }

    public init(
        kind: HomeSectionKind,
        homeUseCase: HomeUseCase,
        action: Action
    ) {
        self.kind = kind
        self.homeUseCase = homeUseCase
        self.action = action
    }
}
