import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class MyMessagesPreviewViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: MyMessagesPreviewViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let retryDidTap: PublishRelay<Void> = .init()

    private var group: MemoryGroup?
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
        view.setTitle("미리보기")
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
        view.estimatedRowHeight = 200
        view.rowHeight = UITableView.automaticDimension
        view.contentInsetAdjustmentBehavior = .never
        view.contentInset = UIEdgeInsets(
            top: MemoryMessageMetrics.feedTopInset,
            left: 0,
            bottom: MemoryMessageMetrics.feedBottomInset,
            right: 0
        )
        view.register(MemoryGroupCell.self, forCellReuseIdentifier: MemoryGroupCell.identifier)
        view.dataSource = self
        return view
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 작성한 메시지가 없어요"
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
        label.text = "미리보기를 불러오지 못했어요"
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

    public init(with viewModel: MyMessagesPreviewViewModel) {
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

        addSubviews()
        setLayout()
        bindViewModel()

        rxViewDidLoad.accept(())
    }
}

// MARK: - Setup

extension MyMessagesPreviewViewController {
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

        let input = MyMessagesPreviewViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            retryDidTap: retryDidTap,
            backButtonDidTap: navigationView.backButtonDidTap
        )
        let output = viewModel.transform(input)

        output.participant
            .drive(with: self) { (self, participant) in
                guard let participant else { return }
                self.profileBarView.configure(participants: [participant], focusedIndex: 0)
            }
            .disposed(by: disposeBag)

        output.contents
            .drive(with: self) { (self, contents) in
                self.apply(contents: contents)
            }
            .disposed(by: disposeBag)

        output.isLoading
            .drive(with: self) { (self, isLoading) in
                self.setLoading(isLoading)
            }
            .disposed(by: disposeBag)

        output.showError
            .emit(with: self) { (self, _) in
                self.showErrorState()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Data

extension MyMessagesPreviewViewController {
    private func apply(contents: [MemoryMessageContent]) {
        errorStackView.isHidden = true
        group = contents.isEmpty ? nil : MemoryGroup(
            participant: MemoryParticipant(id: 0, name: ""),
            isMine: true,
            contents: contents
        )
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
        emptyStateLabel.isHidden = !(didLoadOnce && group == nil && errorStackView.isHidden)
    }
}

// MARK: - UITableViewDataSource

extension MyMessagesPreviewViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group == nil ? 0 : 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let group,
              let cell = tableView.dequeueReusableCell(
                withIdentifier: MemoryGroupCell.identifier,
                for: indexPath
              ) as? MemoryGroupCell
        else {
            return UITableViewCell()
        }
        cell.configure(group: group)
        return cell
    }
}
