//
//  HomeViewController.swift
//  HomePresentation
//
//  Created by 선민재 on 5/19/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem
import BaseDomain

public final class HomeViewController: UIViewController {

    private enum Layout {
        static let bottomTabBarRowHeight: CGFloat = 80

        static let heroMaxWidth: CGFloat = 317
        static let bannerAspectRatio: CGFloat = 213.0 / 335.0
        static let bannerSectionTopInset: CGFloat = 20
        static let bannerSectionBottomInset: CGFloat = 39
        static let heroHorizontalMargin: CGFloat = 58
        static let heroAspectRatio: CGFloat = 390.0 / 317.0
        static let heroInterGroupSpacing: CGFloat = 29
        static let heroPeekAlpha: CGFloat = 0.12
        static let heroPeekRotationDegrees: CGFloat = 15
        static let heroPeekVerticalOffset: CGFloat = 22.378
        static let heroSectionBottomInset: CGFloat = 48

        static let sectionHorizontalInset: CGFloat = 20
        static let sectionInterItemSpacing: CGFloat = 12
        static let sectionInterGroupSpacing: CGFloat = 12
        static let sectionColumnCount: Int = 2
        static let sectionCardAspectRatio: CGFloat = 214.0 / 161.5
        static let sectionCardInfoSpacing: CGFloat = 12
        static let sectionCardInfoHeight: CGFloat = 63
        static let timeTicketHeaderBottomInset: CGFloat = 19
        static let timeTicketSectionBottomInset: CGFloat = 39
        static let upcomingHeaderBottomInset: CGFloat = 16
        static let upcomingSectionBottomInset: CGFloat = 0

        static let emptyMessageTopOffset: CGFloat = 242
        static let emptyMessageCornerRadius: CGFloat = 27
        static let emptyMessageVerticalInset: CGFloat = 34
        static let emptyMessageHorizontalInset: CGFloat = 44
        static let emptyMessageFontSize: CGFloat = 16
        static let emptyMessageLineSpacing: CGFloat = 4
        static let emptyArrowLeadingOffset: CGFloat = 194
        static let emptyArrowTopOffset: CGFloat = 330
        static let emptyArrowWidth: CGFloat = 102
        static let emptyArrowHeight: CGFloat = 239
    }

    private enum Text {
        static let emptyMessage: String = "생성한 티켓이 없습니다\n버튼을 눌러서 티켓을 추가해 보세요"
    }

    private let viewModel: HomeViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let rxViewWillAppear: PublishRelay<Void> = .init()
    private let didTapSeeAll: PublishRelay<HomeSectionKind> = .init()

    private var sections: [HomeSectionModel] = []

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()

    // MARK: - Empty State

    private let emptyStateView = UIView()

    private let emptyMessageContainerView: UIView = {
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
            string: Text.emptyMessage,
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

    public init(with viewModel: HomeViewModel) {
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

// MARK: - Binding

extension HomeViewController {
    private func bindViewModel() {
        let input = HomeViewModel.Input(
            rxViewWillAppear: rxViewWillAppear,
            didTapItem: collectionView.rx.itemSelected,
            didTapSeeAll: didTapSeeAll
        )
        let output = viewModel.translation(input)

        output.sections
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, sections) in
                self.sections = sections
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)

        output.sections
            .map { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .bind(to: emptyStateView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

// MARK: - Subviews

extension HomeViewController {
    private func setInitialValues() {
        view.backgroundColor = .white

        collectionView.dataSource = self
        collectionView.register(
            SeasonalBannerCollectionViewCell.self,
            forCellWithReuseIdentifier: SeasonalBannerCollectionViewCell.identifier
        )
        collectionView.register(
            HeroTicketCollectionViewCell.self,
            forCellWithReuseIdentifier: HeroTicketCollectionViewCell.identifier
        )
        collectionView.register(
            SectionTicketCollectionViewCell.self,
            forCellWithReuseIdentifier: SectionTicketCollectionViewCell.identifier
        )
        collectionView.register(
            HomeCalloutHeaderView.self,
            forSupplementaryViewOfKind: HomeCalloutHeaderView.elementKind,
            withReuseIdentifier: HomeCalloutHeaderView.identifier
        )
        collectionView.register(
            HomeSectionHeaderView.self,
            forSupplementaryViewOfKind: HomeSectionHeaderView.elementKind,
            withReuseIdentifier: HomeSectionHeaderView.identifier
        )
    }

    private func addSubviews() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyMessageContainerView)
        emptyMessageContainerView.addSubview(emptyMessageLabel)
        emptyStateView.addSubview(emptyArrowImageView)
    }

    private func setLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        emptyStateView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        emptyMessageContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.emptyMessageTopOffset)
            $0.centerX.equalToSuperview()
        }

        emptyMessageLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(Layout.emptyMessageVerticalInset)
            $0.leading.trailing.equalToSuperview().inset(Layout.emptyMessageHorizontalInset)
        }

        emptyArrowImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.emptyArrowLeadingOffset)
            $0.top.equalToSuperview().offset(Layout.emptyArrowTopOffset)
            $0.width.equalTo(Layout.emptyArrowWidth)
            $0.height.equalTo(Layout.emptyArrowHeight)
        }
    }
}

// MARK: - Layout

