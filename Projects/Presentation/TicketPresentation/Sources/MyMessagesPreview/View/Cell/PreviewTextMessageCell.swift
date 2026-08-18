import UIKit
import SnapKit

import DesignSystem

final class PreviewTextMessageCell: UITableViewCell {

    static let identifier = String(describing: PreviewTextMessageCell.self)

    // MARK: - UI

    private let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = MyMessagesPreviewMetrics.bubbleColor
        view.layer.cornerRadius = MyMessagesPreviewMetrics.bubbleCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bodyLabel.attributedText = nil
    }

    // MARK: - Configure

    func configure(text: String) {
        bodyLabel.attributedText = MyMessagesPreviewMetrics.attributedString(
            text,
            font: MyMessagesPreviewMetrics.bodyFont,
            color: MyMessagesPreviewMetrics.bodyTextColor,
            alignment: .left
        )
    }
}

// MARK: - Subviews

extension PreviewTextMessageCell {
    private func addSubviews() {
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(bodyLabel)
    }

    private func setLayout() {
        bubbleView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(MyMessagesPreviewMetrics.contentSpacing)
            $0.trailing.equalToSuperview().inset(MyMessagesPreviewMetrics.feedTrailingInset)
            $0.width.equalTo(MyMessagesPreviewMetrics.contentColumnWidth)
        }
        bodyLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(MyMessagesPreviewMetrics.bubblePadding)
        }
    }
}
