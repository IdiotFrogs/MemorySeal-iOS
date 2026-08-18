import UIKit
import SnapKit
import Kingfisher

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
        view.alpha = 0
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
        let placeholder = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        if let profileImageUrl = participant.profileImageUrl, let url = URL(string: profileImageUrl) {
            avatarImageView.kf.setImage(with: url, placeholder: placeholder)
        } else {
            avatarImageView.image = placeholder
        }
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
            $0.center.equalToSuperview()
            $0.width.height.equalTo(MemoryMessageMetrics.focusedRingSize)
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
        let ringScale = avatarSize / MemoryMessageMetrics.focusedRingSize
        let duration = MemoryMessageMetrics.selectionAnimationDuration

        containerSizeConstraint?.update(offset: containerSize)
        avatarSizeConstraint?.update(offset: avatarSize)
        nameLabel.font = isItemFocused
            ? MemoryMessageMetrics.focusedNameFont
            : MemoryMessageMetrics.unfocusedNameFont

        let nameWidth = nameLabel.intrinsicContentSize.width
        widthConstraint?.update(offset: max(containerSize, nameWidth))

        animateCornerRadius(to: avatarSize / 2, duration: animated ? duration : 0)

        let updates: () -> Void = { [weak self] in
            guard let self else { return }
            self.ringView.transform = CGAffineTransform(scaleX: ringScale, y: ringScale)
            self.ringView.alpha = self.isItemFocused ? 1 : 0
            self.superview?.layoutIfNeeded()
        }
        if animated {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState],
                animations: updates
            )
        } else {
            updates()
        }
    }

    private func animateCornerRadius(to radius: CGFloat, duration: TimeInterval) {
        guard duration > 0 else {
            avatarImageView.layer.removeAnimation(forKey: "cornerRadius")
            avatarImageView.layer.cornerRadius = radius
            return
        }

        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.fromValue = avatarImageView.layer.presentation()?.cornerRadius
            ?? avatarImageView.layer.cornerRadius
        animation.toValue = radius
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        avatarImageView.layer.add(animation, forKey: "cornerRadius")
        avatarImageView.layer.cornerRadius = radius
    }
}
