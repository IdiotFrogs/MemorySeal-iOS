//
//  ProfileViewModel.swift
//  ProfilePresentation
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import BaseDomain
import HomeDomain

public final class ProfileViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let userUseCase: UserUseCase
    private let homeUseCase: HomeUseCase

    public struct Action {
        public let moveToBack: () -> Void
        public let moveToEditProfile: (_ nickname: String, _ profileImageUrl: String) -> Void
        public let moveToSettings: () -> Void
        public let moveToTicket: (_ capsuleId: Int) -> Void
        public let moveToOpenCapsule: (_ capsuleId: Int, _ imageUrl: String?) -> Void

        public init(moveToBack: @escaping () -> Void, moveToEditProfile: @escaping (_ nickname: String, _ profileImageUrl: String) -> Void, moveToSettings: @escaping () -> Void, moveToTicket: @escaping (_ capsuleId: Int) -> Void, moveToOpenCapsule: @escaping (_ capsuleId: Int, _ imageUrl: String?) -> Void) {
            self.moveToBack = moveToBack
            self.moveToEditProfile = moveToEditProfile
            self.moveToSettings = moveToSettings
            self.moveToTicket = moveToTicket
            self.moveToOpenCapsule = moveToOpenCapsule
        }
    }
    public let action: Action

    private let userInfo: BehaviorRelay<UserInfoEntity?> = .init(value: nil)
    private let openedTickets: BehaviorRelay<[TimeCapsuleEntity]> = .init(value: [])
    private let refreshRelay: PublishRelay<Void> = .init()

    public func refresh() {
        refreshRelay.accept(())
    }

    struct Input {
        let viewDidLoad: PublishRelay<Void>
        let backButtonDidTap: ControlEvent<Void>
        let editProfileButtonDidTap: ControlEvent<Void>
        let settingButtonDidTap: ControlEvent<Void>
        let ticketDidTap: Observable<IndexPath>
    }

    struct Output {
        let userInfo: Driver<UserInfoEntity?>
        let openedTickets: Driver<[TimeCapsuleEntity]>
    }

    public init(userUseCase: UserUseCase, homeUseCase: HomeUseCase, action: Action) {
        self.userUseCase = userUseCase
        self.homeUseCase = homeUseCase
        self.action = action
    }

    func translation(_ input: Input) -> Output {
        Observable.merge(
            input.viewDidLoad.asObservable(),
            refreshRelay.asObservable()
        )
        .withUnretained(self)
        .subscribe(onNext: { (self, _) in
            Task {
                do {
                    let user = try await self.userUseCase.fetchUserInfo()
                    await MainActor.run {
                        self.userInfo.accept(user)
                    }
                } catch {}
            }

            Task {
                do {
                    let tickets = try await self.homeUseCase.fetchOpenedTimeCapsules()
                    await MainActor.run {
                        self.openedTickets.accept(tickets)
                    }
                } catch {
                    await MainActor.run {
                        self.openedTickets.accept([])
                    }
                }
            }
        })
        .disposed(by: disposeBag)

        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToBack()
            })
            .disposed(by: disposeBag)

        input.editProfileButtonDidTap
            .withLatestFrom(userInfo.asObservable())
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { (self, user) in
                self.action.moveToEditProfile(user.nickname, user.profileImageUrl)
            })
            .disposed(by: disposeBag)

        input.settingButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToSettings()
            })
            .disposed(by: disposeBag)

        input.ticketDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPath) in
                guard indexPath.item < self.openedTickets.value.count else { return }
                let entity = self.openedTickets.value[indexPath.item]
                self.action.moveToOpenCapsule(entity.timeCapsuleId, entity.imageUrl)
            })
            .disposed(by: disposeBag)

        return Output(
            userInfo: userInfo.asDriver(),
            openedTickets: openedTickets.asDriver()
        )
    }
}
