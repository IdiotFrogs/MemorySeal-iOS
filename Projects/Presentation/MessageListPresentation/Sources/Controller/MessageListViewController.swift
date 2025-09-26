//
//  MessageListViewController.swift
//  MessageListPresentation
//
//  Created by 선민재 on 9/22/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class MessageListViewController: UIViewController {
    private let rxViewDidLoad: PublishRelay<Void> = .init()
    
    private let viewModel: MessageListViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("프로필")
        return view
    }()
    
    private let userListCollectionView: UICollectionView = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.itemSize = .init(width: 80, height: 102)
        let collectionView = UICollectionView()
        collectionView.register(
            UserListCollectionViewCell.self,
            forCellWithReuseIdentifier: UserListCollectionViewCell.reuseIdentifier
        )
        return collectionView
    }()
    
    public init(with viewModel: MessageListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSubViews()
        self.setLayout()
        
        self.bindViewModel()
        self.rxViewDidLoad.accept(())
    }
    
}

extension MessageListViewController {
    private func bindViewModel() {
        let input = MessageListViewModel.Input(rxViewDidLoad: rxViewDidLoad)
        let output = viewModel.transform(input)
        
        output.userList
            .bind(to: userListCollectionView.rx.items(
                cellIdentifier: UserListCollectionViewCell.reuseIdentifier,
                cellType: UserListCollectionViewCell.self
            )) { (index, item, cell) in
                cell.configure(userNickName: item)
            }
            .disposed(by: disposeBag)
    }
}

extension MessageListViewController {
    private func addSubViews() {
        view.addSubview(navigationView)
        view.addSubview(userListCollectionView)
    }
    
    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        userListCollectionView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(102)
        }
    }
}
