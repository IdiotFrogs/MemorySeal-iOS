import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class OpenConfirmViewController: UIViewController {

    // MARK: - Constant

    private enum Metric {
        static let ticketWidth: CGFloat = 308
        static let ticketHeight: CGFloat = 405.26
        static let ticketBottomOffset: CGFloat = 169.87
        static let buttonHorizontalInset: CGFloat = 20
        static let buttonBottomInset: CGFloat = 24
        static let buttonHeight: CGFloat = 48
        static let buttonCornerRadius: CGFloat = 12
        static let appearDuration: TimeInterval = 0.45
    }

    // MARK: - Properties

    private let viewModel: OpenConfirmViewModel
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - UI

    private let baseGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 210 / 255, green: 211 / 255, blue: 214 / 255, alpha: 1).cgColor,
            UIColor(red: 245 / 255, green: 245 / 255, blue: 246 / 255, alpha: 1).cgColor
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()

    private let backgroundView: MemoryGradientBackgroundView = MemoryGradientBackgroundView()

    private let ticketOpenView: TicketOpenView = {
        let view = TicketOpenView()
        view.isUserInteractionEnabled = false
        return view
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("추억 메시지 확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.backgroundColor = DesignSystemAsset.ColorAssests.primaryNormal.color
        button.layer.cornerRadius = Metric.buttonCornerRadius
        button.clipsToBounds = true
        return button
    }()

    // MARK: - Init

    public init(with viewModel: OpenConfirmViewModel) {
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
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        setInitialValues()
        addSubviews()
        setLayout()
        bindViewModel()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        baseGradientLayer.frame = view.bounds
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: Metric.appearDuration) {
            self.confirmButton.alpha = 1
        }
    }
}

// MARK: - Setup

extension OpenConfirmViewController {
    private func setInitialValues() {
        view.backgroundColor = .white
        view.layer.insertSublayer(baseGradientLayer, at: 0)
        confirmButton.alpha = 0
        ticketOpenView.setTicketImage(urlString: viewModel.ticketImageUrl)
        ticketOpenView.showOpenedLid()
    }

    private func addSubviews() {
        view.addSubview(backgroundView)
        view.addSubview(ticketOpenView)
        view.addSubview(confirmButton)
    }

    private func setLayout() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        ticketOpenView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Metric.ticketBottomOffset)
            $0.width.equalTo(Metric.ticketWidth)
            $0.height.equalTo(Metric.ticketHeight)
        }
        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Metric.buttonHorizontalInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Metric.buttonBottomInset)
            $0.height.equalTo(Metric.buttonHeight)
        }
    }

    private func bindViewModel() {
        let input = OpenConfirmViewModel.Input(
            confirmDidTap: confirmButton.rx.tap
        )
        _ = viewModel.transform(input)
    }
}
