import UIKit
import SnapKit
import DesignSystem

// MARK: - MessageTypeBannerView

final class MessageTypeBannerView: UIView {
    var onPreviewTap: (() -> Void)?

    // MARK: - Subviews

    private let containerView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.primaryLight.color
        )
        view.waveCornerRadius = 12
        return view
    }()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.primaryNormal.color
        view.layer.cornerRadius = 22
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        label.textColor = DesignSystemAsset.ColorAssests.primaryDark.color
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        label.textColor = DesignSystemAsset.ColorAssests.primaryDark.color
        label.numberOfLines = 2
        return label
    }()

    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()

    private let previewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("미리보기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
        button.backgroundColor = DesignSystemAsset.ColorAssests.grey5.color
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setLayout()
        previewButton.addTarget(self, action: #selector(previewTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func update(for type: MyTicketMessageType) {
        switch type {
        case .text:
            titleLabel.text = "메세지"
            subtitleLabel.text = "말하고 싶은 메시지를 작성해보세요."
            iconImageView.image = DesignSystemAsset.ImageAssets.messageTextIcon.image
        case .photo:
            titleLabel.text = "사진"
            subtitleLabel.text = "공유하고 싶은 사진을 등록해보세요."
            iconImageView.image = DesignSystemAsset.ImageAssets.messagePhotoIcon.image
        }
    }

    @objc private func previewTapped() {
        onPreviewTap?()
    }
}

// MARK: - Layout

extension MessageTypeBannerView {
    private func addSubviews() {
        addSubview(containerView)
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        containerView.addSubview(textStack)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)
        containerView.addSubview(previewButton)
    }

    private func setLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
            $0.size.equalTo(44)
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }

        previewButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(32)
        }

        textStack.snp.makeConstraints {
            $0.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            $0.trailing.equalTo(previewButton.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().offset(16)
            $0.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
    }
}
