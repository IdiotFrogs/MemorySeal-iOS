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
import TicketDomain

public final class AddMemberViewController: UIViewController {
    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let didTapCopyInviteCode: PublishRelay<Void> = .init()
    private let didTapShareLink: PublishRelay<Void> = .init()
    private let didConfirmDelegateHost: PublishRelay<Int> = .init()
    private let didConfirmKickContributor: PublishRelay<Int> = .init()
    private var isCurrentUserHost: Bool = false
    private let disposeBag = DisposeBag()

    private let viewModel: AddMemberViewModel

    // MARK: - Navigation
    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("멤버")
        return view
    }()

    // MARK: - Action Pills
    private let shareLinkPill: AddMemberActionPillView = AddMemberActionPillView(
        icon: DesignSystemAsset.ImageAssets.shareLinkIcon.image,
        title: "참여 링크 공유"
    )

    private let copyCodePill: AddMemberActionPillView = AddMemberActionPillView(
        icon: DesignSystemAsset.ImageAssets.copyCodeIcon.image,
        title: "참여 코드 복사"
    )

    private let pillStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    // MARK: - Search
    private let searchContainerView: UIView = UIView()

    private let searchWavyBackground: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: UIColor(hex: "#F5F5F5") ?? .systemGray6,
            strokeColor: DesignSystemAsset.ColorAssests.grey1.color,
            lineWidth: 3
        )
        view.waveCornerRadius = 12
        view.waveAmplitude = 1.0
        view.waveSpacing = 4
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let searchIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = DesignSystemAsset.ImageAssets.searchIcon.image
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let searchTextField: UITextField = {
        let tf = UITextField()
        tf.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        tf.textColor = DesignSystemAsset.ColorAssests.grey5.color
        tf.attributedPlaceholder = NSAttributedString(
            string: "검색",
            attributes: [
                .font: DesignSystemFontFamily.Pretendard.medium.font(size: 16),
                .foregroundColor: DesignSystemAsset.ColorAssests.grey3.color
            ]
        )
        return tf
    }()

    // MARK: - Member Section Header
    private let memberSectionStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()

    private let memberLabel: UILabel = {
        let label = UILabel()
        label.text = "멤버"
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        label.textColor = .black
        return label
    }()

    private let memberCountLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        label.textColor = DesignSystemAsset.ColorAssests.primaryNormal.color
        return label
    }()

    // MARK: - Member List
    private lazy var collectionView: UICollectionView = {
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

        self.addSubViews()
        self.setLayout()
        self.bindButton()
        self.bindViewModel()

        self.rxViewDidLoad.accept(())
    }
}

// MARK: - Bind
extension AddMemberViewController {
    private func bindViewModel() {
        let input = AddMemberViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            didTapCopyInviteCode: didTapCopyInviteCode,
            didConfirmDelegateHost: didConfirmDelegateHost,
            didConfirmKickContributor: didConfirmKickContributor
        )
        let output = viewModel.transform(input)

        output.memberList
            .withUnretained(self)
            .do(onNext: { (self, list) in
                self.memberCountLabel.text = "\(list.count)"
                self.isCurrentUserHost = list.first(where: { $0.isMe })?.role == .host
            })
            .map { $0.1 }
            .bind(to: collectionView.rx.items(
                cellIdentifier: AddMemberCollectionViewCell.reuseIdentifier,
                cellType: AddMemberCollectionViewCell.self
            )) { [weak self] (_, collaborator, cell) in
                let role: AddMemberRole
                if collaborator.isMe {
                    role = .me
                } else if collaborator.role == .host {
                    role = .host
                } else {
                    role = .none
                }
                cell.configure(
                    name: collaborator.nickname,
                    profileImageUrl: collaborator.profileImageUrl,
                    role: role,
                    showMoreButton: self?.isCurrentUserHost ?? false
                )

                cell.moreButtonDidTap
                    .withUnretained(cell)
                    .subscribe(onNext: { (_, _) in
                        guard let self else { return }
                        self.showMemberMoreSheet(for: collaborator)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)

        output.inviteCode
            .withUnretained(self)
            .subscribe(onNext: { (self, code) in
                UIPasteboard.general.string = code
                ToastView.show(on: self.view, message: "참여 코드 복사되었습니다.", position: .top)
            })
            .disposed(by: disposeBag)

        output.errorToast
            .withUnretained(self)
            .subscribe(onNext: { (self, message) in
                ToastView.show(on: self.view, message: message)
            })
            .disposed(by: disposeBag)

        output.delegateHostSuccess
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                ToastView.show(on: self.view, message: "방장 위임이 완료되었습니다.", position: .top)
            })
            .disposed(by: disposeBag)

