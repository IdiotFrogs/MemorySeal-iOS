import UIKit
import SnapKit

import DesignSystem

final class MemoryPhotoCardCell: UITableViewCell {

    static let identifier = String(describing: MemoryPhotoCardCell.self)

    // MARK: - UI

    private let shadowContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = (UIColor(hex: "#494949") ?? .darkGray).cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = .zero
        return view
    }()

    private let imageContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = MemoryMessageMetrics.bubbleCornerRadius
        view.clipsToBounds = true
        view.backgroundColor = MemoryMessageMetrics.photoPlaceholderColor
        return view
    }()

    private let imageStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()

    // MARK: - Constraints

    private var topConstraint: Constraint?
    private var leadingConstraint: Constraint?
    private var trailingConstraint: Constraint?

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
        imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - Configure

    func configure(message: MemoryMessage, topSpacing: CGFloat) {
        guard case let .photo(count) = message.content else { return }

        imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for _ in 0..<max(1, count) {
            let imageView = UIImageView()
            imageView.backgroundColor = MemoryMessageMetrics.photoPlaceholderColor
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageStackView.addArrangedSubview(imageView)
        }

        topConstraint?.update(offset: topSpacing)

        if message.isMine {
            leadingConstraint?.deactivate()
            trailingConstraint?.activate()
        } else {
            trailingConstraint?.deactivate()
            leadingConstraint?.activate()
        }
    }
}

// MARK: - Subviews

extension MemoryPhotoCardCell {
    private func addSubviews() {
        contentView.addSubview(shadowContainer)
        shadowContainer.addSubview(imageContainer)
        imageContainer.addSubview(imageStackView)
    }

    private func setLayout() {
        let bubbleLeading = MemoryMessageMetrics.feedLeftInset
            + MemoryMessageMetrics.feedAvatarSize
            + MemoryMessageMetrics.intraGroupSpacing

        shadowContainer.snp.makeConstraints {
            self.topConstraint = $0.top.equalToSuperview().constraint
            $0.bottom.equalToSuperview()
            $0.width.equalTo(MemoryMessageMetrics.photoCardSize.width)
            $0.height.equalTo(MemoryMessageMetrics.photoCardSize.height)
            self.leadingConstraint = $0.leading.equalToSuperview().offset(bubbleLeading).constraint
            self.trailingConstraint = $0.trailing.equalToSuperview().inset(MemoryMessageMetrics.feedRightInset).constraint
        }
        imageContainer.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        imageStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        trailingConstraint?.deactivate()
    }
}
