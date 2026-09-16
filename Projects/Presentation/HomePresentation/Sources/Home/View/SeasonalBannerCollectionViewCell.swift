//
//  SeasonalBannerCollectionViewCell.swift
//  HomePresentation
//
//  Created by 선민재 on 9/8/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import SnapKit
import Kingfisher

import DesignSystem
import BaseDomain

final class SeasonalBannerCollectionViewCell: UICollectionViewCell {

    static let identifier: String = String(describing: SeasonalBannerCollectionViewCell.self)

    private enum Layout {
        static let cardCornerRadius: CGFloat = 27
        static let cardStrokeLineWidth: CGFloat = 4
        static let contentInset: CGFloat = 20
        static let headlineTopInset: CGFloat = 20
        static let headlineFontSize: CGFloat = 20
        static let ticketNameTopSpacing: CGFloat = 10
        static let ticketNameFontSize: CGFloat = 16
        static let ticketNameWidth: CGFloat = 210
        static let thumbnailSize: CGFloat = 53
        static let thumbnailCornerRadius: CGFloat = 12
        static let thumbnailStrokeLineWidth: CGFloat = 3
        static let decorationTopInset: CGFloat = 89
        static let decorationTicketWidth: CGFloat = 133.401
        static let decorationTicketHeight: CGFloat = 161.453
        static let decorationTicketLeading: CGFloat = 218
        static let decorationTicketTop: CGFloat = 7
        static let decorationTicketRotation: CGFloat = 16.78
        static let decorationTicketCornerRadius: CGFloat = 8
        static let decorationTicketStrokeLineWidth: CGFloat = 3
        static let decorationTicketHeaderHeight: CGFloat = 41.467
        static let decorationTicketOverlap: CGFloat = 5
    }

    private struct DecorationItem {
        let image: UIImage
        let center: CGPoint
        let rotation: CGFloat
        let isFlipped: Bool

        init(
            image: UIImage,
            center: CGPoint,
            rotation: CGFloat = 0,
            isFlipped: Bool = false
        ) {
            self.image = image
            self.center = center
            self.rotation = rotation
            self.isFlipped = isFlipped
        }

        var transform: CGAffineTransform {
            let rotated = CGAffineTransform(rotationAngle: rotation * .pi / 180)
            return isFlipped ? rotated.scaledBy(x: 1, y: -1) : rotated
        }
    }

    private enum Decoration {
        static let designCardWidth: CGFloat = 335

        static let underTicketItems: [DecorationItem] = [
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerSparkleFill01.image,
                center: CGPoint(x: 178.8648, y: 38.0506),
                rotation: 10.21
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerSparkleOutline01.image,
                center: CGPoint(x: 178.8648, y: 38.0506),
                rotation: 10.21
            )
        ]

