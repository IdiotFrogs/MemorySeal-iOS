//
//  ProfileViewController.swift
//  ProfilePresentation
//
//  Created by 선민재 on 7/21/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

public final class ProfileViewController: UIViewController {
    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("프로필")
        return view
    }()

    private let settingButton: UIButton = {
        let button = UIButton()
        button.setTitle("설정", for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 14)
        button.setTitleColor(DesignSystemAsset.ColorAssests.grey3.color, for: .normal)
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

    private let profileSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        return view
    }()

    private let profileCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()

    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 27
        imageView.clipsToBounds = true
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        return label
    }()

    private let editProfileButton = EditProfileButton()

    // MARK: - Open Ticket Section

    private let openTicketSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        return view
    }()

    private let openTicketTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "오픈된 티켓"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 20)
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setLayout()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        profileSectionView.addSubview(profileCardView)
        profileCardView.addSubview(userProfileImageView)
        profileCardView.addSubview(nickNameLabel)
        profileCardView.addSubview(editProfileButton)

        contentView.addSubview(openTicketSectionView)
        openTicketSectionView.addSubview(openTicketTitleLabel)
        openTicketSectionView.addSubview(ticketCollectionView)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.height.equalTo(56)
        }

        settingButton.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.width.greaterThanOrEqualTo(24)
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

        profileCardView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }

        userProfileImageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(54)
        }

        nickNameLabel.snp.makeConstraints {
            $0.leading.equalTo(userProfileImageView.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
        }

        editProfileButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        // Open Ticket Section
        openTicketSectionView.snp.makeConstraints {
            $0.top.equalTo(profileSectionView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        openTicketTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(20)
        }

        ticketCollectionView.snp.makeConstraints {
            $0.top.equalTo(openTicketTitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
}

// MARK: - UICollectionView

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OpenedTicketCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? OpenedTicketCollectionViewCell else { return UICollectionViewCell() }
        
        cell.configure(title: "제목입니다.", date: "2027. 10. 24.")
        
        return cell
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let itemWidth = floor((collectionView.bounds.width - 12) / 2)
        let imageSize = itemWidth - 24
        let itemHeight = 16 + imageSize + 6 + 20 + 4 + 15 + 16
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
