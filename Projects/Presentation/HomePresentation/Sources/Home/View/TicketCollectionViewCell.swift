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
        static let headerHorizontalInset: CGFloat = 24
        static let headerVerticalInset: CGFloat = 20
        static let headerContentSpacing: CGFloat = 12
        static let leftStackSpacing: CGFloat = 6
        static let buriedBadgeCornerRadius: CGFloat = 12
        static let buriedBadgeIconSize: CGFloat = 16
        static let buriedBadgeLeading: CGFloat = 10
        static let buriedBadgeTrailing: CGFloat = 12
        static let buriedBadgeVerticalPadding: CGFloat = 8
        static let buriedBadgeInnerSpacing: CGFloat = 2
        static let activeTitleFontSize: CGFloat = 16
        static let buriedTitleFontSize: CGFloat = 20
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
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: Layout.activeTitleFontSize)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()

    private let ticketCreatedAtLabel: UILabel = {
        let label = UILabel()
        label.text = "2025.05.25"
        label.textColor = DesignSystemAsset.ColorAssests.grey4.color
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

    private let rightStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.setContentHuggingPriority(.required, for: .horizontal)
        stack.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stack
    }()

    // MARK: - Buried Badge

    private let buriedBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        view.layer.cornerRadius = Layout.buriedBadgeCornerRadius
        view.layer.cornerCurve = .continuous
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()

    private let buriedLockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.lockGrey16.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let buriedTextLabel: UILabel = {
        let label = UILabel()
        label.text = "묻어짐"
        label.textColor = DesignSystemAsset.ColorAssests.grey4.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
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
            applyBuriedState()
        case .opened, .beforeBuried:
            applyActiveState(openedAt: entity.openedAt)
        }

        loadImage(from: entity.imageUrl)
    }

    private func applyActiveState(openedAt: Date?) {
        ticketTitleLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: Layout.activeTitleFontSize)
        buriedBadgeView.isHidden = true

        guard let openedAt else {
            endDateLabel.isHidden = true
            ticketCreatedAtLabel.isHidden = true
            return
        }

        endDateLabel.isHidden = false
        ticketCreatedAtLabel.isHidden = false

        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: openedAt)
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
        ticketCreatedAtLabel.text = dateFormatter.string(from: openedAt)
    }

    private func applyBuriedState() {
        ticketTitleLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: Layout.buriedTitleFontSize)

        endDateLabel.isHidden = true
        ticketCreatedAtLabel.isHidden = true
        buriedBadgeView.isHidden = false
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

        leftStackView.addArrangedSubview(endDateLabel)
        leftStackView.addArrangedSubview(ticketTitleLabel)
        ticketHeaderView.addSubview(leftStackView)

        buriedBadgeView.addSubview(buriedLockImageView)
        buriedBadgeView.addSubview(buriedTextLabel)
        rightStackView.addArrangedSubview(ticketCreatedAtLabel)
        rightStackView.addArrangedSubview(buriedBadgeView)
        ticketHeaderView.addSubview(rightStackView)

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
            $0.trailing.lessThanOrEqualTo(rightStackView.snp.leading).offset(-Layout.headerContentSpacing)
        }

        rightStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Layout.headerHorizontalInset)
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
            $0.height.equalTo(ticketContentView.snp.width)
        }

        ticketImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Layout.imageInset)
        }
    }
}