extension HomeViewController {
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider = { [weak self] (
            sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment
        ) -> NSCollectionLayoutSection? in
            guard let self else { return nil }
            guard sectionIndex < self.sections.count else { return nil }

            let containerWidth = layoutEnvironment.container.effectiveContentSize.width

            switch self.sections[sectionIndex].kind {
            case .banner:
                return self.makeBannerSectionLayout(containerWidth: containerWidth)
            case .hero:
                return self.makeHeroSectionLayout(containerWidth: containerWidth)
            case .timeTicket:
                return self.makeTicketSectionLayout(
                    containerWidth: containerWidth,
                    headerBottomInset: Layout.timeTicketHeaderBottomInset,
                    sectionBottomInset: Layout.timeTicketSectionBottomInset
                )
            case .upcoming:
                return self.makeTicketSectionLayout(
                    containerWidth: containerWidth,
                    headerBottomInset: Layout.upcomingHeaderBottomInset,
                    sectionBottomInset: Layout.upcomingSectionBottomInset
                )
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    private func makeBannerSectionLayout(containerWidth: CGFloat) -> NSCollectionLayoutSection {
        let bannerWidth = containerWidth - Layout.sectionHorizontalInset * 2
        let bannerSize = NSCollectionLayoutSize(
            widthDimension: .absolute(bannerWidth),
            heightDimension: .absolute(bannerWidth * Layout.bannerAspectRatio)
        )

        let item = NSCollectionLayoutItem(layoutSize: bannerSize)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: bannerSize,
            repeatingSubitem: item,
            count: 1
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Layout.bannerSectionTopInset,
            leading: Layout.sectionHorizontalInset,
            bottom: Layout.bannerSectionBottomInset,
            trailing: Layout.sectionHorizontalInset
        )

        return section
    }

    private func makeHeroSectionLayout(containerWidth: CGFloat) -> NSCollectionLayoutSection {
        let heroWidth = min(Layout.heroMaxWidth, containerWidth - Layout.heroHorizontalMargin)
        let heroHeight = heroWidth * Layout.heroAspectRatio
        let heroSize = NSCollectionLayoutSize(
            widthDimension: .absolute(heroWidth),
            heightDimension: .absolute(heroHeight)
        )

        let item = NSCollectionLayoutItem(layoutSize: heroSize)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: heroSize,
            repeatingSubitem: item,
            count: 1
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = Layout.heroInterGroupSpacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: Layout.heroSectionBottomInset,
            trailing: 0
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(HomeCalloutHeaderView.height)
            ),
            elementKind: HomeCalloutHeaderView.elementKind,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        section.visibleItemsInvalidationHandler = { items, offset, environment in
            let centerX = offset.x + environment.container.contentSize.width / 2
            let span = heroWidth + Layout.heroInterGroupSpacing

            items.filter { $0.representedElementCategory == .cell }
                .forEach { item in
                    let distance = item.frame.midX - centerX
                    let progress = min(abs(distance) / span, 1)
                    let direction: CGFloat = distance < 0 ? -1 : 1
                    let angle = Layout.heroPeekRotationDegrees * .pi / 180 * progress * direction

                    item.alpha = 1 - (1 - Layout.heroPeekAlpha) * progress
                    item.zIndex = Int((1 - progress) * 1000)
                    item.transform = CGAffineTransform(
                        translationX: 0,
                        y: Layout.heroPeekVerticalOffset * progress
                    ).rotated(by: angle)
                }
        }

        return section
    }

    private func makeTicketSectionLayout(
        containerWidth: CGFloat,
        headerBottomInset: CGFloat,
        sectionBottomInset: CGFloat
    ) -> NSCollectionLayoutSection {
        let contentWidth = containerWidth - Layout.sectionHorizontalInset * 2
        let itemWidth = (contentWidth - Layout.sectionInterItemSpacing)
            / CGFloat(Layout.sectionColumnCount)
        let visualHeight = itemWidth * Layout.sectionCardAspectRatio
        let itemHeight = visualHeight + Layout.sectionCardInfoSpacing + Layout.sectionCardInfoHeight

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
            count: Layout.sectionColumnCount
        )
        group.interItemSpacing = .fixed(Layout.sectionInterItemSpacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Layout.sectionInterGroupSpacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Layout.sectionHorizontalInset,
            bottom: sectionBottomInset,
            trailing: Layout.sectionHorizontalInset
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(HomeSectionHeaderView.contentHeight + headerBottomInset)
            ),
            elementKind: HomeSectionHeaderView.elementKind,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        section.supplementariesFollowContentInsets = false

        return section
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard section < sections.count else { return 0 }
        return sections[section].items.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard indexPath.section < sections.count else { return .init() }
        let section = sections[indexPath.section]
        guard indexPath.item < section.items.count else { return .init() }
        let entity = section.items[indexPath.item]

        switch section.kind {
        case .banner:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SeasonalBannerCollectionViewCell.identifier,
                for: indexPath
            ) as? SeasonalBannerCollectionViewCell else { return .init() }
            cell.configure(content: section.title ?? "", entity: entity)
            return cell
        case .hero:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HeroTicketCollectionViewCell.identifier,
                for: indexPath
            ) as? HeroTicketCollectionViewCell else { return .init() }
            cell.configure(with: entity)
            return cell
        case .timeTicket, .upcoming:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SectionTicketCollectionViewCell.identifier,
                for: indexPath
            ) as? SectionTicketCollectionViewCell else { return .init() }
            cell.configure(with: entity, kind: section.kind)
            return cell
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              indexPath.section < sections.count else { return .init() }
        let section = sections[indexPath.section]

        switch section.kind {
        case .banner:
            return .init()
        case .hero:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HomeCalloutHeaderView.identifier,
                for: indexPath
            ) as? HomeCalloutHeaderView else { return .init() }
            return header
        case .timeTicket, .upcoming:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HomeSectionHeaderView.identifier,
                for: indexPath
            ) as? HomeSectionHeaderView else { return .init() }
            let sectionKind = section.kind
            header.configure(
                title: section.title ?? "",
                showsMore: section.showsMore,
                onTapMore: { [weak self] in
                    self?.didTapSeeAll.accept(sectionKind)
                }
            )
            return header
        }
    }
}
