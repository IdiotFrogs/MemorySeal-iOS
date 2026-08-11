import Foundation
import RxSwift
import RxCocoa

import TicketDomain

final class WateringStore {
    private enum Page {
        static let first: Int = 0
        static let minimumPrefetchThreshold: Int = 3
    }

    private let capsuleId: Int
    private let wateringUseCase: WateringUseCase
    private let pageSize: Int
    private let prefetchThreshold: Int

    let summary: BehaviorRelay<WateringEntity?> = .init(value: nil)
    let days: BehaviorRelay<[WateringDayEntity]> = .init(value: [])
    let errorToast: PublishRelay<String> = .init()

    private var nextPage: Int = Page.first
    private var isLastPage: Bool = false
    private var isLoading: Bool = false
    private var isWatering: Bool = false
    private var loadGeneration: Int = 0

    init(
        capsuleId: Int,
        wateringUseCase: WateringUseCase,
        pageSize: Int
    ) {
        self.capsuleId = capsuleId
        self.wateringUseCase = wateringUseCase
        self.pageSize = pageSize
        self.prefetchThreshold = max(pageSize / 5, Page.minimumPrefetchThreshold)
    }

    var isWateredToday: Bool {
        return WateringDayItemBuilder.isWateredToday(days.value)
    }

    func loadNextPageIfNeeded() {
        guard !isLoading, !isLastPage else { return }
        isLoading = true

        let page = nextPage
        let generation = loadGeneration
        Task { [weak self] in
            guard let self else { return }
            do {
                let entity = try await self.wateringUseCase.fetchWaterings(
                    capsuleId: self.capsuleId,
                    page: page,
                    size: self.pageSize
                )
                await MainActor.run {
                    guard generation == self.loadGeneration else { return }
                    self.summary.accept(entity)
                    self.days.accept(page == Page.first ? entity.days : self.days.value + entity.days)
                    self.nextPage = page + 1
                    self.isLastPage = entity.isLast || entity.days.isEmpty
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    guard generation == self.loadGeneration else { return }
                    self.isLoading = false
                    self.errorToast.accept("물주기 정보를 불러올 수 없습니다")
                }
            }
        }
    }

    func loadNextPageIfNeeded(prefetching indexPaths: [IndexPath]) {
        let loadedCount = days.value.count
        let isNearEnd = indexPaths.contains { $0.item >= loadedCount - prefetchThreshold }
        guard isNearEnd else { return }
        loadNextPageIfNeeded()
    }

    func water() {
        guard !isWatering else { return }
        isWatering = true

        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.wateringUseCase.water(capsuleId: self.capsuleId)
                await MainActor.run {
                    self.isWatering = false
                    self.refresh()
                }
            } catch {
                await MainActor.run {
                    self.isWatering = false
                    self.errorToast.accept("물주기에 실패했습니다")
                }
            }
        }
    }

    private func refresh() {
        loadGeneration += 1
        nextPage = Page.first
        isLastPage = false
        isLoading = false
        loadNextPageIfNeeded()
    }
}
