//
//  TicketDetailViewController.swift
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
import TicketDomain

public final class TicketDetailViewController: UIViewController {
    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let didTapAddMemberButton: PublishRelay<Void> = .init()
    private let didTapManageButton: PublishRelay<Void> = .init()
    private let didTapBuryTicketButton: PublishRelay<Void> = .init()
    private let didTapSeeMessagesButton: PublishRelay<Void> = .init()
    private let disposeBag: DisposeBag = DisposeBag()

    enum TicketDetailSection: Int, CaseIterable {
        case ticketImage
        case ticketDescription
        case buryTicket
        case myMessages
        case members
    }

    private let viewModel: TicketDetailViewModel
    private var ticketDetail: TicketDetailEntity?
    private var collaborators: [CollaboratorEntity] = []
    private let myTicketMessagesHeaderViewReuseIdentifier: String = "MyTicketMessagesCollectionHeaderView"
    private let sectionSpacingReusableViewReuseIdentifier: String = "SectionSpacingReusableView"

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
            MyTicketMessagesCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: myTicketMessagesHeaderViewReuseIdentifier
        )
        collectionView.register(
            TicketSectionSpacingReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: sectionSpacingReusableViewReuseIdentifier
        )
        collectionView.register(
            TicketImageCollectionViewCell.self,
            forCellWithReuseIdentifier: TicketImageCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            TicketDescriptionCollectionViewCell.self,
            forCellWithReuseIdentifier: TicketDescriptionCollectionViewCell.reuseIdentifier
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
            TicketUserCollectionViewCell.self,
            forCellWithReuseIdentifier: TicketUserCollectionViewCell.reuseIdentifier
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

    public init(with viewModel: TicketDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension TicketDetailViewController {
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch TicketDetailViewController.TicketDetailSection(rawValue: sectionIndex) {
            case .ticketImage:
                return self.getTicketImageSectionLayout()
            case .ticketDescription:
                return self.getTicketDescriptionSectionLayout()
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

    private func getTicketImageSectionLayout() -> NSCollectionLayoutSection {
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

    private func getTicketDescriptionSectionLayout() -> NSCollectionLayoutSection {
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
extension TicketDetailViewController {
    private func bindViewModel() {
        let input = TicketDetailViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            didTapAddMemberButton: didTapAddMemberButton,
            didTapManageButton: didTapManageButton,
            didTapSeeMessagesButton: didTapSeeMessagesButton,
            didTapBuryTicketButton: didTapBuryTicketButton
        )
        let output = viewModel.transform(input)

        output.ticketDetail
            .drive(with: self, onNext: { (self, detail) in
                self.ticketDetail = detail
                self.collectionView.reloadSections(IndexSet([
                    TicketDetailSection.ticketImage.rawValue,
                    TicketDetailSection.ticketDescription.rawValue,
                    TicketDetailSection.myMessages.rawValue
                ]))
            })
            .disposed(by: disposeBag)

        output.collaborators
            .drive(with: self, onNext: { (self, list) in
                self.collaborators = list
                self.collectionView.reloadSections(IndexSet(integer: TicketDetailSection.members.rawValue))
            })
            .disposed(by: disposeBag)

        output.errorToast
            .emit(with: self, onNext: { (self, message) in
                ToastView.show(on: self.view, message: message)
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
extension TicketDetailViewController {
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
extension TicketDetailViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return TicketDetailSection.allCases.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch TicketDetailSection(rawValue: section) {
        case .ticketImage, .ticketDescription, .buryTicket, .myMessages:
            return 1
        case .members:
            return collaborators.count
        default:
            return 0
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch TicketDetailSection(rawValue: indexPath.section) {
        case .ticketImage:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TicketImageCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? TicketImageCollectionViewCell else { return .init() }
            cell.configure(imageUrl: ticketDetail?.mainImageUrl)
            return cell
        case .ticketDescription:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TicketDescriptionCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? TicketDescriptionCollectionViewCell else { return .init() }
            if let detail = ticketDetail {
                cell.configure(
                    title: detail.title,
                    description: detail.description,
                    createdAt: detail.createdAt,
                    openedAt: detail.openedAt
                )
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
                messageCount: ticketDetail?.myContentCount ?? 0,
                photoCount: ticketDetail?.myImageCount ?? 0
            )
            return cell
        case .members:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TicketUserCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? TicketUserCollectionViewCell else { return .init() }
            guard indexPath.item < collaborators.count else { return cell }
            cell.configure(collaborator: collaborators[indexPath.item])
            return cell
        default:
            return .init()
        }
    }
}

// MARK: - Delegate (supplementary views)
extension TicketDetailViewController: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch TicketDetailSection(rawValue: indexPath.section) {
        case .myMessages:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: myTicketMessagesHeaderViewReuseIdentifier,
                for: indexPath
            ) as? MyTicketMessagesCollectionHeaderView else { return .init() }
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
                withReuseIdentifier: myTicketMessagesHeaderViewReuseIdentifier,
                for: indexPath
            ) as? MyTicketMessagesCollectionHeaderView else { return .init() }
            header.setStatus(.member)
            header.setMemberCount(collaborators.count)
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
