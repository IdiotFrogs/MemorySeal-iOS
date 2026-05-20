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

    // MARK: - Write (placeholder)

    public func appendMessage(_ message: MyMemoryMessage) {}

    // MARK: - Delete

    public func deleteTextContents(_ ids: Set<Int>) {
        guard !ids.isEmpty else { return }
        let remaining = contents.value.filter { item in
            if case .text(let id, _) = item {
                return !ids.contains(id)
            }
            return true
        }
        contents.accept(remaining)
    }

    public func deletePhotoUrls(_ urls: Set<String>) {
        guard !urls.isEmpty else { return }
        let updated = contents.value.compactMap { item -> CapsuleContent? in
            if case .photo(let id, let imageUrls) = item {
                let remaining = imageUrls.filter { !urls.contains($0) }
                if remaining.isEmpty { return nil }
                return .photo(id: id, imageUrls: remaining)
            }
            return item
        }
        contents.accept(updated)
    }
}