        static let overTicketItems: [DecorationItem] = [
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerFlower02.image,
                center: CGPoint(x: 293.9445, y: 117.9001),
                rotation: -4.34
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerLeafMint01.image,
                center: CGPoint(x: 322.5879, y: 68.2450),
                rotation: 180,
                isFlipped: true
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerLeafGreen01.image,
                center: CGPoint(x: 313.7508, y: 80.7699),
                rotation: 41.6
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerLeafMint02.image,
                center: CGPoint(x: 318.5879, y: 76.8422)
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerLeafGreen02.image,
                center: CGPoint(x: 310.5875, y: 91.6448)
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerLeafMint03.image,
                center: CGPoint(x: 31.2364, y: 117.4623),
                rotation: 21.64
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerLeafMint05.image,
                center: CGPoint(x: 50.5211, y: 126.1360),
                rotation: -28.58
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerLeafMint04.image,
                center: CGPoint(x: 186.4873, y: 76.6478),
                rotation: 146.85,
                isFlipped: true
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerFlower01.image,
                center: CGPoint(x: 36.8552, y: 110.7315),
                rotation: 58.92
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerFlower01.image,
                center: CGPoint(x: 328.8553, y: 111.7315),
                rotation: 58.92
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerLeafGreen03.image,
                center: CGPoint(x: 206.1832, y: 120.7341),
                rotation: -120.37,
                isFlipped: true
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerLeafGreen04.image,
                center: CGPoint(x: 219.3889, y: 122.4423),
                rotation: 178.08,
                isFlipped: true
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerLeafMint06.image,
                center: CGPoint(x: 205.8541, y: 106.8907),
                rotation: 174.49,
                isFlipped: true
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerLeafMint07.image,
                center: CGPoint(x: 230.0043, y: 115.4103),
                rotation: 46.31
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerSparkleFill02.image,
                center: CGPoint(x: 331.1337, y: 27.0649),
                rotation: 45.01
            ),
            DecorationItem(
                image: DesignSystemAsset.ImageAssets.bannerSparkleOutline02.image,
                center: CGPoint(x: 331.1337, y: 27.0649),
                rotation: 45.01
            )
        ]

        static let ticketItem: DecorationItem = DecorationItem(
            image: DesignSystemAsset.ImageAssets.bannerFlower03.image,
            center: CGPoint(x: 2.4205, y: 42.8160),
            rotation: -29.66
        )

        static func makeImageView(_ item: DecorationItem) -> UIImageView {
            let imageView = UIImageView(image: item.image)
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = false
            return imageView
        }
    }

    // MARK: - Card

    private let cardView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.backgroundNormal.color,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.cardStrokeLineWidth
        )
        view.waveCornerRadius = Layout.cardCornerRadius
        view.clipsToBounds = true
        return view
    }()

    // MARK: - Decoration

    private let decorationContainerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        return view
    }()

    private let decorationTicketView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    private let decorationTicketBodyView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: .white,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.decorationTicketStrokeLineWidth
        )
        view.waveCornerRadius = Layout.decorationTicketCornerRadius
        return view
    }()

    private let decorationTicketHeaderView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.decorationTicketStrokeLineWidth
        )
        view.waveCornerRadius = Layout.decorationTicketCornerRadius
        return view
    }()

    private let underTicketDecorationViews: [UIImageView] = Decoration.underTicketItems
        .map(Decoration.makeImageView)

    private let overTicketDecorationViews: [UIImageView] = Decoration.overTicketItems
        .map(Decoration.makeImageView)

    private let ticketDecorationView: UIImageView = Decoration.makeImageView(Decoration.ticketItem)

    // MARK: - Text

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: Layout.headlineFontSize)
        label.numberOfLines = 1
        return label
    }()

    private let ticketNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: Layout.ticketNameFontSize)
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Thumbnail

    private let thumbnailView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: .white,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.thumbnailStrokeLineWidth
        )
        view.waveCornerRadius = Layout.thumbnailCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.ticketDummyImage.image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Layout.thumbnailCornerRadius
        return imageView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layoutIfNeeded()
        layoutDecorations()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        thumbnailImageView.kf.cancelDownloadTask()
        thumbnailImageView.image = DesignSystemAsset.ImageAssets.ticketDummyImage.image
    }
}

// MARK: - Configure

extension SeasonalBannerCollectionViewCell {
    func configure(content: String, entity: TimeCapsuleEntity) {
        headlineLabel.text = content
        ticketNameLabel.text = entity.title
        loadImage(from: entity.imageUrl)
    }

    private func loadImage(from urlString: String?) {
        let placeholder = DesignSystemAsset.ImageAssets.ticketDummyImage.image
        guard let urlString, let url = URL(string: urlString) else {
            thumbnailImageView.image = placeholder
            return
        }
        thumbnailImageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.2))]
        )
    }
}

// MARK: - Layout

extension SeasonalBannerCollectionViewCell {
    private func addSubviews() {
        underTicketDecorationViews.forEach { decorationContainerView.addSubview($0) }

        decorationTicketView.addSubview(decorationTicketBodyView)
        decorationTicketView.addSubview(decorationTicketHeaderView)
        decorationTicketView.addSubview(ticketDecorationView)
        decorationContainerView.addSubview(decorationTicketView)

        overTicketDecorationViews.forEach { decorationContainerView.addSubview($0) }

        thumbnailView.addSubview(thumbnailImageView)

        cardView.addSubview(decorationContainerView)
        cardView.addSubview(headlineLabel)
        cardView.addSubview(ticketNameLabel)
        cardView.addSubview(thumbnailView)

        contentView.addSubview(cardView)
    }

