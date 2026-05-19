import Foundation
import RxSwift
import RxCocoa
import RxRelay

public final class MyMemoryMessagesViewModel {

    // MARK: - Properties

    private let messages: BehaviorRelay<[MyMemoryMessage]> = BehaviorRelay(value: [])

    // MARK: - Init

    public init() {}

    // MARK: - Public

    public func messages(of type: MyMemoryMessageType) -> Driver<[MyMemoryMessage]> {
        return messages
            .map { items in items.filter { $0.type == type } }
            .asDriver(onErrorJustReturn: [])
    }

    public func appendMessage(_ message: MyMemoryMessage) {
        messages.accept(messages.value + [message])
    }
}
