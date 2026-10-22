//
//  PhotoDetailViewController.swift
//  TicketPresentation
//
//  Created by 선민재 on 10/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class PhotoDetailViewController: UIViewController {

    private enum Metric {
        static let headerHeight: CGFloat = 56.0
        static let closeButtonSize: CGFloat = 24.0
        static let closeButtonTrailing: CGFloat = 20.0
        static let thumbnailSize: CGFloat = 48.0
        static let thumbnailSpacing: CGFloat = 8.0
        static let thumbnailBottomInset: CGFloat = 53.0
        static let thumbnailMinimumSideInset: CGFloat = 20.0
    }

    // MARK: - Properties

    private let imageUrls: [String]
    private let ownerNickname: String
    private let startIndex: Int
    private let disposeBag: DisposeBag = DisposeBag()

    private var currentIndex: Int
    private var hasPerformedInitialScroll: Bool = false
    private let photoTransitioningDelegate: PhotoDetailTransitioningDelegate?

    public var currentPhotoIndex: Int {
        return currentIndex
    }

    private var hasMultiplePhotos: Bool {
        return imageUrls.count > 1
    }

    // MARK: - UI

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.textAlignment = .center
        return label
    }()

    private let counterLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        label.textColor = DesignSystemAsset.ColorAssests.grey3.color
        label.textAlignment = .center
        return label
    }()

    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        button.setImage(
            UIImage(systemName: "xmark", withConfiguration: configuration),
            for: .normal
        )
        button.tintColor = DesignSystemAsset.ColorAssests.grey5.color
        return button
    }()

    private lazy var photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(
            PhotoDetailCell.self,
            forCellWithReuseIdentifier: PhotoDetailCell.reuseIdentifier
        )
        return collectionView
    }()

    private lazy var thumbnailCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Metric.thumbnailSpacing
        layout.minimumInteritemSpacing = Metric.thumbnailSpacing
        layout.itemSize = CGSize(width: Metric.thumbnailSize, height: Metric.thumbnailSize)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(
            PhotoThumbnailCell.self,
            forCellWithReuseIdentifier: PhotoThumbnailCell.reuseIdentifier
        )
        return collectionView
    }()

    // MARK: - Init

    public init(
        imageUrls: [String],
        startIndex: Int,
        ownerNickname: String,
        transitionSource: PhotoDetailTransitionSource? = nil
    ) {
        self.imageUrls = imageUrls
        self.startIndex = min(max(startIndex, 0), max(imageUrls.count - 1, 0))
        self.currentIndex = self.startIndex
        self.ownerNickname = ownerNickname
        self.photoTransitioningDelegate = transitionSource.map { PhotoDetailTransitioningDelegate(source: $0) }
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
        if let photoTransitioningDelegate {
            transitioningDelegate = photoTransitioningDelegate
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setInitialValues()
        addSubviews()
        setLayout()
        bindViewModel()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePhotoItemSize()
        updateThumbnailContentInset()
        performInitialScrollIfNeeded()
    }
}

// MARK: - Setup

extension PhotoDetailViewController {
    private func setInitialValues() {
        view.backgroundColor = .white

        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        thumbnailCollectionView.dataSource = self
        thumbnailCollectionView.delegate = self

        titleStackView.addArrangedSubview(nicknameLabel)
        titleStackView.addArrangedSubview(counterLabel)

        nicknameLabel.text = ownerNickname
        counterLabel.isHidden = !hasMultiplePhotos
        thumbnailCollectionView.isHidden = !hasMultiplePhotos

        updateCounterText()
    }

    private func addSubviews() {
        view.addSubview(titleStackView)
        view.addSubview(closeButton)
        view.addSubview(photoCollectionView)
        view.addSubview(thumbnailCollectionView)
    }

