//
//  MemoryViewController.swift
//  HomePresentation
//
//  Created by 선민재 on 7/28/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import BaseDomain
import DesignSystem

public final class MemoryViewController: UIViewController {
    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let didTapAddMemberButton: PublishRelay<Void> = .init()
    private let didTapManageButton: PublishRelay<Void> = .init()
    private let didTapBuryTicketButton: PublishRelay<Void> = .init()
    private let didTapSeeMessagesButton: PublishRelay<Void> = .init()
    private let disposeBag: DisposeBag = DisposeBag()

    enum MemorySection: Int, CaseIterable {
        case memoryImage
        case memoryDescription
        case buryTicket
        case myMessages
        case members
    }

    private let viewModel: MemoryViewModel
    private let memoriesHeaderViewReuseIdentifier: String = "MyMemoriesCollectionHeaderView"
    private let sectionSpacingReusableViewReuseIdentifier: String = "SectionSpacingReusableView"

    private var currentDetail: TimeCapsuleDetailEntity?
    private var currentCollaborators: [CollaboratorEntity] = []

    // MARK: - Floating Header
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(DesignSystemAsset.ImageAssets.navigationBarBackButton.image, for: .normal)
        button.tintColor = .black
        button.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        button.layer.cornerRadius = 16
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return button
    }()

    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        button.layer.cornerRadius = 16
        return button
    }()

    private var backButtonWavyLayer: WavyStrokeLayer?
    private var menuButtonWavyLayer: WavyStrokeLayer?

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(
            MyMemoriesCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: memoriesHeaderViewReuseIdentifier
        )
        collectionView.register(
            MemorySectionSpacingReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: sectionSpacingReusableViewReuseIdentifier
        )
        collectionView.register(
            MemoryImageCollectionViewCell.self,
            forCellWithReuseIdentifier: MemoryImageCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            MemoryDescriptionCollectionViewCell.self,
            forCellWithReuseIdentifier: MemoryDescriptionCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            BuryTicketCollectionViewCell.self,
            forCellWithReuseIdentifier: BuryTicketCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            MyMessagesCardsCollectionViewCell.self,
            forCellWithReuseIdentifier: MyMessagesCardsCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            MemoryUserCollectionViewCell.self,
            forCellWithReuseIdentifier: MemoryUserCollectionViewCell.reuseIdentifier
        )
        return collectionView
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
        self.setDelegate()

        self.addSubViews()
        self.setLayout()
        self.setupFloatingButtonWavyLayers()
        self.bindViewModel()
        self.bindButtons()

        self.rxViewDidLoad.accept(())
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        syncWavyStrokeLayer(backButtonWavyLayer, to: backButton.bounds)
        syncWavyStrokeLayer(menuButtonWavyLayer, to: menuButton.bounds)
    }

    private func setupFloatingButtonWavyLayers() {
        backButtonWavyLayer = backButton.addWavyStrokeLayer(
            strokeColor: .black,
            lineWidth: 2,
            cornerRadius: 16,
            alignment: .outside
        )
        backButtonWavyLayer?.waveAmplitude = 1.5
        backButtonWavyLayer?.waveSpacing = 8
        backButtonWavyLayer?.setNeedsPathRefresh()

        menuButtonWavyLayer = menuButton.addWavyStrokeLayer(
            strokeColor: .black,
            lineWidth: 2,
            cornerRadius: 16,
            alignment: .outside
        )
        menuButtonWavyLayer?.waveAmplitude = 1.5
        menuButtonWavyLayer?.waveSpacing = 8
        menuButtonWavyLayer?.setNeedsPathRefresh()
    }

    private func syncWavyStrokeLayer(_ layer: WavyStrokeLayer?, to bounds: CGRect) {
        guard let layer else { return }
        if layer.frame != bounds {
            layer.frame = bounds
        }
        layer.setNeedsPathRefresh()
    }

    public init(with viewModel: MemoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension MemoryViewController {
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch MemoryViewController.MemorySection(rawValue: sectionIndex) {
            case .memoryImage:
                return self.getMemoryImageSectionLayout()
            case .memoryDescription:
                return self.getMemoryDescriptionSectionLayout()
            case .buryTicket:
                return self.getBuryTicketSectionLayout()
            case .myMessages:
                return self.getMyMessagesSectionLayout()
            case .members:
                return self.getMembersSectionLayout()
            default:
                return nil
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    private func getMemoryImageSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(420)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        return section
    }

    private func getMemoryDescriptionSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(160)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        return section
    }

    private func getBuryTicketSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 28, trailing: 0)
        return section
    }

    private func getMyMessagesSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(24)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 28, trailing: 20)
        section.interGroupSpacing = 20
        return section
    }

    private func getMembersSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(48),
            heightDimension: .absolute(48)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupWidth: CGFloat = 6 * 48 + 5 * 8
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(groupWidth),
                heightDimension: .absolute(48)
            ),
            repeatingSubitem: item,
            count: 6
        )
        group.interItemSpacing = .fixed(8)
        let section = NSCollectionLayoutSection(group: group)
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(24)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 24, trailing: 20)
        section.interGroupSpacing = 8
        return section
    }
}

