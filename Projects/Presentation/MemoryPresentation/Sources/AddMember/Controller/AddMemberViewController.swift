//
//  AddMemberViewController.swift
//  MemoryPresentation
//
//  Created by 선민재 on 10/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class AddMemberViewController: UIViewController {
    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let didTapCopyInviteCode: PublishRelay<Void> = .init()
    private let disposeBag = DisposeBag()

    private let viewModel: AddMemberViewModel
    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("맴버 추가")
        return view
    }()

    private let plusButton: UIButton = {
        let button = UIButton()
        button.setImage(
            DesignSystemAsset.ImageAssets.plusBlack24.image,
            for: .normal
        )
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let view = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
        view.register(AddMemberCollectionViewCell.self, forCellWithReuseIdentifier: AddMemberCollectionViewCell.reuseIdentifier)
        view.backgroundColor = .clear
        return view
    }()

    public init(with viewModel: AddMemberViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        self.addNavigationButton()
        self.addSubViews()
        self.setLayout()
        self.bindButton()
        self.bindViewModel()

        self.rxViewDidLoad.accept(())
    }
}

extension AddMemberViewController {
    private func bindViewModel() {
        let input = AddMemberViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            didTapCopyInviteCode: didTapCopyInviteCode
        )
        let output = viewModel.transform(input)

        output.memberList
            .bind(to: collectionView.rx.items(
                cellIdentifier: AddMemberCollectionViewCell.reuseIdentifier,
                cellType: AddMemberCollectionViewCell.self
            )) { (cell, item, index) in

            }
            .disposed(by: disposeBag)

        output.inviteCode
            .withUnretained(self)
            .subscribe(onNext: { (self, code) in
                UIPasteboard.general.string = code
                ToastView.show(on: self.view, message: "참여 코드가 복사되었습니다")
            })
            .disposed(by: disposeBag)

        output.errorToast
            .withUnretained(self)
            .subscribe(onNext: { (self, message) in
                ToastView.show(on: self.view, message: message)
            })
            .disposed(by: disposeBag)
    }

    private func bindButton() {
        navigationView.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        plusButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.showDropdown()
            })
            .disposed(by: disposeBag)
    }

    private func showDropdown() {
        let dropdown = DropdownMenuView.show(
            on: self.view,
            anchorView: plusButton,
            items: ["참여 링크 공유", "참여 코드 복사"]
        )

        dropdown.itemDidTap
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { (self, index) in
                if index == 1 {
                    self.didTapCopyInviteCode.accept(())
                }
            })
            .disposed(by: disposeBag)
    }
}

extension AddMemberViewController {
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider = { (
            sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment
        ) -> NSCollectionLayoutSection? in
            return self.getAddMemberLayout()
        }

        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
        return layout
    }

    private func getAddMemberLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(48)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(48)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16.0
        return section
    }
}

extension AddMemberViewController {
    private func addNavigationButton() {
        navigationView.addButton(plusButton)
    }

    private func addSubViews() {
        view.addSubview(navigationView)
        view.addSubview(collectionView)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.height.equalTo(56)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
}
