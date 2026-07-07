import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class MemoryMessagesViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: MemoryMessagesViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let retryDidTap: PublishRelay<Void> = .init()

    private var participants: [MemoryParticipant] = []
    private var groups: [MemoryGroup] = []
    private var isProgrammaticScrolling: Bool = false
    private var didSetInitialOffset: Bool = false
    private var didLoadOnce: Bool = false
    private var loadingView: BasicLoadingView?

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
        view.estimatedRowHeight = 200
        view.rowHeight = UITableView.automaticDimension
        view.contentInsetAdjustmentBehavior = .never
        view.register(MemoryGroupCell.self, forCellReuseIdentifier: MemoryGroupCell.identifier)
        view.dataSource = self
        view.delegate = self
        return view
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 도착한 추억 메시지가 없어요"
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        label.textColor = DesignSystemAsset.ColorAssests.grey3.color
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let errorStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.isHidden = true
        return stack
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "추억 메시지를 불러오지 못했어요"
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        label.textColor = DesignSystemAsset.ColorAssests.grey4.color
        label.textAlignment = .center
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("다시 시도", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.backgroundColor = DesignSystemAsset.ColorAssests.primaryNormal.color
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
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
        if !didSetInitialOffset, !groups.isEmpty, tableView.bounds.height > 0 {
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
        view.addSubview(emptyStateLabel)
        view.addSubview(errorStackView)
        errorStackView.addArrangedSubview(errorLabel)
        errorStackView.addArrangedSubview(retryButton)
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
        emptyStateLabel.snp.makeConstraints {
            $0.center.equalTo(tableView)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        errorStackView.snp.makeConstraints {
            $0.center.equalTo(tableView)
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }
    }

    private func bindViewModel() {
        retryButton.rx.tap
            .bind(to: retryDidTap)
            .disposed(by: disposeBag)

        let input = MemoryMessagesViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            retryDidTap: retryDidTap,
            backButtonDidTap: navigationView.backButtonDidTap
        )
        let output = viewModel.transform(input)

        output.conversations
            .drive(onNext: { [weak self] conversations in
                self?.apply(conversations: conversations)
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                self?.setLoading(isLoading)
            })
            .disposed(by: disposeBag)

        output.showError
            .emit(onNext: { [weak self] in
                self?.showErrorState()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Data

extension MemoryMessagesViewController {
    private func apply(conversations: [MemoryConversation]) {
        errorStackView.isHidden = true
        participants = conversations.map { $0.participant }
        groups = conversations.map { Self.makeGroup(from: $0) }
        profileBarView.configure(participants: participants, focusedIndex: 0)
        tableView.reloadData()
        updateEmptyState()
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            errorStackView.isHidden = true
            emptyStateLabel.isHidden = true
            if loadingView == nil {
                loadingView = BasicLoadingView.show(on: view)
            }
        } else {
            loadingView?.hide()
            loadingView = nil
            didLoadOnce = true
            updateEmptyState()
        }
    }

    private func showErrorState() {
        didLoadOnce = true
        emptyStateLabel.isHidden = true
        errorStackView.isHidden = false
    }

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !(didLoadOnce && groups.isEmpty && errorStackView.isHidden)
    }

    private static func makeGroup(from conversation: MemoryConversation) -> MemoryGroup {
        MemoryGroup(
            participant: conversation.participant,
            isMine: conversation.isMine,
            contents: conversation.messages.map { $0.content }
        )
    }
}

// MARK: - UITableViewDataSource

extension MemoryMessagesViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        groups.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MemoryGroupCell.identifier,
            for: indexPath
        ) as? MemoryGroupCell ?? MemoryGroupCell()
        cell.configure(group: groups[indexPath.section])
        return cell
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

        let viewportHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let maxOffset = max(contentHeight + scrollView.contentInset.bottom - viewportHeight, 0)
        let minOffset = -scrollView.contentInset.top

        let current = scrollView.contentOffset.y
        let proposed = targetContentOffset.pointee.y
        let epsilon: CGFloat = 1

        let section = sectionIndex(forOffset: current, tops: tops)
        let sectionTop = tops[section]
        let sectionBottom = section + 1 < tops.count ? tops[section + 1] : contentHeight
        let maxWithinSection = max(sectionTop, sectionBottom - viewportHeight)

        let target: CGFloat
        if velocity.y > 0.2 {
            if current >= maxWithinSection - epsilon {
                target = section + 1 < tops.count ? tops[section + 1] : maxOffset
            } else {
                target = min(proposed, maxWithinSection)
            }
        } else if velocity.y < -0.2 {
            if current <= sectionTop + epsilon {
                target = section - 1 >= 0 ? tops[section - 1] : minOffset
            } else {
                target = max(proposed, sectionTop)
            }
        } else {
            target = min(max(proposed, sectionTop), maxWithinSection)
        }

        targetContentOffset.pointee.y = min(max(target, minOffset), maxOffset)
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

    private func sectionIndex(forOffset offset: CGFloat, tops: [CGFloat]) -> Int {
        var index = 0
        for (i, top) in tops.enumerated() where top <= offset + 1 {
            index = i
        }
        return index
    }

    private func updateFocusedProfile() {
        let tops = sectionTops()
        guard !tops.isEmpty else { return }
        let index = sectionIndex(forOffset: tableView.contentOffset.y, tops: tops)
        profileBarView.setFocusedIndex(index, animated: true)
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