// MARK: - Bind
extension MemoryViewController {
    private func bindViewModel() {
        let input = MemoryViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            didTapAddMemberButton: didTapAddMemberButton,
            didTapManageButton: didTapManageButton
        )
        let output = viewModel.transform(input)

        output.detail
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, detail) in
                self.currentDetail = detail
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)

        output.collaborators
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, collaborators) in
                self.currentCollaborators = collaborators
                self.collectionView.reloadSections(IndexSet(integer: MemorySection.members.rawValue))
            })
            .disposed(by: disposeBag)
    }

    private func bindButtons() {
        backButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        menuButton.rx.tap
            .bind(to: didTapManageButton)
            .disposed(by: disposeBag)
    }
}

// MARK: - Subviews
extension MemoryViewController {
    private func setDelegate() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func addSubViews() {
        view.addSubview(collectionView)
        view.addSubview(backButton)
        view.addSubview(menuButton)
    }

    private func setLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(32)
        }

        menuButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(32)
        }
    }
}

// MARK: - DataSource
extension MemoryViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return MemorySection.allCases.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch MemorySection(rawValue: section) {
        case .memoryImage, .memoryDescription, .myMessages:
            return 1
        case .buryTicket:
            return currentDetail?.userRole == .host ? 1 : 0
        case .members:
            return currentCollaborators.count
        default:
            return 0
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch MemorySection(rawValue: indexPath.section) {
        case .memoryImage:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MemoryImageCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? MemoryImageCollectionViewCell else { return .init() }
            cell.configure(imageUrl: currentDetail?.mainImageUrl)
            return cell
        case .memoryDescription:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MemoryDescriptionCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? MemoryDescriptionCollectionViewCell else { return .init() }
            if let detail = currentDetail {
                cell.configure(detail: detail)
            }
            return cell
        case .buryTicket:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BuryTicketCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? BuryTicketCollectionViewCell else { return .init() }
            cell.buryButton.rx.tap
                .bind(to: didTapBuryTicketButton)
                .disposed(by: cell.disposeBag)
            return cell
        case .myMessages:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MyMessagesCardsCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? MyMessagesCardsCollectionViewCell else { return .init() }
            cell.configure(
                contentCount: currentDetail?.myContentCount ?? 0,
                imageCount: currentDetail?.myImageCount ?? 0
            )
            return cell
        case .members:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MemoryUserCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? MemoryUserCollectionViewCell else { return .init() }
            guard indexPath.item < currentCollaborators.count else { return cell }
            cell.configure(profileImageUrl: currentCollaborators[indexPath.item].profileImageUrl)
            return cell
        default:
            return .init()
        }
    }
}

// MARK: - Delegate (supplementary views)
extension MemoryViewController: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch MemorySection(rawValue: indexPath.section) {
        case .myMessages:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: memoriesHeaderViewReuseIdentifier,
                for: indexPath
            ) as? MyMemoriesCollectionHeaderView else { return .init() }
            header.setStatus(.message)
            header.didTapSeeOtherButton
                .withUnretained(self)
                .subscribe(onNext: { (self, _) in
                    self.didTapSeeMessagesButton.accept(())
                })
                .disposed(by: header.disposeBag)
            return header
        case .members:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: memoriesHeaderViewReuseIdentifier,
                for: indexPath
            ) as? MyMemoriesCollectionHeaderView else { return .init() }
            header.setStatus(.member, memberCount: currentCollaborators.count)
            header.didTapSeeOtherButton
                .withUnretained(self)
                .subscribe(onNext: { (self, _) in
                    self.didTapAddMemberButton.accept(())
                })
                .disposed(by: header.disposeBag)
            return header
        default:
            return .init()
        }
    }
}
