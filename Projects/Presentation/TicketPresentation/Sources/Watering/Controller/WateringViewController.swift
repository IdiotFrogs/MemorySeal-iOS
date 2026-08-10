import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class WateringViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: WateringViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private var days: [WateringDayItem] = []
    private var todayIndex: Int = 0
    private var hasScrolledToToday: Bool = false

    private enum Layout {
        static let todayChipSize: CGFloat = 64
        static let dayChipSize: CGFloat = 48
        static let chipSpacing: CGFloat = 12
        static let horizontalInset: CGFloat = 20
    }

    // MARK: - UI

    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("물주기")
        return view
    }()

    private let plantImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .center
        label.attributedText = NSAttributedString(
            string: "티켓에 물을 주다보면\n메실 티켓이 자라나요!",
            attributes: [
                .font: DesignSystemFontFamily.Pretendard.bold.font(size: 16),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
        )
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.4
        paragraphStyle.alignment = .center
        label.attributedText = NSAttributedString(
            string: "티켓은 누구나 매일\n물을 주기만해도돼요.",
            attributes: [
                .font: DesignSystemFontFamily.Pretendard.regular.font(size: 12),
                .foregroundColor: DesignSystemAsset.ColorAssests.grey3.color,
                .paragraphStyle: paragraphStyle
            ]
        )
        label.numberOfLines = 0
        return label
    }()

    private let progressView: WateringProgressView = {
        let view = WateringProgressView()
        return view
    }()

    private lazy var dayCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Layout.chipSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: Layout.horizontalInset,
            bottom: 0,
            right: Layout.horizontalInset
        )
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
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

    public init(with viewModel: WateringViewModel) {
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
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToTodayIfNeeded()
    }
}

// MARK: - Setup

extension WateringViewController {
    private func setInitialValues() {
        view.backgroundColor = .white
        dayCollectionView.dataSource = self
        dayCollectionView.delegate = self
    }

    private func addSubviews() {
        view.addSubview(navigationView)
        view.addSubview(plantImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
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

        waterButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(48)
        }

        waterButtonWavyBackground.snp.makeConstraints {
            $0.edges.equalTo(waterButton)
        }

        dayCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(waterButton.snp.top).offset(-32)
            $0.height.equalTo(Layout.todayChipSize)
        }

        progressView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.bottom.equalTo(dayCollectionView.snp.top).offset(-32)
            $0.height.equalTo(53)
        }

        subtitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.bottom.equalTo(progressView.snp.top).offset(-60)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-8)
        }

        plantImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(titleLabel.snp.top).offset(-24)
            $0.top.greaterThanOrEqualTo(navigationView.snp.bottom)
        }
    }

    private func bindViewModel() {
        let input = WateringViewModel.Input(
            backButtonDidTap: navigationView.backButtonDidTap,
            allDaysDidTap: progressView.allDaysDidTap,
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

        output.growthStage
            .drive(with: self, onNext: { (self, stage) in
                self.applyGrowthStage(stage)
            })
            .disposed(by: disposeBag)

        output.todayIndex
            .drive(with: self, onNext: { (self, todayIndex) in
                self.todayIndex = todayIndex
            })
            .disposed(by: disposeBag)

        output.days
            .drive(with: self, onNext: { (self, days) in
                self.days = days
                self.dayCollectionView.reloadData()
                self.view.setNeedsLayout()
            })
            .disposed(by: disposeBag)

        output.isWateredToday
            .drive(with: self, onNext: { (self, isWateredToday) in
                self.applyWaterButtonState(isWateredToday: isWateredToday)
            })
            .disposed(by: disposeBag)
    }

    private func scrollToTodayIfNeeded() {
        guard !hasScrolledToToday,
              dayCollectionView.bounds.width > 0,
              days.indices.contains(todayIndex) else { return }

        let indexPath = IndexPath(item: todayIndex, section: 0)
        dayCollectionView.layoutIfNeeded()
        guard let attributes = dayCollectionView.layoutAttributesForItem(at: indexPath) else { return }

        let maximumOffset = max(
            dayCollectionView.contentSize.width - dayCollectionView.bounds.width,
            0
        )
        let targetOffset = min(
            max(attributes.frame.minX - Layout.horizontalInset, 0),
            maximumOffset
        )
        dayCollectionView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: false)
        hasScrolledToToday = true
    }

    private func applyGrowthStage(_ stage: WateringGrowthStage) {
        plantImageView.image = stage.image
        plantImageView.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(titleLabel.snp.top).offset(-24)
            $0.top.greaterThanOrEqualTo(navigationView.snp.bottom)
            $0.width.equalTo(stage.size.width)
            $0.height.equalTo(stage.size.height)
        }
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

extension WateringViewController: UICollectionViewDataSource {
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

// MARK: - UICollectionViewDelegateFlowLayout

extension WateringViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = days[indexPath.item].isToday ? Layout.todayChipSize : Layout.dayChipSize
        return CGSize(width: width, height: Layout.todayChipSize)
    }
}
