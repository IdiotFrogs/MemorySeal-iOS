import UIKit

import SnapKit
import RxSwift
import RxCocoa

import MemoryDomain
import DesignSystem

public final class BuryTicketViewController: UIViewController {
    private let viewModel: BuryTicketViewModel
    private let disposeBag: DisposeBag = DisposeBag()

    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let didSelectDate: PublishRelay<Date> = .init()
    private var currentCalendarDates: [CalendarDateEntity] = []

    // MARK: - Subviews

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.24)
        return view
    }()

    private let containerView: WavyStrokeView = {
        let view = WavyStrokeView(fillColor: .white)
        view.waveCornerRadius = 12
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "티켓 오픈일 설정"
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 20)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        let text = "한번 묻은 티켓은 오픈일까지 다시 오픈,\n수정 할 수 없습니다."
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        label.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: DesignSystemFontFamily.Pretendard.regular.font(size: 16),
                .foregroundColor: DesignSystemAsset.ColorAssests.grey3.color,
                .paragraphStyle: paragraphStyle
            ]
        )
        label.numberOfLines = 0
        return label
    }()

    private let calendarView: MemorySealCalendarView = MemorySealCalendarView()

    private let cancelButtonBackground: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.grey1.color,
            strokeColor: DesignSystemAsset.ColorAssests.grey1.color,
            lineWidth: 3
        )
        view.waveCornerRadius = 12
        view.strokeAlignment = .inside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("취소", for: .normal)
        button.setTitleColor(DesignSystemAsset.ColorAssests.grey4.color, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.backgroundColor = .clear
        return button
    }()

    private let buryButtonBackground: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            strokeColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            lineWidth: 3
        )
        view.waveCornerRadius = 12
        view.strokeAlignment = .inside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let buryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("묻기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.backgroundColor = .clear
        return button
    }()

    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    // MARK: - Init

    public init(with viewModel: BuryTicketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear

        self.addSubviews()
        self.setLayout()
        self.bindViewModel()
        self.bindDimView()

        self.rxViewDidLoad.accept(())
    }
}

// MARK: - Subviews

extension BuryTicketViewController {
    private func addSubviews() {
        view.addSubview(dimView)
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(calendarView)
        cancelButton.insertSubview(cancelButtonBackground, at: 0)
        buryButton.insertSubview(buryButtonBackground, at: 0)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(buryButton)
        containerView.addSubview(buttonStackView)
    }

    private func setLayout() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        calendarView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        cancelButtonBackground.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        buryButtonBackground.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
    }
}

// MARK: - Bind

extension BuryTicketViewController {
    private func bindViewModel() {
        let input = BuryTicketViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            previousMonthButtonDidTap: calendarView.previousMonthButtonDidTap,
            nextMonthButtonDidTap: calendarView.nextMonthButtonDidTap,
            didSelectDate: didSelectDate,
            cancelButtonDidTap: cancelButton.rx.tap,
            buryButtonDidTap: buryButton.rx.tap
        )
        let output = viewModel.transform(input)

        output.currentMonth
            .withUnretained(self)
            .subscribe(onNext: { (self, date) in
                self.calendarView.setTitleLabel(date: date)
            })
            .disposed(by: disposeBag)

        output.calendarDates
            .withUnretained(self)
            .subscribe(onNext: { (self, dates) in
                self.currentCalendarDates = dates
            })
            .disposed(by: disposeBag)

        output.calendarDates
            .bind(to: calendarView.collectionView.rx.items(
                cellIdentifier: MemorySealCalendarCollectionViewCell.reuseIdentifier,
                cellType: MemorySealCalendarCollectionViewCell.self
            )) { (index, item, cell) in
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US")
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                dateFormatter.dateFormat = "d"
                let dateText: String = dateFormatter.string(from: item.date)

                cell.configure(
                    dateText: dateText,
                    isCurrentMonth: item.isInCurrentMonth,
                    isToday: item.isToday
                )

                if index > 30 {
                    self.calendarView.remakeCollectionViewLayout()
                }
            }
            .disposed(by: disposeBag)

        calendarView.collectionView.rx.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPath) in
                guard indexPath.item < self.currentCalendarDates.count else { return }
                let date = self.currentCalendarDates[indexPath.item].date
                self.didSelectDate.accept(date)
            })
            .disposed(by: disposeBag)

        output.canBury
            .drive(with: self) { (self, canBury) in
                self.applyBuryButtonState(enabled: canBury)
            }
            .disposed(by: disposeBag)

        output.isLoading
            .drive(with: self) { (self, isLoading) in
                self.view.isUserInteractionEnabled = !isLoading
            }
            .disposed(by: disposeBag)

        output.errorMessage
            .emit(with: self) { (self, message) in
                ToastView.show(on: self.view, message: message)
            }
            .disposed(by: disposeBag)
    }

    private func applyBuryButtonState(enabled: Bool) {
        buryButton.isEnabled = enabled
        let color: UIColor = enabled
            ? DesignSystemAsset.ColorAssests.primaryNormal.color
            : DesignSystemAsset.ColorAssests.primaryLight.color
        buryButtonBackground.style = .filledStroked(fill: color, stroke: color, lineWidth: 3)
        buryButton.setTitleColor(.white, for: .normal)
    }

    private func bindDimView() {
        let tapGesture = UITapGestureRecognizer()
        dimView.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
