import UIKit
import SnapKit

import DesignSystem

final class MemoryProfileBarView: UIView {

    // MARK: - Properties

    private static let reachEndThreshold: CGFloat = 80

    var onSelect: ((Int) -> Void)?
    var onReachEnd: (() -> Void)?

    private var itemViews: [MemoryProfileItemView] = []
    private(set) var selectedIndex: Int?

    // MARK: - UI

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceHorizontal = true
        view.clipsToBounds = false
        view.delegate = self
        return view
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = MemoryMessageMetrics.profileBarSpacing
        return stack
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

    func configure(participants: [MemoryParticipant]) {
        if participants.count < itemViews.count {
            resetItems()
        }

        for (index, participant) in participants.enumerated() {
            if index < itemViews.count {
                itemViews[index].configure(participant: participant)
            } else {
                appendItem(participant: participant, index: index)
            }
        }

        applySelection(animated: false)
    }

    func setSelectedIndex(_ index: Int?, animated: Bool) {
        guard selectedIndex != index else { return }
        selectedIndex = index
        applySelection(animated: animated)

        if let index {
            scrollItemToVisible(index: index, animated: animated)
        }
    }
}

// MARK: - Items

extension MemoryProfileBarView {
    private func resetItems() {
        itemViews.forEach {
            contentStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        itemViews.removeAll()
    }

    private func appendItem(participant: MemoryParticipant, index: Int) {
        let itemView = MemoryProfileItemView()
        itemView.configure(participant: participant)
        itemView.tag = index
        itemView.isUserInteractionEnabled = true
        itemView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleItemTap(_:)))
        )
        contentStackView.addArrangedSubview(itemView)
        itemViews.append(itemView)
    }

    private func applySelection(animated: Bool) {
        for (index, itemView) in itemViews.enumerated() {
            itemView.setFocused(index == selectedIndex, animated: animated)
        }
    }

    private func scrollItemToVisible(index: Int, animated: Bool) {
        guard itemViews.indices.contains(index) else { return }
        let target = itemViews[index]
        let rect = target.convert(target.bounds, to: scrollView)
        scrollView.scrollRectToVisible(
            rect.insetBy(dx: -MemoryMessageMetrics.profileBarHorizontalInset, dy: 0),
            animated: animated
        )
    }
}

// MARK: - Actions

extension MemoryProfileBarView {
    @objc private func handleItemTap(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        onSelect?(index)
    }
}

// MARK: - UIScrollViewDelegate

extension MemoryProfileBarView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let distanceToEnd = scrollView.contentSize.width
            - scrollView.contentOffset.x
            - scrollView.bounds.width

        guard scrollView.contentSize.width > 0,
              distanceToEnd < Self.reachEndThreshold
        else {
            return
        }

        onReachEnd?()
    }
}

// MARK: - Subviews

extension MemoryProfileBarView {
    private func addSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStackView)
    }

    private func setLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(MemoryMessageMetrics.profileBarHorizontalInset)
            $0.trailing.equalToSuperview().inset(MemoryMessageMetrics.profileBarHorizontalInset)
            $0.height.equalTo(scrollView.frameLayoutGuide)
        }
    }
}
