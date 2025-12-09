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

import DesignSystem

public final class MemoryViewController: UIViewController {
    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let didTapAddMemberButton: PublishRelay<Void> = .init()
    
    enum MemorySection: Int, CaseIterable {
        case memoryImage
        case memoryDescription
        case memories
        case headUser
        case invitedUsers
    }
    
    private let viewModel: MemoryViewModel
    private let memoriesHeaderViewReuseIdentifier: String = "MyMemoriesCollectionHeaderView"
    private let sectionSpacingReusableViewReuseIdentifier: String = "SectionSpacingReusableView"
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
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
            TextMemoryCollectionViewCell.self,
            forCellWithReuseIdentifier: TextMemoryCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            VoiceMemoryCollectionViewCell.self,
            forCellWithReuseIdentifier: VoiceMemoryCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            MemoryHeadUserCollectionViewCell.self,
            forCellWithReuseIdentifier: MemoryHeadUserCollectionViewCell.reuseIdentifier
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
        self.setDelegate()
        
        self.addSubViews()
        self.setLayout()
        self.bindViewModel()
        
        self.rxViewDidLoad.accept(())
    }
    
    public init(with viewModel: MemoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MemoryViewController {
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch MemoryViewController.MemorySection(rawValue: sectionIndex) {
            case .memoryImage:
                return self.getMemoryImageSectionLayout()
            case .memoryDescription:
                return self.getMemoryDescriptionSectionLayout()
            case .memories:
                return self.getMemoriesSectionLayout()
            case .headUser:
                return self.getHeadUserSectionLayout()
            case .invitedUsers:
                return self.getUserSectionLayout()
            default:
                return nil
            }
        }
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
        return layout
    }
    
    private func getMemoryImageSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(420)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(420)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: -view.safeAreaInsets.top,
            leading: 0.0,
            bottom: 0.0,
            trailing: 0.0
        )
        section.interGroupSpacing = 0.0
        return section
    }
    
    private func getMemoryDescriptionSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(128)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(128)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        let footerView = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(16)
            ),
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        section.boundarySupplementaryItems = [footerView]
        section.interGroupSpacing = 0.0
        return section
    }
    
    private func getMemoriesSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(64)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(64)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        let headerView = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(65)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        let footerView = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40)
            ),
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        footerView.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0)
        section.boundarySupplementaryItems = [headerView, footerView]
        section.interGroupSpacing = 8.0
        return section
    }
    
    private func getHeadUserSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(64)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(64)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        let headerView = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(65)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerView]
        section.interGroupSpacing = 8.0
        return section
    }
    
    private func getUserSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(48)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(64)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16.0, leading: 0, bottom: 0, trailing: 0)
        section.interGroupSpacing = 16.0
        return section
    }
}

extension MemoryViewController {
    private func bindViewModel() {
        let input = MemoryViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            didTapAddMemberButton: didTapAddMemberButton
        )
        let _ = viewModel.transform(input)
    }
}

extension MemoryViewController {
    private func setDelegate() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func addSubViews() {
        view.addSubview(collectionView)
    }
    
    private func setLayout() {
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension MemoryViewController: UICollectionViewDataSource {
    public func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        return MemorySection.allCases.count
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch MemorySection(rawValue: section) {
        case .memoryImage:
            return 1
        case .memoryDescription:
            return 1
        case .memories:
            return 2
        case .headUser:
            return 1
        case .invitedUsers:
            return 4
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
            return cell
        case .memoryDescription:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MemoryDescriptionCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? MemoryDescriptionCollectionViewCell else { return .init() }
            
            return cell
        case .memories:
            let voice: Bool = false
            
            if voice {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: VoiceMemoryCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as? VoiceMemoryCollectionViewCell else { return .init() }
                
                let urlString: String = "https://sample-files.com/audio/m4a/sample4.m4a"
                guard let url: URL = URL(string: urlString) else { return .init() }
                
                cell.configure(url)
                
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TextMemoryCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as? TextMemoryCollectionViewCell else { return .init() }
                
                return cell
            }
        case .headUser:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MemoryHeadUserCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? MemoryHeadUserCollectionViewCell else { return .init() }

            return cell
        case .invitedUsers:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MemoryUserCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? MemoryUserCollectionViewCell else { return .init() }
                
            return cell
        default:
            return .init()
        }
    }
}

extension MemoryViewController: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch MemorySection(rawValue: indexPath.section) {
        case .memoryDescription:
            guard let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: sectionSpacingReusableViewReuseIdentifier,
                for: indexPath
            ) as? MemorySectionSpacingReusableView else { return .init() }
            
            return footerView
        case .memories:
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: memoriesHeaderViewReuseIdentifier,
                    for: indexPath
                ) as? MyMemoriesCollectionHeaderView else { return .init() }
                
                headerView.setStatus(.message)
                
                return headerView
            case UICollectionView.elementKindSectionFooter:
                guard let footerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter,
                    withReuseIdentifier: sectionSpacingReusableViewReuseIdentifier,
                    for: indexPath
                ) as? MemorySectionSpacingReusableView else { return .init() }
                
                return footerView
            default:
                return .init()
            }
        case .headUser:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: memoriesHeaderViewReuseIdentifier,
                for: indexPath
            ) as? MyMemoriesCollectionHeaderView else { return .init() }
            
            headerView.setStatus(.member)
            
            headerView.didTapSeeOtherButton
                .withUnretained(self)
                .subscribe(onNext: { (self, _) in
                    self.didTapAddMemberButton.accept(())
                })
                .disposed(by: headerView.disposeBag)
            
            return headerView
        default:
            return .init()
        }
        
    }
}
