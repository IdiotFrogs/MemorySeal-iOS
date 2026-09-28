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
    private let sort: WateringSort
    private let prefetchThreshold: Int
    private let calendar: Calendar = Calendar.current

    let summary: BehaviorRelay<WateringEntity?> = .init(value: nil)
    let daysByDate: BehaviorRelay<[Date: WateringDayEntity]> = .init(value: [:])
    let startDate: BehaviorRelay<Date?> = .init(value: nil)
    let errorToast: PublishRelay<String> = .init()

    private var nextPage: Int = Page.first
    private var isLastPage: Bool = false
    private var isLoading: Bool = false
    private var isWatering: Bool = false
    private var loadGeneration: Int = 0

    init(
        capsuleId: Int,
        wateringUseCase: WateringUseCase,
        pageSize: Int,
        sort: WateringSort
    ) {
        self.capsuleId = capsuleId
        self.wateringUseCase = wateringUseCase
        self.pageSize = pageSize
        self.sort = sort
        self.prefetchThreshold = max(pageSize / 5, Page.minimumPrefetchThreshold)
    }

    var isWateredToday: Bool {
        let today = calendar.startOfDay(for: Date())
        return daysByDate.value[today]?.isWatered ?? false
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
                    size: self.pageSize,
                    sort: self.sort
                )
                await MainActor.run {
                    guard generation == self.loadGeneration else { return }
                    self.summary.accept(entity)
                    self.merge(entity, page: page)
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
        guard isNearUnloadedEdge(prefetching: indexPaths) else { return }
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

    // MARK: - Merge

    private func merge(_ entity: WateringEntity, page: Int) {
        if page == Page.first {
            startDate.accept(resolveStartDate(entity))
        }

        var merged = page == Page.first ? [:] : daysByDate.value
        for day in entity.days {
            guard let wateredDate = day.wateredDate else { continue }
            merged[calendar.startOfDay(for: wateredDate)] = day
        }
        daysByDate.accept(merged)
    }

    private func resolveStartDate(_ entity: WateringEntity) -> Date? {
        guard let anchor = entity.days.first?.wateredDate else { return nil }
        let anchorDay = calendar.startOfDay(for: anchor)

        switch sort {
        case .asc:
            return anchorDay
        case .desc:
            let elapsed = max(entity.totalElements, 1) - 1
            return calendar.date(byAdding: .day, value: -elapsed, to: anchorDay)
        }
    }

    // MARK: - Prefetch

    private func isNearUnloadedEdge(prefetching indexPaths: [IndexPath]) -> Bool {
        guard let startDate = startDate.value else { return true }

        let loadedIndexes = daysByDate.value.keys.compactMap {
            calendar.dateComponents([.day], from: startDate, to: $0).day
        }

        switch sort {
        case .asc:
            guard let highest = loadedIndexes.max() else { return true }
            return indexPaths.contains { $0.item >= highest - prefetchThreshold }
        case .desc:
            guard let lowest = loadedIndexes.min() else { return true }
            return indexPaths.contains { $0.item <= lowest + prefetchThreshold }
        }
    }

    func refresh() {
        loadGeneration += 1
        nextPage = Page.first
        isLastPage = false
        isLoading = false
        loadNextPageIfNeeded()
    }
}
