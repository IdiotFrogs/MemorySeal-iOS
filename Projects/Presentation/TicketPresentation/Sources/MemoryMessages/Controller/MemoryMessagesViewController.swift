import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class MemoryMessagesViewController: UIViewController {

    // MARK: - Row

    private struct Row {
        let message: MemoryMessage
        let participant: MemoryParticipant
        let showAvatarAndName: Bool
        let topSpacing: CGFloat
    }

    // MARK: - Properties

    private let viewModel: MemoryMessagesViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let rxViewDidLoad: PublishRelay<Void> = .init()

    private var participants: [MemoryParticipant] = []
    private var sections: [[Row]] = []
    private var isProgrammaticScrolling: Bool = false
    private var didSetInitialOffset: Bool = false

    // MARK: - UI

    private let headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("추억 메시지")
        view.setTitleFont(MemoryMessageMetrics.titleFont)
        return view
    }()

    private let profileBarView: MemoryProfileBarView = MemoryProfileBarView()

    private let headerSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = MemoryMessageMetrics.headerBorderColor
        return view
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.decelerationRate = .fast
        view.estimatedRowHeight = 120
        view.rowHeight = UITableView.automaticDimension
        view.contentInsetAdjustmentBehavior = .never
        view.register(MemoryTextBubbleCell.self, forCellReuseIdentifier: MemoryTextBubbleCell.identifier)
        view.register(MemoryPhotoCardCell.self, forCellReuseIdentifier: MemoryPhotoCardCell.identifier)
        view.dataSource = self
        view.delegate = self
        return view
    }()

    // MARK: - Init

    public init(with viewModel: MemoryMessagesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        setInitialValues()
        addSubviews()
        setLayout()
        bindViewModel()
        rxViewDidLoad.accept(())
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBottomInsetForCentering()
        if !didSetInitialOffset, !sections.isEmpty, tableView.bounds.height > 0 {
            didSetInitialOffset = true
            tableView.setContentOffset(.zero, animated: false)
            profileBarView.setFocusedIndex(0, animated: false)
        }
    }
}

// MARK: - Setup

