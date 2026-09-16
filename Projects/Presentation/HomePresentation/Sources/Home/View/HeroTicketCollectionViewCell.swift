//
//  HeroTicketCollectionViewCell.swift
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

final class HeroTicketCollectionViewCell: UICollectionViewCell {

    static let identifier: String = String(describing: HeroTicketCollectionViewCell.self)

    private enum Layout {
        static let cornerRadius: CGFloat = 16
        static let strokeLineWidth: CGFloat = 4
        static let headerInset: CGFloat = 20
        static let headerStackSpacing: CGFloat = 8
        static let headerOverlap: CGFloat = 7
        static let contentInset: CGFloat = 24
        static let titleFontSize: CGFloat = 20
        static let dateFontSize: CGFloat = 14
        static let dateAlpha: CGFloat = 0.6
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy. MM. dd."
        return formatter
    }()

    // MARK: - Header

    private let ticketHeaderView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.strokeLineWidth
        )
        view.waveCornerRadius = Layout.cornerRadius
        return view
    }()

    private let headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Layout.headerStackSpacing
        return stack
    }()

    private let ticketTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: Layout.titleFontSize)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()

    private let ticketCreatedAtLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
            .withAlphaComponent(Layout.dateAlpha)
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: Layout.dateFontSize)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    // MARK: - Content

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
        stageDecorationImageView.frame = stageDecoration.frame(fittingTicketBounds: contentView.bounds)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        ticketImageView.imageView.kf.cancelDownloadTask()
        ticketImageView.image = DesignSystemAsset.ImageAssets.ticketDummyImage.image
        stageDecoration = nil
        stageDecorationImageView.image = nil
        stageDecorationImageView.isHidden = true
    }
}

// MARK: - Configure

extension HeroTicketCollectionViewCell {
    func configure(with entity: TimeCapsuleEntity) {
        ticketTitleLabel.text = entity.title
        applyCreatedAt(entity.openedAt ?? entity.createdAt)
        applyStageDecoration(stage: entity.stage)
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

    private func applyStageDecoration(stage: Int) {
        stageDecoration = TicketStageDecoration(stage: stage)

        guard let stageDecoration else {
            stageDecorationImageView.image = nil
            stageDecorationImageView.isHidden = true
            return
        }

        stageDecorationImageView.image = stageDecoration.image
        stageDecorationImageView.isHidden = false
        setNeedsLayout()
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

extension HeroTicketCollectionViewCell {
    private func addSubviews() {
        contentView.addSubview(ticketContentView)
        ticketContentView.addSubview(ticketImageView)

        headerStackView.addArrangedSubview(ticketTitleLabel)
        headerStackView.addArrangedSubview(ticketCreatedAtLabel)
        ticketHeaderView.addSubview(headerStackView)
        contentView.addSubview(ticketHeaderView)

        contentView.addSubview(stageDecorationImageView)
    }

    private func setLayout() {
        ticketHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        headerStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.headerInset)
            $0.leading.equalToSuperview().offset(Layout.headerInset)
            $0.trailing.equalToSuperview().inset(Layout.headerInset)
            $0.bottom.equalToSuperview().inset(Layout.headerInset)
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
    }
}
