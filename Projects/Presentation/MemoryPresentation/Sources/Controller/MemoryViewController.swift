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
    enum MemorySection: Int, CaseIterable {
        case memoryImage
        case memoryDescription
        case memories
        case invitedUsers
    }
    
    private let viewModel: MemoryViewModel
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
        collectionView.register(
            MemoryImageCollectionViewCell.self,
            forCellWithReuseIdentifier: MemoryImageCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            MemoryDescriptionCollectionViewCell.self,
            forCellWithReuseIdentifier: MemoryDescriptionCollectionViewCell.reuseIdentifier
        )
        return collectionView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        self.setDelegate()
        
        self.addSubViews()
        self.setLayout()
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
        section.interGroupSpacing = 0.0
        return section
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
        default:
            return .init()
        }
    }
}

extension MemoryViewController: UICollectionViewDelegate {
}
