import Foundation
import RxSwift
import RxCocoa
import RxRelay

import MemoryDomain

public final class MyMemoryMessagesViewModel {

    // MARK: - Properties

    private let capsuleId: Int
    private let capsuleContentUseCase: CapsuleContentUseCase
    private let contents: BehaviorRelay<[CapsuleContent]> = BehaviorRelay(value: [])

    // MARK: - Init

    public init(capsuleId: Int, capsuleContentUseCase: CapsuleContentUseCase) {
        self.capsuleId = capsuleId
        self.capsuleContentUseCase = capsuleContentUseCase
    }

    // MARK: - Fetch

    public func fetchContents() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await capsuleContentUseCase.execute(capsuleId: capsuleId)
                await MainActor.run {
                    self.contents.accept(result)
                }
            } catch {
                print("fetchContents error:", error)
            }
        }
    }

    // MARK: - Output

    public func textContents() -> Driver<[CapsuleContent]> {
        return contents
            .map { items in
                items.filter {
                    if case .text = $0 { return true }
                    return false
                }
            }
            .asDriver(onErrorJustReturn: [])
    }

    public func photoImageUrls() -> Driver<[String]> {
        return contents
            .map { items in
                items.flatMap { item -> [String] in
                    if case .photo(_, let imageUrls) = item { return imageUrls }
                    return []
                }
            }
            .asDriver(onErrorJustReturn: [])
    }

    // MARK: - Create

    public func createTextContent(_ text: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let created = try await capsuleContentUseCase.createText(capsuleId: capsuleId, content: text)
                await MainActor.run {
                    self.contents.accept(self.contents.value + [created])
                }
            } catch {
                print("createTextContent error:", error)
            }
        }
    }

    public func createPhotoContent(_ images: [Data]) {
        guard !images.isEmpty else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                let created = try await capsuleContentUseCase.createPhotos(capsuleId: capsuleId, images: images)
                await MainActor.run {
                    self.contents.accept(self.contents.value + [created])
                }
            } catch {
                print("createPhotoContent error:", error)
            }
        }
    }

    // MARK: - Delete

    public func deleteTextContents(_ ids: Set<Int>) {
        guard !ids.isEmpty else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                for id in ids {
                    try await capsuleContentUseCase.delete(contentId: id)
                }
                await MainActor.run {
                    let remaining = self.contents.value.filter { item in
                        if case .text(let id, _) = item {
                            return !ids.contains(id)
                        }
                        return true
                    }
                    self.contents.accept(remaining)
                }
            } catch {
                print("deleteTextContents error:", error)
            }
        }
    }

    public func deletePhotoUrls(_ urls: Set<String>) {
        guard !urls.isEmpty else { return }
        let contentIds: Set<Int> = Set(contents.value.compactMap { item -> Int? in
            if case .photo(let id, let imageUrls) = item {
                return imageUrls.contains(where: { urls.contains($0) }) ? id : nil
            }
            return nil
        })
        guard !contentIds.isEmpty else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                for id in contentIds {
                    try await capsuleContentUseCase.delete(contentId: id)
                }
                await MainActor.run {
                    let remaining = self.contents.value.filter { item in
                        if case .photo(let id, _) = item {
                            return !contentIds.contains(id)
                        }
                        return true
                    }
                    self.contents.accept(remaining)
                }
            } catch {
                print("deletePhotoUrls error:", error)
            }
        }
    }
}
