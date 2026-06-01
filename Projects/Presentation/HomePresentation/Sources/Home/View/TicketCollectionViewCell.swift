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
        static let headerHorizontalInset: CGFloat = 20
        static let headerVerticalInset: CGFloat = 20
        static let leftStackSpacing: CGFloat = 8
        static let buriedBadgeCornerRadius: CGFloat = 12
        static let buriedBadgeIconSize: CGFloat = 16
        static let buriedBadgeLeading: CGFloat = 6
        static let buriedBadgeTrailing: CGFloat = 8
        static let buriedBadgeVerticalPadding: CGFloat = 6
        static let buriedBadgeInnerSpacing: CGFloat = 4
        static let contentFixedHeight: CGFloat = 328
        static let activeTitleFontSize: CGFloat = 24
        static let buriedTitleFontSize: CGFloat = 24
        static let buriedBadgeAlpha: CGFloat = 0.6
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

    private let ticketTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목입니다."
        label.textColor = .black
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: Layout.activeTitleFontSize)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()

    private let ticketCreatedAtLabel: UILabel = {
        let label = UILabel()
        label.text = "2025. 05. 25."
        label.textColor = DesignSystemAsset.ColorAssests.grey4.color.withAlphaComponent(0.6)
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let leftStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Layout.leftStackSpacing
        return stack
    }()

    // MARK: - Buried Badge

    private let buriedBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#CFF2D8")
        view.layer.cornerRadius = Layout.buriedBadgeCornerRadius
        view.layer.cornerCurve = .continuous
        view.alpha = Layout.buriedBadgeAlpha
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()

    private let buriedLockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.shovelFill16.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let buriedTextLabel: UILabel = {
        let label = UILabel()
        label.text = "묻어짐"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 12)
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

        switch entity.timeCapsuleStatus {
        case .buried:
            applyBuriedState(createdAt: entity.createdAt)
        case .opened, .beforeBuried:
            applyActiveState(createdAt: entity.createdAt)
        }

        loadImage(from: entity.imageUrl)
    }

    private func applyActiveState(createdAt: Date?) {
        ticketTitleLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: Layout.activeTitleFontSize)
        buriedBadgeView.isHidden = true

        guard let createdAt else {
            ticketCreatedAtLabel.isHidden = true
            return
        }

        ticketCreatedAtLabel.isHidden = false

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd."
        ticketCreatedAtLabel.text = dateFormatter.string(from: createdAt)
    }

    private func applyBuriedState(createdAt: Date?) {
        ticketTitleLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: Layout.buriedTitleFontSize)
        buriedBadgeView.isHidden = false

        guard let createdAt else {
            ticketCreatedAtLabel.isHidden = true
            return
        }

        ticketCreatedAtLabel.isHidden = false

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd."
        ticketCreatedAtLabel.text = dateFormatter.string(from: createdAt)
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

        buriedBadgeView.addSubview(buriedLockImageView)
        buriedBadgeView.addSubview(buriedTextLabel)

        leftStackView.addArrangedSubview(buriedBadgeView)
        leftStackView.addArrangedSubview(ticketTitleLabel)
        leftStackView.addArrangedSubview(ticketCreatedAtLabel)
        ticketHeaderView.addSubview(leftStackView)

        contentView.addSubview(ticketContentView)
        ticketContentView.addSubview(ticketImageView)
    }

    private func setLayout() {
        ticketHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        leftStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.headerVerticalInset)
            $0.leading.equalToSuperview().offset(Layout.headerHorizontalInset)
            $0.bottom.equalToSuperview().inset(Layout.headerVerticalInset)
            $0.trailing.lessThanOrEqualToSuperview().inset(Layout.headerHorizontalInset)
        }

        buriedLockImageView.snp.makeConstraints {
            $0.size.equalTo(Layout.buriedBadgeIconSize)
            $0.leading.equalToSuperview().offset(Layout.buriedBadgeLeading)
            $0.centerY.equalToSuperview()
        }

        buriedTextLabel.snp.makeConstraints {
            $0.leading.equalTo(buriedLockImageView.snp.trailing).offset(Layout.buriedBadgeInnerSpacing)
            $0.trailing.equalToSuperview().inset(Layout.buriedBadgeTrailing)
            $0.top.equalToSuperview().offset(Layout.buriedBadgeVerticalPadding)
            $0.bottom.equalToSuperview().inset(Layout.buriedBadgeVerticalPadding)
        }

        ticketContentView.snp.makeConstraints {
            $0.top.equalTo(ticketHeaderView.snp.bottom).offset(-7)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(Layout.contentFixedHeight)
        }

        ticketImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Layout.imageInset)
        }
    }
}
