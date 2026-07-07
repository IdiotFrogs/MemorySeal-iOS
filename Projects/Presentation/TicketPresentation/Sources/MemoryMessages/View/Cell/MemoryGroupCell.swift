import UIKit
import SnapKit
import Kingfisher

import DesignSystem

final class MemoryGroupCell: UITableViewCell {

    static let identifier = String(describing: MemoryGroupCell.self)

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

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = MemoryMessageMetrics.intraGroupSpacing
        return stack
    }()

    // MARK: - Constraints

    private var contentLeadingConstraint: Constraint?
    private var contentTrailingConstraint: Constraint?

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
        nameLabel.text = nil
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        removeContentItems()
    }

    // MARK: - Configure

    func configure(group: MemoryGroup) {
        nameLabel.isHidden = group.isMine
        avatarImageView.isHidden = group.isMine
        if !group.isMine {
            nameLabel.text = group.participant.name
            let placeholder = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
            if let profileImageUrl = group.participant.profileImageUrl, let url = URL(string: profileImageUrl) {
                avatarImageView.kf.setImage(with: url, placeholder: placeholder)
            } else {
                avatarImageView.image = placeholder
            }
        }

        contentStack.alignment = group.isMine ? .trailing : .leading

        removeContentItems()
        for content in group.contents {
            switch content {
            case .text(let text):
                contentStack.addArrangedSubview(makeTextBubble(text, isMine: group.isMine))
            case .photo(let imageUrls):
                let gridView = MemoryPhotoGridView()
                gridView.configure(imageUrls: imageUrls)
                contentStack.addArrangedSubview(gridView)
                gridView.snp.makeConstraints {
                    $0.width.equalTo(MemoryMessageMetrics.contentColumnWidth)
                }
            }
        }

        if group.isMine {
            contentLeadingConstraint?.deactivate()
            contentTrailingConstraint?.activate()
        } else {
            contentTrailingConstraint?.deactivate()
            contentLeadingConstraint?.activate()
        }
    }

    private func removeContentItems() {
        contentStack.arrangedSubviews
            .filter { $0 !== nameLabel }
            .forEach { $0.removeFromSuperview() }
    }

    private func makeTextBubble(_ text: String, isMine: Bool) -> UIView {
        let bubbleView = UIView()
        bubbleView.layer.cornerRadius = MemoryMessageMetrics.bubbleCornerRadius
        bubbleView.clipsToBounds = true
        bubbleView.backgroundColor = isMine
            ? MemoryMessageMetrics.bubbleMineColor
            : MemoryMessageMetrics.bubbleIncomingColor

        let bodyLabel = UILabel()
        bodyLabel.numberOfLines = 0
        bodyLabel.attributedText = Self.bodyAttributedString(text)

        bubbleView.addSubview(bodyLabel)
        bubbleView.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(MemoryMessageMetrics.contentColumnWidth)
        }
        bodyLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(MemoryMessageMetrics.bubblePadding)
        }
        return bubbleView
    }

    static func bodyAttributedString(_ text: String) -> NSAttributedString {
        return NSAttributedString(
            string: text,
            attributes: [
                .font: MemoryMessageMetrics.bodyFont,
                .foregroundColor: MemoryMessageMetrics.bodyTextColor
            ]
        )
    }
}

// MARK: - Subviews

extension MemoryGroupCell {
    private func addSubviews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(contentStack)
        contentStack.addArrangedSubview(nameLabel)
    }

    private func setLayout() {
        avatarImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(MemoryMessageMetrics.feedLeftInset)
            $0.top.equalToSuperview().offset(MemoryMessageMetrics.groupSpacing)
            $0.width.height.equalTo(MemoryMessageMetrics.feedAvatarSize)
        }

        contentStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(MemoryMessageMetrics.groupSpacing)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(MemoryMessageMetrics.contentColumnWidth)
            self.contentLeadingConstraint = $0.leading
                .equalTo(avatarImageView.snp.trailing)
                .offset(MemoryMessageMetrics.intraGroupSpacing)
                .constraint
            self.contentTrailingConstraint = $0.trailing
                .equalToSuperview()
                .inset(MemoryMessageMetrics.feedRightInset)
                .constraint
        }

        contentTrailingConstraint?.deactivate()
    }
}