        output.kickContributorSuccess
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                ToastView.show(on: self.view, message: "멤버를 추방했습니다.", position: .top)
            })
            .disposed(by: disposeBag)
    }

    private func showMemberMoreSheet(for collaborator: CollaboratorEntity) {
        let sheet = MemberMoreSheetView.show(on: self.view)

        sheet.delegateButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                sheet.dismiss { [weak self] in
                    self?.showDelegateHostDialog(for: collaborator)
                }
            })
            .disposed(by: disposeBag)

        sheet.kickButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                sheet.dismiss { [weak self] in
                    self?.showKickContributorDialog(for: collaborator)
                }
            })
            .disposed(by: disposeBag)
    }

    private func showKickContributorDialog(for collaborator: CollaboratorEntity) {
        let title = "\u{201C}\(collaborator.nickname)\u{201D}님을\n정말 추방하시겠습니까?"
        let dialog = DialogView.show(
            on: self.view,
            title: title,
            cancelTitle: "취소",
            confirmTitle: "추방",
            confirmStyle: .destructive
        )

        dialog.confirmButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                dialog.dismiss()
                self.didConfirmKickContributor.accept(collaborator.userId)
            })
            .disposed(by: disposeBag)

        dialog.cancelButtonDidTap
            .subscribe(onNext: { [weak dialog] in
                dialog?.dismiss()
            })
            .disposed(by: disposeBag)
    }

    private func showDelegateHostDialog(for collaborator: CollaboratorEntity) {
        let title = "\u{201C}\(collaborator.nickname)\u{201D}님에게\n방장을 위임하시겠습니까?"
        let dialog = DialogView.show(
            on: self.view,
            title: title,
            cancelTitle: "취소",
            confirmTitle: "위임"
        )

        dialog.confirmButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                dialog.dismiss()
                self.didConfirmDelegateHost.accept(collaborator.userId)
            })
            .disposed(by: disposeBag)

        dialog.cancelButtonDidTap
            .subscribe(onNext: { [weak dialog] in
                dialog?.dismiss()
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

        copyCodePill.tap
            .bind(to: didTapCopyInviteCode)
            .disposed(by: disposeBag)

        shareLinkPill.tap
            .bind(to: didTapShareLink)
            .disposed(by: disposeBag)
    }
}

// MARK: - Layout
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
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
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
    private func addSubViews() {
        view.addSubview(navigationView)

        pillStackView.addArrangedSubview(shareLinkPill)
        pillStackView.addArrangedSubview(copyCodePill)
        view.addSubview(pillStackView)

        searchContainerView.addSubview(searchWavyBackground)
        searchContainerView.addSubview(searchIconImageView)
        searchContainerView.addSubview(searchTextField)
        view.addSubview(searchContainerView)

        memberSectionStackView.addArrangedSubview(memberLabel)
        memberSectionStackView.addArrangedSubview(memberCountLabel)
        view.addSubview(memberSectionStackView)

        view.addSubview(collectionView)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        pillStackView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }

        searchContainerView.snp.makeConstraints {
            $0.top.equalTo(pillStackView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }

        searchWavyBackground.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        searchIconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        searchTextField.snp.makeConstraints {
            $0.leading.equalTo(searchIconImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        memberSectionStackView.snp.makeConstraints {
            $0.top.equalTo(searchContainerView.snp.bottom).offset(28)
            $0.leading.equalToSuperview().inset(22)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(memberSectionStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
}
