import UIKit
import SnapKit

import DesignSystem

final class PreviewGuideBannerView: UIView {

    // MARK: - UI

    private let containerView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: MyMessagesPreviewMetrics.bannerBackgroundColor
        )
        view.waveCornerRadius = MyMessagesPreviewMetrics.bannerCornerRadius
        view.waveSpacing = MyMessagesPreviewMetrics.bannerWaveSpacing
        view.waveAmplitude = MyMessagesPreviewMetrics.bannerWaveAmplitude
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(message: String) {
        messageLabel.attributedText = MyMessagesPreviewMetrics.attributedString(
            message,
            font: MyMessagesPreviewMetrics.bannerFont,
            color: MyMessagesPreviewMetrics.bannerTextColor,
            alignment: .center
        )
    }
}

// MARK: - Subviews

extension PreviewGuideBannerView {
    private func addSubviews() {
        addSubview(containerView)
        containerView.addSubview(messageLabel)
    }

    private func setLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        messageLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(MyMessagesPreviewMetrics.bannerContentVerticalPadding)
            $0.leading.trailing.equalToSuperview().inset(MyMessagesPreviewMetrics.bannerContentHorizontalPadding)
        }
    }
}
