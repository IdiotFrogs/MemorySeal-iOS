//
//  CreateTicketViewController.swift
//  HomePresentation
//
//  Created by 선민재 on 5/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import PhotosUI
import SnapKit
import RxSwift
import RxCocoa

import CalendarDomain
import DesignSystem

public final class CreateTicketViewController: UIViewController {
    private let viewModel: CreateTicketViewModel
    private let disposeBag: DisposeBag = DisposeBag()

    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let imageSelectedRelay: PublishRelay<UIImage> = .init()
    private let selectedDateRelay: PublishRelay<Date> = .init()
    private var currentCalendarDates: [CalendarDateModel] = []

    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("타임 티켓 생성하기")
        return view
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let photoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "사진"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        return label
    }()

    private let ticketImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.ticketNoneImage.image
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let ticketImageWavyStrokeView: WavyStrokeView = {
        let view = WavyStrokeView(
            strokeColor: DesignSystemAsset.ColorAssests.grey1.color,
            lineWidth: 3
        )
        view.waveCornerRadius = 12
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let ticketTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        return label
    }()

    private let ticketTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목을 입력해주세요."
        textField.textColor = DesignSystemAsset.ColorAssests.grey5.color
        textField.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        textField.setPlaceholder(
            color: DesignSystemAsset.ColorAssests.grey3.color,
            font: DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        )
        textField.layer.cornerRadius = 12
        return textField
    }()

    private let ticketTitleWavyStrokeView: WavyStrokeView = {
        let view = WavyStrokeView(
            strokeColor: DesignSystemAsset.ColorAssests.grey1.color,
            lineWidth: 3
        )
        view.waveCornerRadius = 12
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "간단한 설명"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        return label
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = DesignSystemAsset.ColorAssests.grey5.color
        textView.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        textView.layer.cornerRadius = 12
        textView.textContainerInset = .init(top: 14.0, left: 12.0, bottom: 14.0, right: 12.0)
        textView.isScrollEnabled = false
        return textView
    }()

    private let descriptionWavyStrokeView: WavyStrokeView = {
        let view = WavyStrokeView(
            strokeColor: DesignSystemAsset.ColorAssests.grey1.color,
            lineWidth: 3
        )
        view.waveCornerRadius = 12
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let descriptionPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "설명을 입력해주세요."
        label.textColor = DesignSystemAsset.ColorAssests.grey3.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        return label
    }()

    private let calendarTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "오픈 날짜"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        return label
    }()

    private let calendarView: MemorySealCalendarView = {
        let view = MemorySealCalendarView()
        view.layer.cornerRadius = 12
        return view
    }()

    private let calendarWavyStrokeView: WavyStrokeView = {
        let view = WavyStrokeView(
            strokeColor: DesignSystemAsset.ColorAssests.grey1.color,
            lineWidth: 3
        )
        view.waveCornerRadius = 12
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let createButtonWavyBackground: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            strokeColor: UIColor(hex: "#29A047") ?? DesignSystemAsset.ColorAssests.primaryDark.color,
            lineWidth: 3
        )
        view.waveCornerRadius = 12
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("생성", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.backgroundColor = .clear
        return button
    }()

    public init(with viewModel: CreateTicketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        self.addSubviews()
        self.setLayout()
        self.addLeftPaddingView()

        self.bindViewModel()
        self.bindScrollView()
        self.bindTextView()
        self.bindTextFieldFocus()
        self.bindImagePicker()
        self.rxViewDidLoad.accept(())
    }

    public override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        self.view.endEditing(true)
    }
}

