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

public final class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let rxViewDidLoad: PublishRelay<Void> = .init()
    
    private let collectionView: UICollectionView = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        collectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewFlowLayout
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            TicketCollectionViewCell.self,
            forCellWithReuseIdentifier: TicketCollectionViewCell.reuseIdentifier
        )
        return collectionView
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
        self.view.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        
        self.addSubviews()
        self.setLayout()
        
        self.bindViewModel()
        self.rxViewDidLoad.accept(())
    }
}

extension HomeViewController {
    private func bindViewModel() {
        let input = HomeViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            didTapMemoryList: collectionView.rx.itemSelected
        )
        let output = viewModel.transform(input)
        
        output.memoryList
            .bind(to: collectionView.rx.items(
                cellIdentifier: TicketCollectionViewCell.reuseIdentifier,
                cellType: TicketCollectionViewCell.self
            )) { (index, cell, item) in
                
            }
            .disposed(by: disposeBag)
        
    }
}

extension HomeViewController {
    private func addSubviews() {
        view.addSubview(collectionView)
    }
    
    private func setLayout() {
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(172)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
}
