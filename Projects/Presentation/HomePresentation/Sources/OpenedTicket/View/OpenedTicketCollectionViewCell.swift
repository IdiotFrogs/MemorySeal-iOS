//
//  OpenedTicketCollectionViewCell.swift
//  HomePresentation
//
//  Created by 선민재 on 9/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import SnapKit
import Kingfisher

import DesignSystem
import BaseDomain

final class OpenedTicketCollectionViewCell: UICollectionViewCell {

    static let identifier: String = String(describing: OpenedTicketCollectionViewCell.self)

    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let strokeLineWidth: CGFloat = 4
        static let designCardWidth: CGFloat = 159.5
        static let lidBoundingHeight: CGFloat = 65.494
        static let lidBandWidth: CGFloat = 150.698
        static let lidBandHeight: CGFloat = 43.441
        static let lidOverlap: CGFloat = 16
        static let lidRotationDegrees: CGFloat = 10.49
        static let contentInset: CGFloat = 12
        static let infoTopSpacing: CGFloat = 12
        static let infoHorizontalInset: CGFloat = 8
        static let infoSpacing: CGFloat = 8
        static let titleHeight: CGFloat = 35
        static let dateHeight: CGFloat = 15
        static let titleFontSize: CGFloat = 16
        static let dateFontSize: CGFloat = 12
        static let dateAlpha: CGFloat = 0.6
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy. MM. dd"
        return formatter
    }()

    // MARK: - Visual Block

    private let visualBlockView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()

    private let lidContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()

    private let lidBandView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: .white,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.strokeLineWidth
        )
        view.waveCornerRadius = Layout.cornerRadius
        return view
    }()

    private let bodyView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: .white,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.strokeLineWidth
        )
        view.waveCornerRadius = Layout.cornerRadius
        return view
    }()

    private let ticketImageView: WavyPhotoView = {
        let imageView = WavyPhotoView(frame: .zero)
        imageView.image = DesignSystemAsset.ImageAssets.ticketDummyImage.image
        return imageView
    }()

    // MARK: - Info

    private let ticketTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: Layout.titleFontSize)
        label.numberOfLines = 2
        return label
    }()

    private let dateRangeLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
            .withAlphaComponent(Layout.dateAlpha)
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: Layout.dateFontSize)
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        lidBandView.transform = CGAffineTransform(
            rotationAngle: Layout.lidRotationDegrees * .pi / 180
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        ticketImageView.imageView.kf.cancelDownloadTask()
        ticketImageView.image = DesignSystemAsset.ImageAssets.ticketDummyImage.image
    }
}

// MARK: - Configure

extension OpenedTicketCollectionViewCell {
    func configure(with entity: TimeCapsuleEntity) {
        ticketTitleLabel.text = entity.title
        dateRangeLabel.text = makeDateRangeText(createdAt: entity.createdAt, openedAt: entity.openedAt)
        loadImage(from: entity.imageUrl)
    }

    private func makeDateRangeText(createdAt: Date?, openedAt: Date?) -> String {
        guard let createdAt else { return "" }

        let createdAtText = Self.dateFormatter.string(from: createdAt)
        guard let openedAt else { return createdAtText }

        let openedAtText = Self.dateFormatter.string(from: openedAt)
        return "\(createdAtText) ~ \(openedAtText)"
    }

    private func loadImage(from urlString: String?) {
        let placeholder = DesignSystemAsset.ImageAssets.ticketDummyImage.image
        guard let urlString, let url = URL(string: urlString) else {
            ticketImageView.image = placeholder
            return
        }
        ticketImageView.imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.2))]
        )
    }
}

// MARK: - Layout

extension OpenedTicketCollectionViewCell {
    private func addSubviews() {
        bodyView.addSubview(ticketImageView)

        lidContainerView.addSubview(lidBandView)

        visualBlockView.addSubview(lidContainerView)
        visualBlockView.addSubview(bodyView)

        contentView.addSubview(visualBlockView)
        contentView.addSubview(ticketTitleLabel)
        contentView.addSubview(dateRangeLabel)
    }

    private func setLayout() {
        visualBlockView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        lidContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(lidContainerView.snp.width)
                .multipliedBy(Layout.lidBoundingHeight / Layout.designCardWidth)
        }

        lidBandView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(lidContainerView.snp.width)
                .multipliedBy(Layout.lidBandWidth / Layout.designCardWidth)
            $0.height.equalTo(lidContainerView.snp.width)
                .multipliedBy(Layout.lidBandHeight / Layout.designCardWidth)
        }

        bodyView.snp.makeConstraints {
            $0.top.equalTo(lidContainerView.snp.bottom).offset(-Layout.lidOverlap)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        ticketImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(ticketImageView.snp.width)
            $0.leading.greaterThanOrEqualToSuperview().offset(Layout.contentInset)
            $0.trailing.lessThanOrEqualToSuperview().inset(Layout.contentInset)
            $0.top.greaterThanOrEqualToSuperview().offset(Layout.contentInset)
            $0.bottom.lessThanOrEqualToSuperview().inset(Layout.contentInset)
            $0.width.equalToSuperview().priority(.low)
        }

        ticketTitleLabel.snp.makeConstraints {
            $0.top.equalTo(visualBlockView.snp.bottom).offset(Layout.infoTopSpacing)
            $0.leading.trailing.equalToSuperview().inset(Layout.infoHorizontalInset)
            $0.height.equalTo(Layout.titleHeight)
        }

        dateRangeLabel.snp.makeConstraints {
            $0.top.equalTo(ticketTitleLabel.snp.bottom).offset(Layout.infoSpacing)
            $0.leading.trailing.equalToSuperview().inset(Layout.infoHorizontalInset)
            $0.height.equalTo(Layout.dateHeight)
            $0.bottom.equalToSuperview()
        }
    }
}
