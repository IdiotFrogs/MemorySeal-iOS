//
//  OpenedTicketViewController.swift
//  HomePresentation
//
//  Created by 선민재 on 9/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem
import BaseDomain

public final class OpenedTicketViewController: UIViewController {
    private let viewModel: OpenedTicketViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let rxViewWillAppear: PublishRelay<Void> = .init()
    private let didReachBottom: PublishRelay<Void> = .init()
    private let didPullToRefresh: PublishRelay<Void> = .init()

    private enum Layout {
        static let itemHorizontalInset: CGFloat = 20
        static let sectionTopInset: CGFloat = 20
        static let itemSpacing: CGFloat = 16
        static let columnCount: Int = 2
        static let prefetchThreshold: Int = 4
        static let interGroupSpacing: CGFloat = 24
        static let visualAspectWidth: CGFloat = 159.5
        static let visualAspectHeight: CGFloat = 216.2
        static let infoTopSpacing: CGFloat = 12
        static let infoBlockHeight: CGFloat = 58
        static let bottomTabBarRowHeight: CGFloat = 80
        static let emptyMessageTop: CGFloat = 242
        static let emptyMessageCornerRadius: CGFloat = 27
        static let emptyMessageVerticalPadding: CGFloat = 34
        static let emptyMessageHorizontalPadding: CGFloat = 44
        static let emptyMessageFontSize: CGFloat = 16
        static let emptyMessageLineSpacing: CGFloat = 4
        static let emptyArrowLeading: CGFloat = 194
        static let emptyArrowTop: CGFloat = 330
        static let emptyArrowWidth: CGFloat = 102
        static let emptyArrowHeight: CGFloat = 239
    }

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPrefetchingEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
        collectionView.register(
            OpenedTicketCollectionViewCell.self,
            forCellWithReuseIdentifier: OpenedTicketCollectionViewCell.identifier
        )
        return collectionView
    }()

    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = DesignSystemAsset.ColorAssests.grey4.color
        return refreshControl
    }()

    private let emptyStateView: UIView = UIView()

    private let messageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        view.layer.cornerRadius = Layout.emptyMessageCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let emptyMessageLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: Layout.emptyMessageFontSize)
        label.textColor = DesignSystemAsset.ColorAssests.grey4.color
        label.numberOfLines = 2
        label.textAlignment = .center
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = Layout.emptyMessageLineSpacing
        label.attributedText = NSAttributedString(
            string: "오픈된 티켓이 없습니다\n버튼을 눌러서 티켓을 추가해 보세요",
            attributes: [.paragraphStyle: paragraphStyle]
        )
        return label
    }()

    private let emptyArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.emptyArrow.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public init(with viewModel: OpenedTicketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.setInitialValues()
        self.addSubviews()
        self.setLayout()
        self.bindViewModel()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.rxViewWillAppear.accept(())
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.contentInset.bottom = Layout.bottomTabBarRowHeight + view.safeAreaInsets.bottom
    }
}

extension OpenedTicketViewController {
    private func setInitialValues() {
        view.backgroundColor = .white
    }
}

extension OpenedTicketViewController {
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider = { [weak self] (_: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard self != nil else { return nil }

            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            let contentWidth = containerWidth - Layout.itemHorizontalInset * 2
            let itemWidth = (contentWidth - Layout.itemSpacing) / CGFloat(Layout.columnCount)
            let visualHeight = itemWidth * (Layout.visualAspectHeight / Layout.visualAspectWidth)
            let itemHeight = visualHeight + Layout.infoTopSpacing + Layout.infoBlockHeight

            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(itemWidth),
                    heightDimension: .absolute(itemHeight)
                )
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(contentWidth),
                    heightDimension: .absolute(itemHeight)
                ),
                repeatingSubitem: item,
                count: Layout.columnCount
            )
            group.interItemSpacing = .fixed(Layout.itemSpacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Layout.interGroupSpacing
            section.contentInsets = NSDirectionalEdgeInsets(
                top: Layout.sectionTopInset,
                leading: Layout.itemHorizontalInset,
                bottom: 0,
                trailing: Layout.itemHorizontalInset
            )
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

extension OpenedTicketViewController {
    private func bindViewModel() {
        let input = OpenedTicketViewModel.Input(
            rxViewWillAppear: rxViewWillAppear,
            didTapItem: collectionView.rx.itemSelected,
            didReachBottom: didReachBottom,
            didPullToRefresh: didPullToRefresh
        )
        let output = viewModel.translation(input)

        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: didPullToRefresh)
            .disposed(by: disposeBag)

        output.isRefreshing
            .observe(on: MainScheduler.instance)
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        collectionView.rx.prefetchItems
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPaths) in
                let itemCount = self.collectionView.numberOfItems(inSection: 0)
                let threshold = itemCount - Layout.prefetchThreshold
                guard indexPaths.contains(where: { $0.item >= threshold }) else { return }
                self.didReachBottom.accept(())
            })
            .disposed(by: disposeBag)

        output.ticketList
            .bind(to: collectionView.rx.items(
                cellIdentifier: OpenedTicketCollectionViewCell.identifier,
                cellType: OpenedTicketCollectionViewCell.self
            )) { (_, entity, cell) in
                cell.configure(with: entity)
            }
            .disposed(by: disposeBag)

        output.ticketList
            .map { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .bind(to: emptyStateView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

extension OpenedTicketViewController {
    private func addSubviews() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(messageContainerView)
        messageContainerView.addSubview(emptyMessageLabel)
        emptyStateView.addSubview(emptyArrowImageView)
    }

    private func setLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        emptyStateView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        messageContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.emptyMessageTop)
            $0.centerX.equalToSuperview()
        }

        emptyMessageLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(
                UIEdgeInsets(
                    top: Layout.emptyMessageVerticalPadding,
                    left: Layout.emptyMessageHorizontalPadding,
                    bottom: Layout.emptyMessageVerticalPadding,
                    right: Layout.emptyMessageHorizontalPadding
                )
            )
        }

        emptyArrowImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.emptyArrowLeading)
            $0.top.equalToSuperview().offset(Layout.emptyArrowTop)
            $0.width.equalTo(Layout.emptyArrowWidth)
            $0.height.equalTo(Layout.emptyArrowHeight)
        }
    }
}
