import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class MyMessagesPreviewViewController: UIViewController {

    // MARK: - Properties

    private static let guideMessage: String = "미리보기는 자신이 등록한 내용만\n확인하실 수 있습니다."

    private let viewModel: MyMessagesPreviewViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let retryDidTap: PublishRelay<Void> = .init()

    private var contents: [PreviewMessageContent] = []
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
        view.setTitleFont(MyMessagesPreviewMetrics.titleFont)
        return view
    }()

    private let guideBannerView: PreviewGuideBannerView = PreviewGuideBannerView()

    private let bannerContainerView: UIView = UIView()

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.estimatedRowHeight = 200
        view.rowHeight = UITableView.automaticDimension
        view.contentInsetAdjustmentBehavior = .never
        view.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: MyMessagesPreviewMetrics.feedBottomInset,
            right: 0
        )
        view.register(PreviewTextMessageCell.self, forCellReuseIdentifier: PreviewTextMessageCell.identifier)
        view.register(PreviewPhotoMessageCell.self, forCellReuseIdentifier: PreviewPhotoMessageCell.identifier)
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

        setInitialValues()
        addSubviews()
        setLayout()
        bindViewModel()

        rxViewDidLoad.accept(())
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeTableHeaderView()
    }
}

// MARK: - Setup

extension MyMessagesPreviewViewController {
    private func setInitialValues() {
        guideBannerView.configure(message: Self.guideMessage)
        tableView.tableHeaderView = bannerContainerView
    }

    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(errorStackView)
        errorStackView.addArrangedSubview(errorLabel)
        errorStackView.addArrangedSubview(retryButton)
        view.addSubview(headerContainerView)
        headerContainerView.addSubview(navigationView)
        bannerContainerView.addSubview(guideBannerView)
    }

    private func setLayout() {
        headerContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(navigationView)
        }
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(MyMessagesPreviewMetrics.navigationBarHeight)
        }
        guideBannerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(MyMessagesPreviewMetrics.bannerVerticalPadding)
            $0.leading.trailing.equalToSuperview().inset(MyMessagesPreviewMetrics.bannerHorizontalInset)
            $0.bottom.equalToSuperview().inset(
                MyMessagesPreviewMetrics.bannerVerticalPadding + MyMessagesPreviewMetrics.feedTopInset
            )
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

// MARK: - Table Header

extension MyMessagesPreviewViewController {
    private func sizeTableHeaderView() {
        guard let headerView = tableView.tableHeaderView else { return }

        let targetWidth = tableView.bounds.width
        guard targetWidth > 0 else { return }

        headerView.frame.size.width = targetWidth
        headerView.layoutIfNeeded()

        let fittingHeight = headerView.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        guard headerView.frame.height != fittingHeight else { return }

        headerView.frame.size.height = fittingHeight
        tableView.tableHeaderView = headerView
    }
}

// MARK: - Data

extension MyMessagesPreviewViewController {
    private func apply(contents: [PreviewMessageContent]) {
        errorStackView.isHidden = true
        self.contents = contents
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
        emptyStateLabel.isHidden = !(didLoadOnce && contents.isEmpty && errorStackView.isHidden)
    }
}

// MARK: - UITableViewDataSource

extension MyMessagesPreviewViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch contents[indexPath.row] {
        case .text(let text):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PreviewTextMessageCell.identifier,
                for: indexPath
            ) as? PreviewTextMessageCell else {
                return UITableViewCell()
            }
            cell.configure(text: text)
            return cell
        case .photo(let imageUrls):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PreviewPhotoMessageCell.identifier,
                for: indexPath
            ) as? PreviewPhotoMessageCell else {
                return UITableViewCell()
            }
            cell.configure(imageUrls: imageUrls)
            return cell
        }
    }
}
