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
    private let viewModel: HomeViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let rxViewDidLoad: PublishRelay<Void> = .init()

    private let collectionView: UICollectionView = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        collectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionViewFlowLayout.minimumLineSpacing = 20
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewFlowLayout
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 23, left: 0, bottom: 0, right: 0)
        collectionView.register(
            TicketCollectionViewCell.self,
            forCellWithReuseIdentifier: TicketCollectionViewCell.reuseIdentifier
        )
        return collectionView
    }()

    private let emptyStateView = UIView()

    private let emptyMessageLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        label.textColor = DesignSystemAsset.ColorAssests.grey4.color
        label.numberOfLines = 0
        label.textAlignment = .center
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 4
        label.attributedText = NSAttributedString(
            string: "생성한 티켓이 없습니다\n버튼을 눌러서 티켓을 추가해 보세요",
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
            )) { (index, entity, cell) in
                cell.configure(with: entity)
            }
            .disposed(by: disposeBag)

        output.memoryList
            .map { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .bind(to: emptyStateView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

extension HomeViewController {
    private func addSubviews() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyMessageLabel)
        emptyStateView.addSubview(emptyArrowImageView)
    }

    private func setLayout() {
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(164)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }

        emptyStateView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        emptyMessageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(376)
        }

        emptyArrowImageView.snp.makeConstraints {
            $0.top.equalTo(emptyMessageLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(176)
            $0.width.equalTo(92)
            $0.height.equalTo(246)
        }
    }
}
