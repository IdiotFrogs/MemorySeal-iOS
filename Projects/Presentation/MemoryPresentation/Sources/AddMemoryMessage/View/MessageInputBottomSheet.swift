import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import DesignSystem

// MARK: - MessageInputBottomSheet

public final class MessageInputBottomSheet: UIViewController {

    // MARK: - Subviews

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.24)
        return view
    }()

    private let sheetContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "메시지"
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        label.textColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1.0)
        label.textAlignment = .left
        return label
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.setTitleColor(UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1.0), for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        button.backgroundColor = .clear
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return button
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.setTitleColor(UIColor(red: 132/255, green: 181/255, blue: 145/255, alpha: 1.0), for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        button.backgroundColor = UIColor(red: 207/255, green: 242/255, blue: 216/255, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return button
    }()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "공유하고 싶은 메시지를 작성해보세요!"
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        label.textColor = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1.0)
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        return label
    }()

    // MARK: - Properties

    public let didSubmitText: PublishRelay<String> = PublishRelay()
    private let disposeBag: DisposeBag = DisposeBag()
    private var isAnimating: Bool = false
    private var sheetBottomConstraint: Constraint?

    // MARK: - Init

    public init() {
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
        addSubviews()
        setLayout()
        bindKeyboard()
        bindActions()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
}

// MARK: - Setup

extension MessageInputBottomSheet {
    private func addSubviews() {
        view.addSubview(dimView)
        view.addSubview(sheetContainer)
        sheetContainer.addSubview(titleLabel)
        sheetContainer.addSubview(cancelButton)
        sheetContainer.addSubview(saveButton)
        sheetContainer.addSubview(textView)
        sheetContainer.addSubview(placeholderLabel)
    }

    private func setLayout() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        sheetContainer.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
            $0.leading.trailing.equalToSuperview()
            self.sheetBottomConstraint = $0.bottom.equalToSuperview().constraint
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().inset(20)
        }

        saveButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(32)
            $0.width.greaterThanOrEqualTo(48)
        }

        cancelButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalTo(saveButton.snp.leading).offset(-4)
        }

        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }

        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(textView.snp.top)
            $0.leading.trailing.equalTo(textView)
        }
    }
}

// MARK: - Keyboard

extension MessageInputBottomSheet {
    private func bindKeyboard() {
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, noti) in
                guard let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                      let duration = noti.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
                else { return }
                self.isAnimating = true
                self.sheetBottomConstraint?.update(offset: -frame.height)
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    self.isAnimating = false
                })
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, noti) in
                let duration = noti.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
                self.isAnimating = true
                self.sheetBottomConstraint?.update(offset: 0)
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    self.isAnimating = false
                })
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Binding

extension MessageInputBottomSheet {
    private func bindActions() {
        let tapGesture = UITapGestureRecognizer()
        dimView.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .filter { [weak self] _ in self?.isAnimating == false }
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                let trimmed = self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    self.didSubmitText.accept(trimmed)
                }
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        textView.rx.text.orEmpty
            .map { !$0.isEmpty }
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
