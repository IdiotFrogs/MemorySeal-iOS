import UIKit
import SnapKit

import DesignSystem

final class MemoryTextBubbleCell: UITableViewCell {

    static let identifier = String(describing: MemoryTextBubbleCell.self)

    // MARK: - UI

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        imageView.layer.cornerRadius = MemoryMessageMetrics.feedAvatarSize / 2
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = MemoryMessageMetrics.feedNameFont
        label.textColor = MemoryMessageMetrics.nameTextColor
        return label
    }()

    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = MemoryMessageMetrics.bubbleCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Constraints

    private var nameTopConstraint: Constraint?
    private var bubbleLeadingConstraint: Constraint?
    private var bubbleTrailingConstraint: Constraint?
    private var bubbleTopToNameConstraint: Constraint?
    private var bubbleTopToContentConstraint: Constraint?

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
        nameLabel.text = nil
        avatarImageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
    }

    // MARK: - Configure

    func configure(message: MemoryMessage, participant: MemoryParticipant, showAvatarAndName: Bool, topSpacing: CGFloat) {
        let text: String
        if case let .text(value) = message.content {
            text = value
        } else {
            text = ""
        }
        bodyLabel.attributedText = Self.bodyAttributedString(text)

        nameTopConstraint?.update(offset: topSpacing)
        bubbleTopToContentConstraint?.update(offset: topSpacing)
        bubbleView.backgroundColor = message.isMine
            ? MemoryMessageMetrics.bubbleMineColor
            : MemoryMessageMetrics.bubbleIncomingColor

        if message.isMine {
            avatarImageView.isHidden = true
            nameLabel.isHidden = true
            bubbleLeadingConstraint?.deactivate()
            bubbleTrailingConstraint?.activate()
            bubbleTopToNameConstraint?.deactivate()
            bubbleTopToContentConstraint?.activate()
        } else {
            avatarImageView.isHidden = !showAvatarAndName
            nameLabel.isHidden = !showAvatarAndName
            nameLabel.text = showAvatarAndName ? participant.name : nil
            avatarImageView.image = participant.displayImage
            bubbleTrailingConstraint?.deactivate()
            bubbleLeadingConstraint?.activate()
            if showAvatarAndName {
                bubbleTopToContentConstraint?.deactivate()
                bubbleTopToNameConstraint?.activate()
            } else {
                bubbleTopToNameConstraint?.deactivate()
                bubbleTopToContentConstraint?.activate()
            }
        }
    }

    static func bodyAttributedString(_ text: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = MemoryMessageMetrics.bodyLineHeightMultiple
        return NSAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: style,
                .font: MemoryMessageMetrics.bodyFont,
                .foregroundColor: MemoryMessageMetrics.bodyTextColor
            ]
        )
    }
}

// MARK: - Subviews

extension MemoryTextBubbleCell {
    private func addSubviews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(bodyLabel)
    }

    private func setLayout() {
        let leading = MemoryMessageMetrics.feedLeftInset
        let bubbleLeading = leading + MemoryMessageMetrics.feedAvatarSize + MemoryMessageMetrics.intraGroupSpacing

        avatarImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(leading)
            $0.top.equalTo(bubbleView.snp.top)
            $0.width.height.equalTo(MemoryMessageMetrics.feedAvatarSize)
        }

        nameLabel.snp.makeConstraints {
            self.nameTopConstraint = $0.top.equalToSuperview().constraint
            $0.leading.equalToSuperview().offset(bubbleLeading)
        }

        bubbleView.snp.makeConstraints {
            $0.width.equalTo(MemoryMessageMetrics.contentColumnWidth)
            $0.bottom.equalToSuperview()
            self.bubbleLeadingConstraint = $0.leading.equalToSuperview().offset(bubbleLeading).constraint
            self.bubbleTrailingConstraint = $0.trailing.equalToSuperview().inset(MemoryMessageMetrics.feedRightInset).constraint
            self.bubbleTopToNameConstraint = $0.top.equalTo(nameLabel.snp.bottom).offset(MemoryMessageMetrics.intraGroupSpacing).constraint
            self.bubbleTopToContentConstraint = $0.top.equalToSuperview().constraint
        }

        bodyLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(MemoryMessageMetrics.bubblePadding)
        }

        bubbleTrailingConstraint?.deactivate()
        bubbleTopToContentConstraint?.deactivate()
    }
}
