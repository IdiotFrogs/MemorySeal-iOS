//
//  SectionTicketCollectionViewCell.swift
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

final class SectionTicketCollectionViewCell: UICollectionViewCell {

    static let identifier: String = String(describing: SectionTicketCollectionViewCell.self)

    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let strokeLineWidth: CGFloat = 4
        static let headerHeight: CGFloat = 59
        static let headerVerticalInset: CGFloat = 20
        static let headerHorizontalInset: CGFloat = 12
        static let headerOverlap: CGFloat = 7
        static let contentInset: CGFloat = 12
        static let infoTopSpacing: CGFloat = 12
        static let infoHorizontalInset: CGFloat = 8
        static let infoSpacing: CGFloat = 8
        static let titleHeight: CGFloat = 38
        static let dateHeight: CGFloat = 17
        static let titleFontSize: CGFloat = 16
        static let dateFontSize: CGFloat = 14
        static let dateAlpha: CGFloat = 0.6
        static let badgeCornerRadius: CGFloat = 8
        static let badgeAlpha: CGFloat = 0.6
        static let badgeIconSize: CGFloat = 16
        static let badgeSpacing: CGFloat = 4
        static let badgeVerticalInset: CGFloat = 4
        static let badgeLeadingInset: CGFloat = 6
        static let badgeTrailingInset: CGFloat = 8
        static let badgeFontSize: CGFloat = 12
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy. MM. dd."
        return formatter
    }()

    // MARK: - Visual Block

    private let visualBlockView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()

    private let ticketHeaderView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.strokeLineWidth
        )
        view.waveCornerRadius = Layout.cornerRadius
        return view
    }()

    private let ticketContentView: WavyStrokeView = {
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

    // MARK: - D-day Badge

    private let dDayBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.primaryLight.color
        view.layer.cornerRadius = Layout.badgeCornerRadius
        view.layer.cornerCurve = .continuous
        view.alpha = Layout.badgeAlpha
        view.isHidden = true
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()

    private let dDayIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.shovelFill16.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let dDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: Layout.badgeFontSize)
        return label
    }()

    // MARK: - Info

    private let ticketTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: Layout.titleFontSize)
        label.numberOfLines = 2
        return label
    }()

    private let ticketCreatedAtLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
            .withAlphaComponent(Layout.dateAlpha)
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: Layout.dateFontSize)
        return label
    }()

    // MARK: - Stage Decoration

    private let stageDecorationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = false
        imageView.isHidden = true
        return imageView
    }()

    private var stageDecoration: TicketStageDecoration?

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

        guard let stageDecoration else { return }
        contentView.layoutIfNeeded()
        stageDecorationImageView.frame = stageDecoration.frame(fittingTicketBounds: visualBlockView.frame)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        ticketImageView.imageView.kf.cancelDownloadTask()
        ticketImageView.image = DesignSystemAsset.ImageAssets.ticketDummyImage.image
        stageDecoration = nil
        stageDecorationImageView.image = nil
        stageDecorationImageView.isHidden = true
        dDayBadgeView.isHidden = true
        dDayLabel.text = nil
    }
}

// MARK: - Configure

extension SectionTicketCollectionViewCell {
    func configure(with entity: TimeCapsuleEntity, kind: HomeSectionKind) {
        ticketTitleLabel.text = entity.title
        applyCreatedAt(entity.createdAt)

        switch kind {
        case .upcoming:
            applyDDayBadge(openedAt: entity.openedAt)
            applyStageDecoration(stage: entity.stage)
        case .banner, .timeTicket, .hero:
            dDayBadgeView.isHidden = true
            clearStageDecoration()
        }

        loadImage(from: entity.imageUrl)
    }

    private func applyCreatedAt(_ createdAt: Date?) {
        guard let createdAt else {
            ticketCreatedAtLabel.isHidden = true
            return
        }

        ticketCreatedAtLabel.isHidden = false
        ticketCreatedAtLabel.text = Self.dateFormatter.string(from: createdAt)
    }

    private func applyDDayBadge(openedAt: Date?) {
        guard let openedAt else {
            dDayBadgeView.isHidden = true
            return
        }

        let calendar = Calendar.current
        let remainingDays = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: Date()),
            to: calendar.startOfDay(for: openedAt)
        ).day

        guard let remainingDays, remainingDays >= 0 else {
            dDayBadgeView.isHidden = true
            return
        }

        dDayBadgeView.isHidden = false
        dDayLabel.text = remainingDays == 0 ? "D-DAY" : "D-\(remainingDays)"
    }

    private func applyStageDecoration(stage: Int) {
        stageDecoration = TicketStageDecoration(stage: stage)

        guard let stageDecoration else {
            clearStageDecoration()
            return
        }

        stageDecorationImageView.image = stageDecoration.image
        stageDecorationImageView.isHidden = false
        setNeedsLayout()
    }

    private func clearStageDecoration() {
        stageDecoration = nil
        stageDecorationImageView.image = nil
        stageDecorationImageView.isHidden = true
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

extension SectionTicketCollectionViewCell {
    private func addSubviews() {
        visualBlockView.addSubview(ticketContentView)
        ticketContentView.addSubview(ticketImageView)

        dDayBadgeView.addSubview(dDayIconImageView)
        dDayBadgeView.addSubview(dDayLabel)
        ticketHeaderView.addSubview(dDayBadgeView)
        visualBlockView.addSubview(ticketHeaderView)

        contentView.addSubview(visualBlockView)
        contentView.addSubview(ticketTitleLabel)
        contentView.addSubview(ticketCreatedAtLabel)
        contentView.addSubview(stageDecorationImageView)
    }

    private func setLayout() {
        visualBlockView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        ticketHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.headerHeight)
        }

        dDayBadgeView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.headerVerticalInset)
            $0.leading.equalToSuperview().offset(Layout.headerHorizontalInset)
            $0.trailing.lessThanOrEqualToSuperview().inset(Layout.headerHorizontalInset)
        }

        dDayIconImageView.snp.makeConstraints {
            $0.size.equalTo(Layout.badgeIconSize)
            $0.leading.equalToSuperview().offset(Layout.badgeLeadingInset)
            $0.centerY.equalToSuperview()
        }

        dDayLabel.snp.makeConstraints {
            $0.leading.equalTo(dDayIconImageView.snp.trailing).offset(Layout.badgeSpacing)
            $0.trailing.equalToSuperview().inset(Layout.badgeTrailingInset)
            $0.top.equalToSuperview().offset(Layout.badgeVerticalInset)
            $0.bottom.equalToSuperview().inset(Layout.badgeVerticalInset)
        }

        ticketContentView.snp.makeConstraints {
            $0.top.equalTo(ticketHeaderView.snp.bottom).offset(-Layout.headerOverlap)
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

        ticketCreatedAtLabel.snp.makeConstraints {
            $0.top.equalTo(ticketTitleLabel.snp.bottom).offset(Layout.infoSpacing)
            $0.leading.trailing.equalToSuperview().inset(Layout.infoHorizontalInset)
            $0.height.equalTo(Layout.dateHeight)
            $0.bottom.equalToSuperview()
        }
    }
}