extension CreateTicketViewController {
    private func bindViewModel() {
        let input = CreateTicketViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            navigationViewBackButtonDidTap: navigationView.backButtonDidTap,
            previousMonthButtonDidTap: calendarView.previousMonthButtonDidTap,
            nextMonthButtonDidTap: calendarView.nextMonthButtonDidTap,
            createButtonDidTap: createButton.rx.tap,
            titleText: ticketTitleTextField.rx.text,
            descriptionText: descriptionTextView.rx.text,
            selectedImage: imageSelectedRelay,
            selectedDate: selectedDateRelay
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
                self.selectedDateRelay.accept(date)
            })
            .disposed(by: disposeBag)

        output.isLoading
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, isLoading) in
                self.createButton.isEnabled = !isLoading
            })
            .disposed(by: disposeBag)
    }

    private func bindScrollView() {
        scrollView.rx.contentOffset
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }

    private func bindTextView() {
        descriptionTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { (self, text) in
                self.descriptionPlaceholderLabel.isHidden = text.isEmpty == false
            })
            .disposed(by: disposeBag)
    }

    private func bindTextFieldFocus() {
        let activeColor = DesignSystemAsset.ColorAssests.primaryNormal.color
        let inactiveColor = DesignSystemAsset.ColorAssests.grey1.color
        let filledBg = DesignSystemAsset.ColorAssests.backgroundNormal.color

        ticketTitleTextField.rx.controlEvent(.editingDidBegin)
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.ticketTitleWavyStrokeView.setStrokeColor(activeColor)
                self.ticketTitleTextField.backgroundColor = .white
            })
            .disposed(by: disposeBag)

        ticketTitleTextField.rx.controlEvent(.editingDidEnd)
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.ticketTitleWavyStrokeView.setStrokeColor(inactiveColor)
                let isEmpty = self.ticketTitleTextField.text?.isEmpty ?? true
                self.ticketTitleTextField.backgroundColor = isEmpty ? .white : filledBg
            })
            .disposed(by: disposeBag)

        descriptionTextView.rx.didBeginEditing
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.descriptionWavyStrokeView.setStrokeColor(activeColor)
                self.descriptionTextView.backgroundColor = .white
            })
            .disposed(by: disposeBag)

        descriptionTextView.rx.didEndEditing
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.descriptionWavyStrokeView.setStrokeColor(inactiveColor)
                let isEmpty = self.descriptionTextView.text?.isEmpty ?? true
                self.descriptionTextView.backgroundColor = isEmpty ? .white : filledBg
            })
            .disposed(by: disposeBag)
    }

    private func bindImagePicker() {
        let tapGesture = UITapGestureRecognizer()
        ticketImageView.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.presentImagePicker()
            })
            .disposed(by: disposeBag)

        imageSelectedRelay
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, image) in
                self.ticketImageView.image = image
                self.ticketImageView.contentMode = .scaleAspectFill
                self.ticketImageWavyStrokeView.setStrokeColor(
                    DesignSystemAsset.ColorAssests.grey5.color
                )
            })
            .disposed(by: disposeBag)
    }

    private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension CreateTicketViewController: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self.imageSelectedRelay.accept(image)
            }
        }
    }
}

extension CreateTicketViewController {
    private func addLeftPaddingView() {
        let paddingView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 12,
            height: 0
        ))
        ticketTitleTextField.leftView = paddingView
        ticketTitleTextField.leftViewMode = .always
    }

    private func addSubviews() {
        view.addSubview(navigationView)
        view.addSubview(scrollView)

        scrollView.addSubview(photoTitleLabel)
        scrollView.addSubview(ticketImageView)
        scrollView.addSubview(ticketImageWavyStrokeView)

        scrollView.addSubview(ticketTitleLabel)
        scrollView.addSubview(ticketTitleTextField)
        scrollView.addSubview(ticketTitleWavyStrokeView)

        scrollView.addSubview(descriptionTitleLabel)
        scrollView.addSubview(descriptionTextView)
        scrollView.addSubview(descriptionPlaceholderLabel)
        scrollView.addSubview(descriptionWavyStrokeView)

        scrollView.addSubview(calendarTitleLabel)
        scrollView.addSubview(calendarView)
        scrollView.addSubview(calendarWavyStrokeView)

        scrollView.addSubview(createButtonWavyBackground)
        scrollView.addSubview(createButton)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.width.equalTo(view.frame.width)
        }

        photoTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
        }

        ticketImageView.snp.makeConstraints {
            $0.top.equalTo(photoTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.width.height.equalTo(120)
        }

        ticketImageWavyStrokeView.snp.makeConstraints {
            $0.edges.equalTo(ticketImageView)
        }

        ticketTitleLabel.snp.makeConstraints {
            $0.top.equalTo(ticketImageView.snp.bottom).offset(16)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
        }

        ticketTitleTextField.snp.makeConstraints {
            $0.top.equalTo(ticketTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
            $0.height.equalTo(48)
        }

        ticketTitleWavyStrokeView.snp.makeConstraints {
            $0.edges.equalTo(ticketTitleTextField)
        }

        descriptionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(ticketTitleTextField.snp.bottom).offset(16)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
        }

        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(descriptionTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
            $0.height.greaterThanOrEqualTo(48)
        }

        descriptionWavyStrokeView.snp.makeConstraints {
            $0.edges.equalTo(descriptionTextView)
        }

        descriptionPlaceholderLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.top).offset(14)
            $0.leading.equalTo(descriptionTextView.snp.leading).offset(15)
        }

        calendarTitleLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom).offset(16)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
        }

        calendarView.snp.makeConstraints {
            $0.top.equalTo(calendarTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
        }

        calendarWavyStrokeView.snp.makeConstraints {
            $0.edges.equalTo(calendarView)
        }

        createButton.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(24)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
            $0.bottom.equalTo(scrollView.snp.bottom).inset(24)
            $0.height.equalTo(48)
        }

        createButtonWavyBackground.snp.makeConstraints {
            $0.edges.equalTo(createButton)
        }
    }
}
