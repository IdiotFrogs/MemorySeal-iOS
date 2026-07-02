//
//  ProfileViewController.swift
//  ProfilePresentation
//
//  Created by 선민재 on 7/21/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

import DesignSystem
import BaseDomain

public final class ProfileViewController: UIViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: ProfileViewModel

    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let ticketSelectedRelay: PublishRelay<IndexPath> = .init()

    private var openedTickets: [TimeCapsuleEntity] = []

    private static let openedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd."
        return formatter
    }()

    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("프로필")
        return view
    }()

    private let settingButton: UIButton = {
        let button = UIButton()
        button.setImage(
            DesignSystemAsset.ImageAssets.settingIcon.image,
            for: .normal
        )
        return button
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        return view
    }()

    // MARK: - Profile Header

    private let profileSectionView = UIView()

    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 20)
        label.textAlignment = .center
        return label
    }()

    private let editProfileButton = EditProfileButton()

    // MARK: - Open Ticket Section

    private let openTicketSectionView = UIView()

    private let openTicketTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "오픈된 티켓"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        label.textAlignment = .center
        return label
    }()

    private let ticketDashedSeparator = DashedLineView(
        lineColor: DesignSystemAsset.ColorAssests.grey2.color,
        lineWidth: 2,
        dashPattern: [8, 8]
    )

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 오픈된 티켓이 없어요"
        label.textColor = DesignSystemAsset.ColorAssests.grey3.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var ticketCollectionView: IntrinsicCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        let collectionView = IntrinsicCollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            OpenedTicketCollectionViewCell.self,
            forCellWithReuseIdentifier: OpenedTicketCollectionViewCell.reuseIdentifier
        )
        return collectionView
    }()

    public init(with viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        bindViewModel()
        rxViewDidLoad.accept(())

        addSubviews()
        setLayout()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - Bind

extension ProfileViewController {
    private func bindViewModel() {
        let input = ProfileViewModel.Input(
            viewDidLoad: rxViewDidLoad,
            backButtonDidTap: navigationView.backButtonDidTap,
            editProfileButtonDidTap: editProfileButton.rx.tap,
            settingButtonDidTap: settingButton.rx.tap,
            ticketDidTap: ticketSelectedRelay.asObservable()
        )
        let output = viewModel.translation(input)

        output.userInfo
            .drive(with: self, onNext: { (self, user) in
                guard let user = user else { return }
                self.nickNameLabel.text = user.nickname

                if let url = URL(string: user.profileImageUrl) {
                    self.userProfileImageView.kf.setImage(with: url)
                }
            })
            .disposed(by: disposeBag)

        output.openedTickets
            .drive(with: self, onNext: { (self, tickets) in
                self.openedTickets = tickets
                self.emptyStateLabel.isHidden = !tickets.isEmpty
                self.ticketCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Layout

extension ProfileViewController {
    private func addSubviews() {
        view.addSubview(navigationView)
        navigationView.addButton(settingButton)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(profileSectionView)
        profileSectionView.addSubview(userProfileImageView)
        profileSectionView.addSubview(nickNameLabel)
        profileSectionView.addSubview(editProfileButton)

        contentView.addSubview(openTicketSectionView)
        openTicketSectionView.addSubview(openTicketTitleLabel)
        openTicketSectionView.addSubview(ticketDashedSeparator)
        openTicketSectionView.addSubview(ticketCollectionView)
        openTicketSectionView.addSubview(emptyStateLabel)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.height.equalTo(56)
        }

        settingButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }

        profileSectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        userProfileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(userProfileImageView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        editProfileButton.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }

        openTicketSectionView.snp.makeConstraints {
            $0.top.equalTo(profileSectionView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        openTicketTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
        }

        ticketDashedSeparator.snp.makeConstraints {
            $0.top.equalTo(openTicketTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.height.equalTo(2)
        }

        ticketCollectionView.snp.makeConstraints {
            $0.top.equalTo(ticketDashedSeparator.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }

        emptyStateLabel.snp.makeConstraints {
            $0.top.equalTo(openTicketTitleLabel.snp.bottom).offset(60)
            $0.centerX.equalToSuperview()
        }
    }
}

// MARK: - UICollectionView

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return openedTickets.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OpenedTicketCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? OpenedTicketCollectionViewCell else { return UICollectionViewCell() }

        let ticket = openedTickets[indexPath.item]
        let date = (ticket.openedAt ?? ticket.createdAt).map { Self.openedDateFormatter.string(from: $0) } ?? ""
        cell.configure(
            title: ticket.title,
            date: date
        )

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ticketSelectedRelay.accept(indexPath)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let itemWidth = floor((collectionView.bounds.width - 12) / 2)
        let itemHeight = itemWidth * 1.08
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
