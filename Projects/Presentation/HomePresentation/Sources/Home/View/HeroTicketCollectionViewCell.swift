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

    private enum Decoration {
        static let designCardWidth: CGFloat = 317

        static let light: TicketDecorationItem = TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLight.image,
            size: CGSize(width: 354.6, height: 324.6),
            center: CGPoint(x: 160, y: 90)
        )

        static let vineItems: [TicketDecorationItem] = [
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf18.image,
            size: CGSize(width: 19.667, height: 10.131),
            center: CGPoint(x: 16.54, y: 354.36),
            rotation: 0.0,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf17.image,
            size: CGSize(width: 25.926, height: 13.385),
            center: CGPoint(x: 34.75, y: 349.14),
            rotation: 0.0,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf16.image,
            size: CGSize(width: 30.275, height: 15.44),
            center: CGPoint(x: 28.88, y: 289.81),
            rotation: -53.7,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf08.image,
            size: CGSize(width: 27.276, height: 14.054),
            center: CGPoint(x: 288.7, y: 285.74),
            rotation: 53.7,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf15.image,
            size: CGSize(width: 25.936, height: 13.39),
            center: CGPoint(x: 14.21, y: 300.27),
            rotation: 7.36,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf07.image,
            size: CGSize(width: 23.762, height: 12.165),
            center: CGPoint(x: 302.12, y: 295.31),
            rotation: -7.36,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf06.image,
            size: CGSize(width: 24.518, height: 12.404),
            center: CGPoint(x: 304.87, y: 331.28),
            rotation: 21.65,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf14.image,
            size: CGSize(width: 24.518, height: 12.404),
            center: CGPoint(x: 270.64, y: 370.02),
            rotation: -46.67,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf14.image,
            size: CGSize(width: 24.518, height: 12.404),
            center: CGPoint(x: 31.11, y: 370.02),
            rotation: -46.67,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf05.image,
            size: CGSize(width: 24.254, height: 12.362),
            center: CGPoint(x: 300.16, y: 339.26),
            rotation: 52.08,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf04.image,
            size: CGSize(width: 24.254, height: 12.362),
            center: CGPoint(x: 278.28, y: 375.27),
            rotation: -77.1,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf13.image,
            size: CGSize(width: 27.944, height: 14.282),
            center: CGPoint(x: 113.61, y: 355.13),
            rotation: -61.13,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf03.image,
            size: CGSize(width: 20.652, height: 10.335),
            center: CGPoint(x: 300.13, y: 357.87),
            rotation: 52.08,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf03.image,
            size: CGSize(width: 20.652, height: 10.335),
            center: CGPoint(x: 291.95, y: 370.15),
            rotation: 52.08,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf12.image,
            size: CGSize(width: 26.748, height: 13.748),
            center: CGPoint(x: 57.25, y: 369.43),
            rotation: 37.37,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf11.image,
            size: CGSize(width: 25.936, height: 13.39),
            center: CGPoint(x: 15.46, y: 331.41),
            rotation: -63.02,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf10.image,
            size: CGSize(width: 30.877, height: 15.772),
            center: CGPoint(x: 47.89, y: 376.42),
            rotation: 77.1,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf08.image,
            size: CGSize(width: 27.276, height: 14.054),
            center: CGPoint(x: 288.7, y: 166.4),
            rotation: 53.7,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf09.image,
            size: CGSize(width: 27.276, height: 14.054),
            center: CGPoint(x: 11.26, y: 168.25),
            rotation: -6.89,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf08.image,
            size: CGSize(width: 27.276, height: 14.054),
            center: CGPoint(x: 18.94, y: 125.49),
            rotation: 53.7,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf07.image,
            size: CGSize(width: 23.762, height: 12.166),
            center: CGPoint(x: 302.12, y: 175.93),
            rotation: -7.36,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf07.image,
            size: CGSize(width: 23.762, height: 12.166),
            center: CGPoint(x: 295.59, y: 96.29),
            rotation: -7.36,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf07.image,
            size: CGSize(width: 23.762, height: 12.166),
            center: CGPoint(x: 32.35, y: 135.06),
            rotation: -7.36,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf06.image,
            size: CGSize(width: 24.518, height: 12.404),
            center: CGPoint(x: 35.11, y: 171.03),
            rotation: 21.65,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf05.image,
            size: CGSize(width: 24.254, height: 12.361),
            center: CGPoint(x: 30.4, y: 179.05),
            rotation: 52.08,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf04.image,
            size: CGSize(width: 24.254, height: 12.362),
            center: CGPoint(x: 279.61, y: 107.34),
            rotation: -77.1,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf04.image,
            size: CGSize(width: 24.254, height: 12.362),
            center: CGPoint(x: 16.38, y: 146.11),
            rotation: -77.1,
            isMirroredX: true,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf03.image,
            size: CGSize(width: 20.652, height: 10.335),
            center: CGPoint(x: 299.3, y: 269.22),
            rotation: 52.08,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf02.image,
            size: CGSize(width: 28.064, height: 14.335),
            center: CGPoint(x: 305.33, y: 144.13),
            rotation: 28.28,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf02.image,
            size: CGSize(width: 28.064, height: 14.335),
            center: CGPoint(x: 297.95, y: 107.0),
            rotation: 28.28,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroLeaf01.image,
            size: CGSize(width: 28.064, height: 14.335),
            center: CGPoint(x: 304.53, y: 149.5),
            rotation: 52.4,
            isMirroredX: false,
            isMirroredY: false
        )
        ]
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy. MM. dd."
        return formatter
    }()

    // MARK: - Header

    private let lightImageView: UIImageView = {
        let imageView = UIImageView(image: DesignSystemAsset.ImageAssets.heroLight.image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private let vineContainerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.clipsToBounds = false
        return view
    }()

    private lazy var vineImageViews: [UIImageView] = Decoration.vineItems.map { $0.makeImageView() }

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

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
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

        applyDecorations()

    }

    override func prepareForReuse() {
        super.prepareForReuse()

        ticketImageView.imageView.kf.cancelDownloadTask()
        ticketImageView.image = DesignSystemAsset.ImageAssets.ticketDummyImage.image
    }
}

// MARK: - Configure

extension HeroTicketCollectionViewCell {
    func configure(with entity: TimeCapsuleEntity) {
        ticketTitleLabel.text = entity.title
        applyCreatedAt(entity.openedAt ?? entity.createdAt)
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
    private func applyDecorations() {
        let scale = contentView.bounds.width / Decoration.designCardWidth
        guard scale > 0 else { return }

        Decoration.light.apply(to: lightImageView, scale: scale)

        zip(vineImageViews, Decoration.vineItems).forEach { imageView, item in
            item.apply(to: imageView, scale: scale)
        }
    }

    private func addSubviews() {
        contentView.addSubview(lightImageView)
        contentView.addSubview(ticketContentView)
        ticketContentView.addSubview(ticketImageView)

        headerStackView.addArrangedSubview(ticketTitleLabel)
        headerStackView.addArrangedSubview(ticketCreatedAtLabel)
        ticketHeaderView.addSubview(headerStackView)
        contentView.addSubview(ticketHeaderView)

        vineImageViews.forEach { vineContainerView.addSubview($0) }
        contentView.addSubview(vineContainerView)
    }

    private func setLayout() {
        vineContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

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