    private func setLayout() {
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        decorationContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.decorationTopInset)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        decorationTicketHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview()
                .multipliedBy(Layout.decorationTicketHeaderHeight / Layout.decorationTicketHeight)
        }

        decorationTicketBodyView.snp.makeConstraints {
            $0.top.equalTo(decorationTicketHeaderView.snp.bottom).offset(-Layout.decorationTicketOverlap)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        headlineLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.headlineTopInset)
            $0.leading.equalToSuperview().offset(Layout.contentInset)
            $0.trailing.lessThanOrEqualTo(thumbnailView.snp.leading).offset(-Layout.contentInset)
        }

        ticketNameLabel.snp.makeConstraints {
            $0.top.equalTo(headlineLabel.snp.bottom).offset(Layout.ticketNameTopSpacing)
            $0.leading.equalToSuperview().offset(Layout.contentInset)
            $0.width.lessThanOrEqualTo(Layout.ticketNameWidth)
        }

        thumbnailView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.headlineTopInset)
            $0.trailing.equalToSuperview().inset(Layout.contentInset)
            $0.width.height.equalTo(Layout.thumbnailSize)
        }

        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Layout.thumbnailStrokeLineWidth)
        }
    }
}

// MARK: - Decoration Layout

extension SeasonalBannerCollectionViewCell {
    private func layoutDecorations() {
        let scale = decorationContainerView.bounds.width / Decoration.designCardWidth
        guard scale > 0 else { return }

        layoutDecorationTicket(scale: scale)

        zip(underTicketDecorationViews, Decoration.underTicketItems).forEach { imageView, item in
            place(imageView, item: item, center: containerCenter(of: item, scale: scale), scale: scale)
        }

        zip(overTicketDecorationViews, Decoration.overTicketItems).forEach { imageView, item in
            place(imageView, item: item, center: containerCenter(of: item, scale: scale), scale: scale)
        }

        let ticketItem = Decoration.ticketItem
        place(
            ticketDecorationView,
            item: ticketItem,
            center: CGPoint(x: ticketItem.center.x * scale, y: ticketItem.center.y * scale),
            scale: scale
        )
    }

    private func layoutDecorationTicket(scale: CGFloat) {
        decorationTicketView.transform = .identity
        decorationTicketView.bounds = CGRect(
            origin: .zero,
            size: CGSize(
                width: Layout.decorationTicketWidth * scale,
                height: Layout.decorationTicketHeight * scale
            )
        )
        decorationTicketView.center = CGPoint(
            x: (Layout.decorationTicketLeading + Layout.decorationTicketWidth / 2) * scale,
            y: (Layout.decorationTopInset + Layout.decorationTicketTop + Layout.decorationTicketHeight / 2)
                * scale - Layout.decorationTopInset
        )
        decorationTicketView.transform = CGAffineTransform(
            rotationAngle: Layout.decorationTicketRotation * .pi / 180
        )
        decorationTicketView.layoutIfNeeded()
    }

    private func containerCenter(of item: DecorationItem, scale: CGFloat) -> CGPoint {
        CGPoint(
            x: item.center.x * scale,
            y: (Layout.decorationTopInset + item.center.y) * scale - Layout.decorationTopInset
        )
    }

    private func place(
        _ imageView: UIImageView,
        item: DecorationItem,
        center: CGPoint,
        scale: CGFloat
    ) {
        imageView.transform = .identity
        imageView.bounds = CGRect(
            origin: .zero,
            size: CGSize(
                width: item.image.size.width * scale,
                height: item.image.size.height * scale
            )
        )
        imageView.center = center
        imageView.transform = item.transform
    }
}
