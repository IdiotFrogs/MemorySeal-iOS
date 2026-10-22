//
//  PhotoDetailCell.swift
//  TicketPresentation
//
//  Created by 선민재 on 10/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

final class PhotoDetailCell: UICollectionViewCell {

    private enum Metric {
        static let maximumZoomScale: CGFloat = 5.0
        static let minimumZoomScale: CGFloat = 1.0
    }

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.maximumZoomScale = Metric.maximumZoomScale
        scrollView.minimumZoomScale = Metric.minimumZoomScale
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bouncesZoom = true
        return scrollView
    }()

    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    var displayedImageView: UIImageView {
        return photoImageView
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setInitialValues()
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.kf.cancelDownloadTask()
        photoImageView.image = nil
        resetZoom()
    }

    // MARK: - Public

    func configure(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        photoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
    }

    func resetZoom() {
        scrollView.setZoomScale(Metric.minimumZoomScale, animated: false)
    }
}

// MARK: - Setup

extension PhotoDetailCell {
    private func setInitialValues() {
        contentView.backgroundColor = .white
        scrollView.delegate = self
    }

    private func addSubviews() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(photoImageView)
    }

    private func setLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        photoImageView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.equalTo(scrollView.frameLayoutGuide)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PhotoDetailCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
}
