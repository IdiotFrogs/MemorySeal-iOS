//
//  OpenedTicketViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 9/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import BaseDomain
import HomeDomain

public final class OpenedTicketViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    private enum Constant {
        static let pageSize: Int = 20
    }

    public struct Action {
        public let moveToTicket: (_ capsuleId: Int) -> Void

        public init(moveToTicket: @escaping (_ capsuleId: Int) -> Void) {
            self.moveToTicket = moveToTicket
        }
    }

    public let action: Action

    private let homeUseCase: HomeUseCase

    private let ticketList: BehaviorRelay<[TimeCapsuleEntity]> = .init(value: [])
    private let refreshRelay: PublishRelay<Void> = .init()
    private var loadGeneration: Int = 0
    private var currentPage: Int = 0
    private var isLastPage: Bool = true
    private var isLoading: Bool = false

    public func refresh() {
        refreshRelay.accept(())
    }

    struct Input {
        let rxViewWillAppear: PublishRelay<Void>
        let didTapItem: ControlEvent<IndexPath>
        let didReachBottom: PublishRelay<Void>
    }

    struct Output {
        let ticketList: BehaviorRelay<[TimeCapsuleEntity]>
    }

    func translation(_ input: Input) -> Output {

        Observable.merge(
            input.rxViewWillAppear.asObservable(),
            refreshRelay.asObservable()
        )
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

        return Output(ticketList: ticketList)
    }

    private func loadFirstPage() {
        loadGeneration += 1
        let generation = loadGeneration
        isLoading = true

        Task {
            do {
                let page = try await self.homeUseCase.fetchTimeCapsules(
                    status: .opened,
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
                    status: .opened,
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

    public init(homeUseCase: HomeUseCase, action: Action) {
        self.homeUseCase = homeUseCase
        self.action = action
    }
}
