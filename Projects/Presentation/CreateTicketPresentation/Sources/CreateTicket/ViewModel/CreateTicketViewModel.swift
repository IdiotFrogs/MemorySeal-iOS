//
//  CreateTicketViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 5/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import CreateTicketDomain
import DesignSystem

public final class CreateTicketViewModel {
    public struct Action {
        public let popViewController: () -> Void

        public init(popViewController: @escaping () -> Void) {
            self.popViewController = popViewController
        }
    }

    private let disposeBag: DisposeBag = DisposeBag()
    private let createTicketUseCase: CreateTicketUseCase

    public let action: Action

    private var storedImage: UIImage?

    public init(
        createTicketUseCase: CreateTicketUseCase,
        action: Action
    ) {
        self.createTicketUseCase = createTicketUseCase
        self.action = action
    }

    struct Input {
        let navigationViewBackButtonDidTap: ControlEvent<Void>
        let createButtonDidTap: ControlEvent<Void>
        let titleText: ControlProperty<String?>
        let descriptionText: ControlProperty<String?>
        let selectedImage: PublishRelay<UIImage>
    }

    struct Output {
        let isLoading: BehaviorRelay<Bool>
        let canCreate: Driver<Bool>
    }

    func transform(_ input: Input) -> Output {
        let isLoading = BehaviorRelay<Bool>(value: false)
        let imageSelectedRelay = BehaviorRelay<Bool>(value: false)

        input.navigationViewBackButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.popViewController()
            })
            .disposed(by: disposeBag)

        input.selectedImage
            .withUnretained(self)
            .subscribe(onNext: { (self, image) in
                self.storedImage = image
                imageSelectedRelay.accept(true)
            })
            .disposed(by: disposeBag)

        input.createButtonDidTap
            .withLatestFrom(Observable.combineLatest(
                input.titleText.asObservable(),
                input.descriptionText.asObservable()
            ))
            .withUnretained(self)
            .subscribe(onNext: { (self, args) in
                let (title, description) = args
                guard let title, !title.isEmpty else { return }
                guard let imageData = self.storedImage?.jpegData(compressionQuality: 0.8) else { return }
                let desc = description.flatMap { $0.isEmpty ? nil : $0 }
                self.requestCreateTicket(
                    title: title,
                    description: desc,
                    mainImage: imageData,
                    isLoading: isLoading
                )
            })
            .disposed(by: disposeBag)

        let titleNonEmpty = input.titleText
            .orEmpty
            .map { !$0.isEmpty }

        let canCreate = Observable.combineLatest(
            titleNonEmpty.asObservable(),
            imageSelectedRelay.asObservable(),
            isLoading.asObservable()
        ) { titleOk, imageOk, loading in
            titleOk && imageOk && !loading
        }
        .asDriver(onErrorJustReturn: false)

        return Output(
            isLoading: isLoading,
            canCreate: canCreate
        )
    }
}

extension CreateTicketViewModel {
    private func requestCreateTicket(
        title: String,
        description: String?,
        mainImage: Data,
        isLoading: BehaviorRelay<Bool>
    ) {
        isLoading.accept(true)
        Task {
            do {
                try await createTicketUseCase.execute(
                    title: title,
                    description: description,
                    mainImage: mainImage
                )
                await MainActor.run {
                    isLoading.accept(false)
                    self.action.popViewController()
                }
            } catch {
                await MainActor.run {
                    isLoading.accept(false)
                }
            }
        }
    }
}
