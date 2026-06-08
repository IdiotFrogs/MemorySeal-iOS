import UIKit
import SnapKit

import DesignSystem
import TicketDomain

// MARK: - MessageTextCardCell

public final class MessageTextCardCell: UICollectionViewCell {

    private let selectionIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    private let rowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0).cgColor
        view.clipsToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        label.textColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1.0)
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        label.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        return stack
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setLayout()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        bodyLabel.attributedText = nil
        bodyLabel.text = nil
        selectionIconView.isHidden = true
        selectionIconView.image = nil
    }

    public func configure(with content: CapsuleContent, index: Int) {
        titleLabel.text = "메세지 \(index)"

        let text: String
        if case .text(_, let value) = content {
            text = value
        } else {
            text = ""
        }

        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.5
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: style,
            .font: DesignSystemFontFamily.Pretendard.regular.font(size: 14),
            .foregroundColor: UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0)
        ]
        bodyLabel.attributedText = NSAttributedString(
            string: text,
            attributes: attributes
        )
    }

    public func setSelection(isSelectionMode: Bool, isSelected: Bool) {
        selectionIconView.isHidden = !isSelectionMode
        guard isSelectionMode else {
            selectionIconView.image = nil
            return
        }
        let name = isSelected ? "MessageSelectedIcon" : "MessageUnselectedIcon"
        selectionIconView.image = UIImage(
            named: name,
            in: DesignSystemResources.bundle,
            with: nil
        )
    }
}

// MARK: - Subviews

extension MessageTextCardCell {
    private func addSubviews() {
        contentView.addSubview(rowStack)
        rowStack.addArrangedSubview(selectionIconView)
        rowStack.addArrangedSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(bodyLabel)
    }
}

// MARK: - Layout

extension MessageTextCardCell {
    private func setLayout() {
        rowStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        selectionIconView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
