import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class OpenConfirmViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: OpenConfirmViewModel
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - UI

    private let ticketImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.ticketWavyFrame.image
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        return imageView
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("추억 메시지 확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.backgroundColor = DesignSystemAsset.ColorAssests.primaryNormal.color
        button.layer.cornerRadius = 12
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
}

// MARK: - Setup

extension OpenConfirmViewController {
    private func setInitialValues() {
        view.backgroundColor = .white
        ticketImageView.layer.shadowColor = UIColor.black.cgColor
        ticketImageView.layer.shadowOpacity = 0.12
        ticketImageView.layer.shadowRadius = 12
        ticketImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    private func addSubviews() {
        view.addSubview(ticketImageView)
        view.addSubview(confirmButton)
    }

    private func setLayout() {
        ticketImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-40)
            $0.width.equalTo(269)
            $0.height.equalTo(ticketImageView.snp.width).multipliedBy(317.0 / 315.0)
        }
        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(48)
        }
    }

    private func bindViewModel() {
        let input = OpenConfirmViewModel.Input(
            confirmDidTap: confirmButton.rx.tap
        )
        _ = viewModel.transform(input)
    }
}