extension MemoryMessagesViewController {
    private func setInitialValues() {
        profileBarView.onSelect = { [weak self] index in
            self?.scrollToSection(index, animated: true)
        }
    }

    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(headerContainerView)
        headerContainerView.addSubview(navigationView)
        headerContainerView.addSubview(profileBarView)
        headerContainerView.addSubview(headerSeparatorView)
    }

    private func setLayout() {
        headerContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(MemoryMessageMetrics.navigationBarHeight)
        }
        profileBarView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(MemoryMessageMetrics.headerStackSpacing)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(MemoryMessageMetrics.focusedRingSize + MemoryMessageMetrics.profileItemSpacing + 16)
        }
        headerSeparatorView.snp.makeConstraints {
            $0.top.equalTo(profileBarView.snp.bottom).offset(MemoryMessageMetrics.headerBottomPadding)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerContainerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    private func bindViewModel() {
        let input = MemoryMessagesViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            backButtonDidTap: navigationView.backButtonDidTap
        )
        let output = viewModel.transform(input)

        output.conversations
            .drive(onNext: { [weak self] conversations in
                self?.apply(conversations: conversations)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Data

extension MemoryMessagesViewController {
    private func apply(conversations: [MemoryConversation]) {
        participants = conversations.map { $0.participant }
        sections = conversations.map { Self.makeRows(from: $0) }
        profileBarView.configure(participants: participants, focusedIndex: 0)
        tableView.reloadData()
    }

    private static func makeRows(from conversation: MemoryConversation) -> [Row] {
        conversation.messages.enumerated().map { index, message in
            let previous = index > 0 ? conversation.messages[index - 1] : nil
            let senderChanged = previous == nil || previous?.isMine != message.isMine

            let topSpacing: CGFloat
            if index == 0 {
                topSpacing = MemoryMessageMetrics.feedTopInset
            } else if senderChanged {
                topSpacing = MemoryMessageMetrics.groupSpacing
            } else {
                topSpacing = MemoryMessageMetrics.intraGroupSpacing
            }

            let showAvatarAndName = !message.isMine && senderChanged

            return Row(
                message: message,
                participant: conversation.participant,
                showAvatarAndName: showAvatarAndName,
                topSpacing: topSpacing
            )
        }
    }
}

// MARK: - UITableViewDataSource

extension MemoryMessagesViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section][indexPath.row]

        switch row.message.content {
        case .text:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MemoryTextBubbleCell.identifier,
                for: indexPath
            ) as? MemoryTextBubbleCell ?? MemoryTextBubbleCell()
            cell.configure(
                message: row.message,
                participant: row.participant,
                showAvatarAndName: row.showAvatarAndName,
                topSpacing: row.topSpacing
            )
            return cell
        case .photo:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MemoryPhotoCardCell.identifier,
                for: indexPath
            ) as? MemoryPhotoCardCell ?? MemoryPhotoCardCell()
            cell.configure(message: row.message, topSpacing: row.topSpacing)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate / Snapping

extension MemoryMessagesViewController: UITableViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isProgrammaticScrolling else { return }
        updateFocusedProfile()
    }

    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let tops = sectionTops()
        guard !tops.isEmpty else { return }

        let current = scrollView.contentOffset.y
        let proposed = targetContentOffset.pointee.y
        let threshold: CGFloat = 1

        let target: CGFloat
        if velocity.y > 0.2 {
            target = tops.first(where: { $0 > current + threshold }) ?? tops.last ?? current
        } else if velocity.y < -0.2 {
            target = tops.last(where: { $0 < current - threshold }) ?? tops.first ?? current
        } else {
            target = tops.min(by: { abs($0 - proposed) < abs($1 - proposed) }) ?? proposed
        }

        let maxOffset = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.height
        targetContentOffset.pointee.y = min(max(target, -scrollView.contentInset.top), max(maxOffset, 0))
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isProgrammaticScrolling = false
        updateFocusedProfile()
    }
}

// MARK: - Focus / Section Helpers

extension MemoryMessagesViewController {
    private func sectionTops() -> [CGFloat] {
        (0..<tableView.numberOfSections).map { tableView.rect(forSection: $0).minY }
    }

    private func updateFocusedProfile() {
        let tops = sectionTops()
        guard !tops.isEmpty else { return }
        let offset = tableView.contentOffset.y
        var nearest = 0
        var minDistance = CGFloat.greatestFiniteMagnitude
        for (index, top) in tops.enumerated() {
            let distance = abs(top - offset)
            if distance < minDistance {
                minDistance = distance
                nearest = index
            }
        }
        profileBarView.setFocusedIndex(nearest, animated: true)
    }

    private func scrollToSection(_ section: Int, animated: Bool) {
        guard section < tableView.numberOfSections else { return }
        profileBarView.setFocusedIndex(section, animated: animated)
        let top = tableView.rect(forSection: section).minY
        let maxOffset = tableView.contentSize.height + tableView.contentInset.bottom - tableView.bounds.height
        let target = min(max(top, -tableView.contentInset.top), max(maxOffset, 0))
        isProgrammaticScrolling = true
        tableView.setContentOffset(CGPoint(x: 0, y: target), animated: animated)
    }

    private func updateBottomInsetForCentering() {
        guard tableView.numberOfSections > 0, tableView.bounds.height > 0 else { return }
        let lastSection = tableView.numberOfSections - 1
        let lastRect = tableView.rect(forSection: lastSection)
        let needed = max(MemoryMessageMetrics.feedBottomInset, tableView.bounds.height - lastRect.height)
        if abs(tableView.contentInset.bottom - needed) > 0.5 {
            tableView.contentInset.bottom = needed
        }
    }
}
