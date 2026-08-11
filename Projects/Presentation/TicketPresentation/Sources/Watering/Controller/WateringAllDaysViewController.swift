import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class WateringAllDaysViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: WateringAllDaysViewModel
    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let prefetchItems: PublishRelay<[IndexPath]> = .init()
    private let disposeBag: DisposeBag = DisposeBag()
    private var days: [WateringDayItem] = []

    private enum Layout {
        static let columnCount: Int = 5
        static let itemSpacing: CGFloat = 16
        static let lineSpacing: CGFloat = 20.675
        static let horizontalInset: CGFloat = 20
        static let gridTopSpacing: CGFloat = 40
        static let buttonAreaHeight: CGFloat = 88
    }

    // MARK: - UI

    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("물주기")
        return view
    }()

    private let progressView: WateringProgressView = {
        let view = WateringProgressView()
        view.setAllDaysButtonHidden(true)
        return view
    }()

    private lazy var dayCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Layout.itemSpacing
        layout.minimumLineSpacing = Layout.lineSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: Layout.horizontalInset,
            bottom: 0,
            right: Layout.horizontalInset
        )
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPrefetchingEnabled = true
        collectionView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: Layout.buttonAreaHeight,
            right: 0
        )
        collectionView.register(
            WateringDayCollectionViewCell.self,
            forCellWithReuseIdentifier: WateringDayCollectionViewCell.reuseIdentifier
        )
        return collectionView
    }()

    private let waterButtonWavyBackground: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.grey5.color,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: 3
        )
        view.waveCornerRadius = 12
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let waterButton: UIButton = {
        let button = UIButton()
        button.setTitle("물주기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.backgroundColor = .clear
        return button
    }()

    // MARK: - Init

    public init(with viewModel: WateringAllDaysViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setInitialValues()
        addSubviews()
        setLayout()
        bindViewModel()
        rxViewDidLoad.accept(())
    }
}

// MARK: - Setup

extension WateringAllDaysViewController {
    private func setInitialValues() {
        view.backgroundColor = .white
        dayCollectionView.dataSource = self
        dayCollectionView.delegate = self
        dayCollectionView.prefetchDataSource = self
    }

    private func addSubviews() {
        view.addSubview(navigationView)
        view.addSubview(progressView)
        view.addSubview(dayCollectionView)
        view.addSubview(waterButtonWavyBackground)
        view.addSubview(waterButton)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.height.equalTo(53)
        }

        dayCollectionView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(Layout.gridTopSpacing)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        waterButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(48)
        }

        waterButtonWavyBackground.snp.makeConstraints {
            $0.edges.equalTo(waterButton)
        }
    }

    private func bindViewModel() {
        let input = WateringAllDaysViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            prefetchItems: prefetchItems,
            backButtonDidTap: navigationView.backButtonDidTap,
            waterButtonDidTap: waterButton.rx.tap
        )
        let output = viewModel.transform(input)

        Driver.combineLatest(output.wateredDays, output.totalDays)
            .drive(with: self, onNext: { (self, value) in
                self.progressView.configure(wateredDays: value.0, totalDays: value.1)
            })
            .disposed(by: disposeBag)

        output.progressRatio
            .drive(with: self, onNext: { (self, ratio) in
                self.progressView.setProgress(ratio)
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)

        output.days
            .drive(with: self, onNext: { (self, days) in
                self.days = days
                self.dayCollectionView.reloadData()
            })
            .disposed(by: disposeBag)

        output.isWateredToday
            .drive(with: self, onNext: { (self, isWateredToday) in
                self.applyWaterButtonState(isWateredToday: isWateredToday)
            })
            .disposed(by: disposeBag)

        output.errorToast
            .emit(with: self, onNext: { (self, message) in
                ToastView.show(on: self.view, message: message)
            })
            .disposed(by: disposeBag)
    }

    private func applyWaterButtonState(isWateredToday: Bool) {
        waterButton.isEnabled = !isWateredToday
        waterButton.setTitle(isWateredToday ? "물주기 완료" : "물주기", for: .normal)

        let color = isWateredToday
            ? DesignSystemAsset.ColorAssests.grey3.color
            : DesignSystemAsset.ColorAssests.grey5.color
        waterButtonWavyBackground.style = .filledStroked(
            fill: color,
            stroke: color,
            lineWidth: 3
        )
    }
}

// MARK: - UICollectionViewDataSource

extension WateringAllDaysViewController: UICollectionViewDataSource {
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return days.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WateringDayCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? WateringDayCollectionViewCell else { return .init() }
        cell.configure(with: days[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension WateringAllDaysViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        prefetchItems.accept(indexPaths)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension WateringAllDaysViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing = Layout.itemSpacing * CGFloat(Layout.columnCount - 1)
        let available = collectionView.bounds.width
            - Layout.horizontalInset * 2
            - totalSpacing
        let width = (available / CGFloat(Layout.columnCount)).rounded(.down)
        return CGSize(width: width, height: width)
    }
}
