import Foundation
import RxSwift
import RxCocoa
import RxRelay

import TicketDomain

public final class MyTicketMessagesViewModel {

    // MARK: - Action

    public struct Action {
        public let moveToPreview: () -> Void

        public init(moveToPreview: @escaping () -> Void) {
            self.moveToPreview = moveToPreview
        }
    }

    // MARK: - Properties

    private let action: Action
    private let capsuleId: Int
    private let capsuleContentUseCase: CapsuleContentUseCase
    private let contents: BehaviorRelay<[CapsuleContent]> = BehaviorRelay(value: [])
    private let textSaveFailure: PublishRelay<String> = PublishRelay()

    public var textSaveFailureSignal: Signal<String> {
        return textSaveFailure.asSignal()
    }

    // MARK: - Init

    public init(
        action: Action,
        capsuleId: Int,
        capsuleContentUseCase: CapsuleContentUseCase
    ) {
        self.action = action
        self.capsuleId = capsuleId
        self.capsuleContentUseCase = capsuleContentUseCase
    }

    // MARK: - Preview

    public func moveToPreview() {
        action.moveToPreview()
    }

    // MARK: - Fetch

    public func fetchContents() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await capsuleContentUseCase.fetchMyContents(capsuleId: capsuleId)
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
                items.flatMap { $0.imageUrls }
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
                await MainActor.run {
                    self.textSaveFailure.accept(text)
                }
            }
        }
    }

    public func createPhotoContent(_ images: [Data]) {
        guard !images.isEmpty else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await capsuleContentUseCase.createPhotos(capsuleId: capsuleId, images: images)
                let result = try await capsuleContentUseCase.fetchMyContents(capsuleId: capsuleId)
                await MainActor.run {
                    self.contents.accept(result)
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
                try await capsuleContentUseCase.delete(contentIds: Array(ids), fileIds: [])
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
        var contentIds: [Int] = []
        var fileIds: [Int] = []
        for item in contents.value {
            guard case .photo(let id, let files) = item else { continue }
            let selectedFiles = files.filter { urls.contains($0.url) }
            guard !selectedFiles.isEmpty else { continue }
            contentIds.append(id)
            fileIds.append(contentsOf: selectedFiles.compactMap { $0.id })
        }
        guard !contentIds.isEmpty else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                try await capsuleContentUseCase.delete(contentIds: contentIds, fileIds: fileIds)
                await MainActor.run {
                    let remaining = self.contents.value.compactMap { item -> CapsuleContent? in
                        guard case .photo(let id, let files) = item else { return item }
                        let keptFiles = files.filter { !urls.contains($0.url) }
                        guard !keptFiles.isEmpty else { return nil }
                        return .photo(id: id, files: keptFiles)
                    }
                    self.contents.accept(remaining)
                }
            } catch {
                print("deletePhotoUrls error:", error)
            }
        }
    }
}
