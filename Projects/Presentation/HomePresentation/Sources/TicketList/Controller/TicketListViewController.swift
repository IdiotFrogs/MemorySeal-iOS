//
//  TicketListViewController.swift
//  HomePresentation
//
//  Created by 선민재 on 9/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

import DesignSystem
import BaseDomain

public final class TicketListViewController: UIViewController {
    private let viewModel: TicketListViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let rxViewWillAppear: PublishRelay<Void> = .init()
    private let didReachBottom: PublishRelay<Void> = .init()

    private enum Layout {
        static let navigationHeight: CGFloat = 56
        static let horizontalInset: CGFloat = 20
        static let sectionTopInset: CGFloat = 20
        static let itemSpacing: CGFloat = 16
        static let lineSpacing: CGFloat = 16
        static let columnCount: Int = 2
        static let designCardWidth: CGFloat = 159.5
        static let cardVisualHeight: CGFloat = 214
        static let cardInfoSpacing: CGFloat = 12
        static let cardInfoHeight: CGFloat = 63
        static let prefetchThreshold: Int = 4
    }

    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle(nil)
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPrefetchingEnabled = true
        collectionView.register(
            SectionTicketCollectionViewCell.self,
            forCellWithReuseIdentifier: SectionTicketCollectionViewCell.identifier
        )
        return collectionView
    }()

    public init(with viewModel: TicketListViewModel) {
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
}

// MARK: - Layout

extension TicketListViewController {
    private func setInitialValues() {
        view.backgroundColor = .white
    }

    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider = { (_: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            let contentWidth = containerWidth - Layout.horizontalInset * 2
            let itemWidth = (contentWidth - Layout.itemSpacing) / CGFloat(Layout.columnCount)
            let visualHeight = itemWidth * (Layout.cardVisualHeight / Layout.designCardWidth)
            let itemHeight = visualHeight + Layout.cardInfoSpacing + Layout.cardInfoHeight

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
            section.interGroupSpacing = Layout.lineSpacing
            section.contentInsets = NSDirectionalEdgeInsets(
                top: Layout.sectionTopInset,
                leading: Layout.horizontalInset,
                bottom: Layout.sectionTopInset,
                trailing: Layout.horizontalInset
            )
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    private func addSubviews() {
        view.addSubview(navigationView)
        view.addSubview(collectionView)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.navigationHeight)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

// MARK: - Binding

extension TicketListViewController {
    private func bindViewModel() {
        let input = TicketListViewModel.Input(
            rxViewWillAppear: rxViewWillAppear,
            didTapItem: collectionView.rx.itemSelected,
            didReachBottom: didReachBottom,
            backButtonDidTap: navigationView.backButtonDidTap
        )
        let output = viewModel.translation(input)

        let kind = viewModel.kind

        output.ticketList
            .bind(to: collectionView.rx.items(
                cellIdentifier: SectionTicketCollectionViewCell.identifier,
                cellType: SectionTicketCollectionViewCell.self
            )) { (_, entity, cell) in
                cell.configure(with: entity, kind: kind)
            }
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
    }
}
