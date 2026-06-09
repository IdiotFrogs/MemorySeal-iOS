import UIKit
import SnapKit

import DesignSystem

public final class MessageDetailModalViewController: UIViewController {

    public var onEditTap: ((String) -> Void)?

    private let messageText: String

    private let dimmerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.24)
        return view
    }()

    private let cardView: WavyStrokeView = {
        let view = WavyStrokeView(fillColor: .white)
        view.waveCornerRadius = 12
        return view
    }()

    private let topBar: UIView = UIView()

    private let editButton: UIButton = {
        let button = UIButton()
        let image = UIImage(
            named: "EditMessageIcon",
            in: DesignSystemResources.bundle,
            with: nil
        )
        button.setImage(image, for: .normal)
        button.tintColor = DesignSystemAsset.ColorAssests.grey5.color
        return button
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(
            named: "CancelMessageIcon",
            in: DesignSystemResources.bundle,
            with: nil
        )
        button.setImage(image, for: .normal)
        button.tintColor = DesignSystemAsset.ColorAssests.grey5.color
        return button
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        return label
    }()

    public init(messageText: String) {
        self.messageText = messageText
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        addSubviews()
        setLayout()
        configureBody()
        bindActions()
    }
}

extension MessageDetailModalViewController {
    private func addSubviews() {
        view.addSubview(dimmerView)
        view.addSubview(cardView)
        cardView.addSubview(topBar)
        topBar.addSubview(editButton)
        topBar.addSubview(closeButton)
        cardView.addSubview(bodyLabel)
    }

    private func setLayout() {
        dimmerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        cardView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.lessThanOrEqualTo(view.snp.height).multipliedBy(0.8)
        }

        topBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }

        editButton.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        closeButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        bodyLabel.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(24)
        }
    }

    private func configureBody() {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.5
        bodyLabel.attributedText = NSAttributedString(
            string: messageText,
            attributes: [
                .paragraphStyle: style,
                .font: DesignSystemFontFamily.Pretendard.regular.font(size: 14),
                .foregroundColor: DesignSystemAsset.ColorAssests.grey5.color
            ]
        )
    }

    private func bindActions() {
        let dimmerTap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        dimmerView.addGestureRecognizer(dimmerTap)
        closeButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(handleEditTap), for: .touchUpInside)
    }

    @objc private func handleDismiss() {
        dismiss(animated: true)
    }

    @objc private func handleEditTap() {
        let text = messageText
        let handler = onEditTap
        dismiss(animated: true) {
            handler?(text)
        }
    }
}
