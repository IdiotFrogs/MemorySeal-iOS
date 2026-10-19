//
//  PhotoThumbnailCell.swift
//  TicketPresentation
//
//  Created by 선민재 on 10/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

import DesignSystem

final class PhotoThumbnailCell: UICollectionViewCell {

    private enum Metric {
        static let cornerRadius: CGFloat = 8.0
        static let selectedBorderWidth: CGFloat = 2.0
    }

    // MARK: - UI

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        imageView.layer.cornerRadius = Metric.cornerRadius
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

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.kf.cancelDownloadTask()
        thumbnailImageView.image = nil
        setSelectedState(false)
    }

    // MARK: - Public

    func configure(with urlString: String, isSelected: Bool) {
        if let url = URL(string: urlString) {
            thumbnailImageView.kf.setImage(with: url)
        }
        setSelectedState(isSelected)
    }

    func setSelectedState(_ isSelected: Bool) {
        thumbnailImageView.layer.borderWidth = isSelected ? Metric.selectedBorderWidth : 0
        thumbnailImageView.layer.borderColor = isSelected
            ? DesignSystemAsset.ColorAssests.primaryNormal.color.cgColor
            : UIColor.clear.cgColor
    }
}

// MARK: - Setup

extension PhotoThumbnailCell {
    private func addSubviews() {
        contentView.addSubview(thumbnailImageView)
    }

    private func setLayout() {
        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
