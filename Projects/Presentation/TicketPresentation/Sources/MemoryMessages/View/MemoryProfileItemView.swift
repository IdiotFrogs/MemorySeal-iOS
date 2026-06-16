import UIKit
import SnapKit

import DesignSystem

final class MemoryProfileItemView: UIView {

    // MARK: - Properties

    private(set) var isItemFocused: Bool = false

    // MARK: - UI

    private let avatarContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        return imageView
    }()

    private let ringView: WavyStrokeView = {
        let view = WavyStrokeView(
            style: .stroked(
                color: MemoryMessageMetrics.focusRingColor,
                lineWidth: MemoryMessageMetrics.focusedRingLineWidth
            )
        )
        view.waveCornerRadius = MemoryMessageMetrics.focusedRingSize / 2
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = MemoryMessageMetrics.nameTextColor
        label.font = MemoryMessageMetrics.unfocusedNameFont
        label.textAlignment = .center
        return label
    }()

    // MARK: - Constraints

    private var widthConstraint: Constraint?
    private var containerSizeConstraint: Constraint?
    private var avatarSizeConstraint: Constraint?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setLayout()
        applyState(animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(participant: MemoryParticipant) {
        avatarImageView.image = participant.displayImage
        nameLabel.text = participant.name
        applyState(animated: false)
    }

    func setFocused(_ focused: Bool, animated: Bool) {
        guard isItemFocused != focused else { return }
        isItemFocused = focused
        applyState(animated: animated)
    }
}

// MARK: - Subviews

extension MemoryProfileItemView {
    private func addSubviews() {
        addSubview(avatarContainer)
        avatarContainer.addSubview(avatarImageView)
        avatarContainer.addSubview(ringView)
        addSubview(nameLabel)
    }

    private func setLayout() {
        snp.makeConstraints {
            self.widthConstraint = $0.width.equalTo(MemoryMessageMetrics.focusedRingSize).constraint
        }
        avatarContainer.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            self.containerSizeConstraint = $0.width.height.equalTo(MemoryMessageMetrics.focusedRingSize).constraint
        }
        avatarImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            self.avatarSizeConstraint = $0.width.height.equalTo(MemoryMessageMetrics.unfocusedAvatarSize).constraint
        }
        ringView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarContainer.snp.bottom).offset(MemoryMessageMetrics.profileItemSpacing)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - State

extension MemoryProfileItemView {
    private func applyState(animated: Bool) {
        let containerSize = isItemFocused
            ? MemoryMessageMetrics.focusedRingSize
            : MemoryMessageMetrics.unfocusedAvatarSize
        let avatarSize = isItemFocused
            ? MemoryMessageMetrics.focusedAvatarSize
            : MemoryMessageMetrics.unfocusedAvatarSize

        containerSizeConstraint?.update(offset: containerSize)
        avatarSizeConstraint?.update(offset: avatarSize)
        avatarImageView.layer.cornerRadius = avatarSize / 2
        nameLabel.font = isItemFocused
            ? MemoryMessageMetrics.focusedNameFont
            : MemoryMessageMetrics.unfocusedNameFont
        ringView.isHidden = !isItemFocused

        let nameWidth = nameLabel.intrinsicContentSize.width
        widthConstraint?.update(offset: max(containerSize, nameWidth))

        let updates: () -> Void = { [weak self] in
            guard let self else { return }
            self.superview?.layoutIfNeeded()
        }
        if animated {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: [.curveEaseInOut],
                animations: updates
            )
        } else {
            updates()
        }
    }
}
