//
//  TutorialViewController.swift
//  TutorialPresentation
//
//  Created by 선민재 on 10/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class TutorialViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: TutorialViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let pageDidScroll: PublishRelay<Int> = .init()

    // MARK: - UI

    private let skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("건너뛰기", for: .normal)
        button.setTitleColor(TutorialMetrics.skipColor, for: .normal)
        button.titleLabel?.font = TutorialMetrics.skipFont
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(
            TutorialPageCell.self,
            forCellWithReuseIdentifier: TutorialPageCell.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private let pageIndicatorView: TutorialPageIndicatorView = TutorialPageIndicatorView()

    private let nextButtonWavyBackground: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            strokeColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            lineWidth: TutorialMetrics.buttonLineWidth
        )
        view.waveCornerRadius = TutorialMetrics.buttonCornerRadius
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = TutorialMetrics.buttonFont
        button.backgroundColor = .clear
        return button
    }()

    // MARK: - Init

    public init(with viewModel: TutorialViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setInitialValues()
        addSubviews()
        setLayout()
        bindViewModel()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateItemSize()
    }
}

// MARK: - Setup

extension TutorialViewController {
    private func setInitialValues() {
        pageIndicatorView.configure(numberOfPages: viewModel.pages.count)
    }

    private func addSubviews() {
        view.addSubview(collectionView)
        view.addSubview(skipButton)
        view.addSubview(pageIndicatorView)
        view.addSubview(nextButtonWavyBackground)
        view.addSubview(nextButton)
    }

    private func setLayout() {
        skipButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(TutorialMetrics.skipTopOffset)
            $0.trailing.equalToSuperview().inset(TutorialMetrics.horizontalInset)
        }
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(TutorialMetrics.horizontalInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(TutorialMetrics.buttonBottomInset)
            $0.height.equalTo(TutorialMetrics.buttonHeight)
        }
        nextButtonWavyBackground.snp.makeConstraints {
            $0.edges.equalTo(nextButton)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(TutorialMetrics.contentTopOffset)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-TutorialMetrics.bodyToButtonSpacing)
        }
        pageIndicatorView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(TutorialMetrics.indicatorDotSize)
            $0.bottom.equalTo(collectionView.snp.bottom).offset(
                -(TutorialMetrics.textBlockHeight + TutorialMetrics.indicatorBottomSpacing)
            )
        }
    }

    private func updateItemSize() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
              collectionView.bounds.width > 0,
              collectionView.bounds.height > 0,
              layout.itemSize != collectionView.bounds.size
        else {
            return
        }

        layout.itemSize = collectionView.bounds.size
        layout.invalidateLayout()
    }

    private func bindViewModel() {
        let input = TutorialViewModel.Input(
            nextButtonDidTap: nextButton.rx.tap.asObservable(),
            skipButtonDidTap: skipButton.rx.tap.asObservable(),
            pageDidScroll: pageDidScroll.asObservable()
        )
        let output = viewModel.translation(input)

        output.currentPage
            .drive(with: self) { (self, page) in
                self.apply(currentPage: page)
            }
            .disposed(by: disposeBag)

        output.scrollToPage
            .emit(with: self) { (self, page) in
                self.collectionView.scrollToItem(
                    at: IndexPath(item: page, section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
            }
            .disposed(by: disposeBag)
    }

    private func apply(currentPage: Int) {
        guard let page = viewModel.pages[safe: currentPage] else { return }

        pageIndicatorView.setCurrentPage(currentPage, animated: true)
        nextButton.setTitle(page.buttonTitle, for: .normal)
        skipButton.isHidden = !page.isSkippable
    }
}

// MARK: - UICollectionViewDataSource

extension TutorialViewController: UICollectionViewDataSource {
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.pages.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TutorialPageCell.reuseIdentifier,
            for: indexPath
        ) as? TutorialPageCell else {
            return UICollectionViewCell()
        }

        cell.configure(page: viewModel.pages[indexPath.item])
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension TutorialViewController: UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === collectionView, scrollView.bounds.width > 0 else { return }

        let page = Int((scrollView.contentOffset.x / scrollView.bounds.width).rounded())
        let clampedPage = min(max(page, 0), viewModel.pages.count - 1)
        pageDidScroll.accept(clampedPage)
    }
}

// MARK: - Collection

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
