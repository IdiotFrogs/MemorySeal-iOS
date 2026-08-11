import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class OpenIntroViewController: UIViewController {

    // MARK: - Constant

    private enum Metric {
        static let titleTopOffset: CGFloat = 84
        static let titleHorizontalInset: CGFloat = 20
        static let ticketWidth: CGFloat = 308
        static let ticketHeight: CGFloat = 405.26
        static let ticketBottomOffset: CGFloat = 169.87
        static let tapHandLeadingOffset: CGFloat = 259.53
        static let tapHandTopOffset: CGFloat = 117.95
        static let tapHandWidth: CGFloat = 50.52
        static let tapHandHeight: CGFloat = 49.71
    }

    // MARK: - Properties

    private let viewModel: OpenIntroViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let ticketOpenRelay: PublishRelay<Void> = PublishRelay()

    // MARK: - UI

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 210 / 255, green: 211 / 255, blue: 214 / 255, alpha: 1).cgColor,
            UIColor(red: 245 / 255, green: 245 / 255, blue: 246 / 255, alpha: 1).cgColor
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.3
        paragraphStyle.alignment = .center
        label.attributedText = NSAttributedString(
            string: "티켓을 열어서\n추억을 확인해보세요!",
            attributes: [
                .font: DesignSystemFontFamily.Pretendard.bold.font(size: 24),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
        )
        label.numberOfLines = 0
        return label
    }()

    private let backgroundView: MemoryGradientBackgroundView = MemoryGradientBackgroundView()

    private let ticketOpenView: TicketOpenView = {
        let view = TicketOpenView()
        view.isUserInteractionEnabled = false
        return view
    }()

    private let tapHandImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.tapHandIcon.image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private let ticketButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        return button
    }()

    // MARK: - Init

    public init(with viewModel: OpenIntroViewModel) {
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
        gradientLayer.frame = view.bounds
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ticketOpenView.showClosedLid()
        backgroundView.alpha = 0
        titleLabel.alpha = 1
        tapHandImageView.alpha = 1
        ticketButton.isUserInteractionEnabled = true
    }
}

// MARK: - Setup

extension OpenIntroViewController {
    private func setInitialValues() {
        view.backgroundColor = .white
        view.layer.insertSublayer(gradientLayer, at: 0)
        backgroundView.alpha = 0
        ticketOpenView.setTicketImage(urlString: viewModel.ticketImageUrl)
    }

    private func addSubviews() {
        view.addSubview(backgroundView)
        view.addSubview(titleLabel)
        view.addSubview(ticketOpenView)
        view.addSubview(tapHandImageView)
        view.addSubview(ticketButton)
    }

    private func setLayout() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(Metric.titleTopOffset)
            $0.leading.trailing.equalToSuperview().inset(Metric.titleHorizontalInset)
        }
        ticketOpenView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Metric.ticketBottomOffset)
            $0.width.equalTo(Metric.ticketWidth)
            $0.height.equalTo(Metric.ticketHeight)
        }
        tapHandImageView.snp.makeConstraints {
            $0.leading.equalTo(ticketOpenView.snp.leading).offset(Metric.tapHandLeadingOffset)
            $0.top.equalTo(ticketOpenView.snp.top).offset(Metric.tapHandTopOffset)
            $0.width.equalTo(Metric.tapHandWidth)
            $0.height.equalTo(Metric.tapHandHeight)
        }
        ticketButton.snp.makeConstraints {
            $0.edges.equalTo(ticketOpenView)
        }
    }

    private func bindViewModel() {
        ticketButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.ticketButton.isUserInteractionEnabled = false
                UIView.animate(withDuration: TicketOpenView.openAnimationDuration) {
                    self.backgroundView.alpha = 1
                    self.titleLabel.alpha = 0
                    self.tapHandImageView.alpha = 0
                }
                self.ticketOpenView.playOpenAnimation { [weak self] in
                    self?.ticketOpenRelay.accept(())
                }
            })
            .disposed(by: disposeBag)

        let input = OpenIntroViewModel.Input(
            ticketDidTap: ControlEvent(events: ticketOpenRelay)
        )
        _ = viewModel.transform(input)
    }
}
