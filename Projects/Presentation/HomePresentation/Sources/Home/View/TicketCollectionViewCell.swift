//
//  TicketCollectionViewCell.swift
//  HomePresentation
//
//  Created by 선민재 on 5/26/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

import DesignSystem
import BaseDomain

final class TicketCollectionViewCell: UICollectionViewCell {

    private enum Layout {
        static let cornerRadius: CGFloat = 16
        static let strokeLineWidth: CGFloat = 4
        static let imageInset: CGFloat = 24
        static let imageCornerRadius: CGFloat = 12
    }

    // MARK: - Header (top)

    private let ticketHeaderView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.strokeLineWidth
        )
        view.waveCornerRadius = Layout.cornerRadius
        return view
    }()

    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "D-5"
        label.textColor = .black
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 28)
        return label
    }()

    private let ticketTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목입니다."
        label.textColor = .black
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        return label
    }()

    private let ticketCreatedAtLabel: UILabel = {
        let label = UILabel()
        label.text = "2025.05.25"
        label.textColor = DesignSystemAsset.ColorAssests.grey4.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        return label
    }()

    // MARK: - Content (bottom, image)

    private let ticketContentView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: .white,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.strokeLineWidth
        )
        view.waveCornerRadius = Layout.cornerRadius
        return view
    }()

    private let ticketImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.ticketDummyImage.image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Layout.imageCornerRadius
        imageView.layer.cornerCurve = .continuous
        return imageView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ticketImageView.kf.cancelDownloadTask()
        ticketImageView.image = DesignSystemAsset.ImageAssets.ticketDummyImage.image
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetWidth = (superview as? UICollectionView)?.bounds.width ?? layoutAttributes.size.width
        attrs.size.width = targetWidth
        let height = contentView.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        attrs.size.height = height
        return attrs
    }

}

// MARK: - Configure

extension TicketCollectionViewCell {
    func configure(with entity: TimeCapsuleEntity) {
        ticketTitleLabel.text = entity.title

        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: entity.openedAt)
        let days = calendar.dateComponents([.day], from: now, to: target).day ?? 0

        if days > 0 {
            endDateLabel.text = "D-\(days)"
        } else if days == 0 {
            endDateLabel.text = "D-Day"
        } else {
            endDateLabel.text = "D+\(abs(days))"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        ticketCreatedAtLabel.text = dateFormatter.string(from: entity.openedAt)

        loadImage(from: entity.imageUrl)
    }

    private func loadImage(from urlString: String?) {
        let placeholder = DesignSystemAsset.ImageAssets.ticketDummyImage.image
        guard let urlString, let url = URL(string: urlString) else {
            ticketImageView.image = placeholder
            return
        }
        ticketImageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.2))]
        )
    }
}

// MARK: - Layout

extension TicketCollectionViewCell {
    private func addSubviews() {
        contentView.addSubview(ticketHeaderView)
        ticketHeaderView.addSubview(endDateLabel)
        ticketHeaderView.addSubview(ticketTitleLabel)
        ticketHeaderView.addSubview(ticketCreatedAtLabel)

        contentView.addSubview(ticketContentView)
        ticketContentView.addSubview(ticketImageView)
    }

    private func setLayout() {
        ticketHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(110)
        }

        endDateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(24)
        }

        ticketTitleLabel.snp.makeConstraints {
            $0.top.equalTo(endDateLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(24)
        }

        ticketCreatedAtLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(24)
        }

        ticketContentView.snp.makeConstraints {
            $0.top.equalTo(ticketHeaderView.snp.bottom).offset(-7)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(ticketContentView.snp.width)
        }

        ticketImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Layout.imageInset)
        }
    }
}