    private func setLayout() {
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(Metric.headerHeight)
        }

        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleStackView)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(Metric.closeButtonTrailing)
            $0.width.height.equalTo(Metric.closeButtonSize)
        }

        thumbnailCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Metric.thumbnailBottomInset)
            $0.height.equalTo(hasMultiplePhotos ? Metric.thumbnailSize : 0)
        }

        photoCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            if hasMultiplePhotos {
                $0.bottom.equalTo(thumbnailCollectionView.snp.top).offset(-Metric.thumbnailSpacing)
            } else {
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
        }
    }

    private func bindViewModel() {
        closeButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Transition Support

extension PhotoDetailViewController {
    private var currentPhotoCell: PhotoDetailCell? {
        return photoCollectionView.cellForItem(
            at: IndexPath(item: currentIndex, section: 0)
        ) as? PhotoDetailCell
    }

    public func currentPhotoImage() -> UIImage? {
        return currentPhotoCell?.displayedImageView.image
    }

    public func currentPhotoFrame(in container: UIView) -> CGRect? {
        guard let imageView = currentPhotoCell?.displayedImageView else { return nil }
        return imageView.convert(imageView.aspectFitImageFrame, to: container)
    }

    public func setPhotoHidden(_ isHidden: Bool) {
        photoCollectionView.alpha = isHidden ? 0 : 1
    }
}

// MARK: - Layout Update

extension PhotoDetailViewController {
    private func updatePhotoItemSize() {
        guard let layout = photoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let size = photoCollectionView.bounds.size
        guard size.width > 0, size.height > 0, layout.itemSize != size else { return }
        layout.itemSize = size
        layout.invalidateLayout()
    }

    private func updateThumbnailContentInset() {
        guard hasMultiplePhotos else { return }
        let width = thumbnailCollectionView.bounds.width
        guard width > 0 else { return }

        let count = CGFloat(imageUrls.count)
        let contentWidth = count * Metric.thumbnailSize + max(count - 1, 0) * Metric.thumbnailSpacing
        let sideInset = max(Metric.thumbnailMinimumSideInset, (width - contentWidth) / 2)

        thumbnailCollectionView.contentInset = UIEdgeInsets(
            top: 0,
            left: sideInset,
            bottom: 0,
            right: sideInset
        )
    }

    private func performInitialScrollIfNeeded() {
        guard !hasPerformedInitialScroll,
              photoCollectionView.bounds.width > 0,
              !imageUrls.isEmpty
        else { return }

        hasPerformedInitialScroll = true

        photoCollectionView.scrollToItem(
            at: IndexPath(item: startIndex, section: 0),
            at: .centeredHorizontally,
            animated: false
        )

        guard hasMultiplePhotos else { return }
        thumbnailCollectionView.scrollToItem(
            at: IndexPath(item: startIndex, section: 0),
            at: .centeredHorizontally,
            animated: false
        )
    }

    private func updateCounterText() {
        counterLabel.text = "\(currentIndex + 1) / \(imageUrls.count)"
    }

    private func updateCurrentIndex(_ index: Int) {
        guard index != currentIndex, imageUrls.indices.contains(index) else { return }
        currentIndex = index
        updateCounterText()
        refreshThumbnailSelection()
    }

    private func refreshThumbnailSelection() {
        guard hasMultiplePhotos else { return }

        thumbnailCollectionView.indexPathsForVisibleItems.forEach { indexPath in
            let cell = thumbnailCollectionView.cellForItem(at: indexPath) as? PhotoThumbnailCell
            cell?.setSelectedState(indexPath.item == currentIndex)
        }

        thumbnailCollectionView.scrollToItem(
            at: IndexPath(item: currentIndex, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
    }
}

// MARK: - UICollectionViewDataSource

extension PhotoDetailViewController: UICollectionViewDataSource {
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return imageUrls.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard imageUrls.indices.contains(indexPath.item) else { return UICollectionViewCell() }
        let urlString = imageUrls[indexPath.item]

        if collectionView === photoCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoDetailCell.reuseIdentifier,
                for: indexPath
            ) as? PhotoDetailCell
            cell?.configure(with: urlString)
            return cell ?? UICollectionViewCell()
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoThumbnailCell.reuseIdentifier,
            for: indexPath
        ) as? PhotoThumbnailCell
        cell?.configure(with: urlString, isSelected: indexPath.item == currentIndex)
        return cell ?? UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate

extension PhotoDetailViewController: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard collectionView === thumbnailCollectionView else { return }

        photoCollectionView.scrollToItem(
            at: IndexPath(item: indexPath.item, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
        updateCurrentIndex(indexPath.item)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard collectionView === photoCollectionView else { return }
        (cell as? PhotoDetailCell)?.resetZoom()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === photoCollectionView else { return }

        let width = photoCollectionView.bounds.width
        guard width > 0 else { return }

        let index = Int((scrollView.contentOffset.x / width).rounded())
        updateCurrentIndex(index)
    }
}
