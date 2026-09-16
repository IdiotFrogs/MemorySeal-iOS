//
//  HomeViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 5/26/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import BaseDomain
import HomeDomain

public final class HomeViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    private enum Text {
        static let timeTicketTitle: String = "타임 티켓"
        static let upcomingTitle: String = "오픈 예정 티켓"
    }

    private enum Constant {
        static let maxSectionItemCount: Int = 6
    }

    public struct Action {
        public let moveToTicket: (_ capsuleId: Int) -> Void
        public let moveToOpenCapsule: (_ capsuleId: Int, _ imageUrl: String?) -> Void
        public let moveToSeeAll: (_ kind: HomeSectionKind) -> Void

        public init(
            moveToTicket: @escaping (_ capsuleId: Int) -> Void,
            moveToOpenCapsule: @escaping (_ capsuleId: Int, _ imageUrl: String?) -> Void,
            moveToSeeAll: @escaping (_ kind: HomeSectionKind) -> Void
        ) {
            self.moveToTicket = moveToTicket
            self.moveToOpenCapsule = moveToOpenCapsule
            self.moveToSeeAll = moveToSeeAll
        }
    }

    public let action: Action

    private let homeUseCase: HomeUseCase

    private let sections: BehaviorRelay<[HomeSectionModel]> = .init(value: [])
    private let refreshRelay: PublishRelay<Void> = .init()
    private var loadGeneration: Int = 0

    public func refresh() {
        refreshRelay.accept(())
    }

    struct Input {
        let rxViewWillAppear: PublishRelay<Void>
        let didTapItem: ControlEvent<IndexPath>
        let didTapSeeAll: PublishRelay<HomeSectionKind>
    }

    struct Output {
        let sections: BehaviorRelay<[HomeSectionModel]>
    }

    func translation(_ input: Input) -> Output {

        Observable.merge(
            input.rxViewWillAppear.asObservable(),
            refreshRelay.asObservable()
        )
        .withUnretained(self)
        .subscribe(onNext: { (self, _) in
            self.loadGeneration += 1
            let generation = self.loadGeneration
            Task {
                async let bannerResult = try? await self.homeUseCase.fetchSeasonalBanner()
                async let heroResult = try? await self.homeUseCase.fetchUnopenedTimeCapsules()
                async let timeTicketResult = try? await self.fetchPage(status: .beforeBuried)
                async let upcomingResult = try? await self.fetchPage(status: .buried)

                let banner = await bannerResult
                let hero = await heroResult
                let timeTicket = await timeTicketResult
                let upcoming = await upcomingResult

                await MainActor.run {
                    guard generation == self.loadGeneration else { return }
                    self.sections.accept(
                        self.makeSections(
                            hero: hero,
                            timeTicket: timeTicket,
                            upcoming: upcoming,
                            banner: banner
                        )
                    )
                }
            }
        })
        .disposed(by: disposeBag)

        input.didTapItem
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPath) in
                guard indexPath.section < self.sections.value.count else { return }
                let section = self.sections.value[indexPath.section]
                guard indexPath.item < section.items.count else { return }
                let entity = section.items[indexPath.item]
                let capsuleId = entity.timeCapsuleId

                switch section.kind {
                case .hero:
                    self.action.moveToOpenCapsule(capsuleId, entity.imageUrl)
                case .banner, .timeTicket, .upcoming:
                    self.action.moveToTicket(capsuleId)
                }
            })
            .disposed(by: disposeBag)

        input.didTapSeeAll
            .withUnretained(self)
            .subscribe(onNext: { (self, kind) in
                self.action.moveToSeeAll(kind)
            })
            .disposed(by: disposeBag)

        return Output(sections: sections)
    }

    private func fetchPage(status: TimeCapsuleStatus) async throws -> TimeCapsulePageEntity {
        return try await homeUseCase.fetchTimeCapsules(
            status: status,
            page: 0,
            size: Constant.maxSectionItemCount
        )
    }

    private func makeSections(
        hero: [TimeCapsuleEntity]?,
        timeTicket: TimeCapsulePageEntity?,
        upcoming: TimeCapsulePageEntity?,
        banner: SeasonalBannerEntity?
    ) -> [HomeSectionModel] {
        var sectionModels: [HomeSectionModel] = []

        let loadedCapsules = (hero ?? [])
            + [timeTicket, upcoming].compactMap { $0 }.flatMap { $0.timeCapsules }

        if let banner,
           let bannerCapsule = loadedCapsules.first(where: { $0.timeCapsuleId == banner.timeCapsuleId }) {
            sectionModels.append(
                HomeSectionModel(
                    kind: .banner,
                    title: banner.content,
                    showsMore: false,
                    items: [bannerCapsule]
                )
            )
        }

        if let hero, !hero.isEmpty {
            sectionModels.append(
                HomeSectionModel(
                    kind: .hero,
                    title: nil,
                    showsMore: false,
                    items: hero
                )
            )
        }

        if let timeTicket, !timeTicket.timeCapsules.isEmpty {
            sectionModels.append(
                HomeSectionModel(
                    kind: .timeTicket,
                    title: Text.timeTicketTitle,
                    showsMore: !timeTicket.isLast,
                    items: timeTicket.timeCapsules
                )
            )
        }

        if let upcoming, !upcoming.timeCapsules.isEmpty {
            sectionModels.append(
                HomeSectionModel(
                    kind: .upcoming,
                    title: Text.upcomingTitle,
                    showsMore: !upcoming.isLast,
                    items: upcoming.timeCapsules
                )
            )
        }

        return sectionModels
    }

    public init(
        action: Action,
        homeUseCase: HomeUseCase
    ) {
        self.action = action
        self.homeUseCase = homeUseCase
    }
}
