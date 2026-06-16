import UIKit
import SnapKit

import DesignSystem

final class MemoryProfileBarView: UIView {

    // MARK: - Properties

    var onSelect: ((Int) -> Void)?
    private var itemViews: [MemoryProfileItemView] = []
    private(set) var focusedIndex: Int = 0

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceHorizontal = true
        view.clipsToBounds = false
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

    func configure(participants: [MemoryParticipant], focusedIndex: Int = 0) {
        itemViews.forEach { $0.removeFromSuperview() }
        itemViews.removeAll()
        contentStackView.arrangedSubviews.forEach { contentStackView.removeArrangedSubview($0); $0.removeFromSuperview() }

        for (index, participant) in participants.enumerated() {
            let itemView = MemoryProfileItemView()
            itemView.configure(participant: participant)
            itemView.tag = index
            itemView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleItemTap(_:)))
            itemView.addGestureRecognizer(tap)
            contentStackView.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }

        self.focusedIndex = focusedIndex
        for (index, itemView) in itemViews.enumerated() {
            itemView.setFocused(index == focusedIndex, animated: false)
        }
    }

    func setFocusedIndex(_ index: Int, animated: Bool) {
        guard index != focusedIndex, itemViews.indices.contains(index) else { return }
        if itemViews.indices.contains(focusedIndex) {
            itemViews[focusedIndex].setFocused(false, animated: animated)
        }
        itemViews[index].setFocused(true, animated: animated)
        focusedIndex = index
        scrollItemToVisible(index: index, animated: animated)
    }
}

// MARK: - Actions

extension MemoryProfileBarView {
    @objc private func handleItemTap(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        onSelect?(index)
    }

    private func scrollItemToVisible(index: Int, animated: Bool) {
        guard itemViews.indices.contains(index) else { return }
        let target = itemViews[index]
        let rect = target.convert(target.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect.insetBy(dx: -MemoryMessageMetrics.profileBarHorizontalInset, dy: 0), animated: animated)
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
