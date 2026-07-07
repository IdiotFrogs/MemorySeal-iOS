import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class OpenIntroViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: OpenIntroViewModel
    private let disposeBag: DisposeBag = DisposeBag()

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

    private let ticketButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(DesignSystemAsset.ImageAssets.ticketWavyFrame.image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
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
}

// MARK: - Setup

extension OpenIntroViewController {
    private func setInitialValues() {
        view.backgroundColor = .white
        view.layer.insertSublayer(gradientLayer, at: 0)
        ticketButton.imageView?.clipsToBounds = false
        ticketButton.imageView?.layer.shadowColor = UIColor.black.cgColor
        ticketButton.imageView?.layer.shadowOpacity = 0.12
        ticketButton.imageView?.layer.shadowRadius = 12
        ticketButton.imageView?.layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(ticketButton)
    }

    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(48)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        ticketButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(56)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(269)
            $0.height.equalTo(ticketButton.snp.width).multipliedBy(317.0 / 315.0)
        }
    }

    private func bindViewModel() {
        let input = OpenIntroViewModel.Input(
            ticketDidTap: ticketButton.rx.tap
        )
        _ = viewModel.transform(input)
    }
}
