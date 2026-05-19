import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import DesignSystem

// MARK: - MyMemoryMessageListViewController

public final class MyMemoryMessageListViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: MyMemoryMessagesViewModel
    private let type: MyMemoryMessageType
    private let disposeBag: DisposeBag = DisposeBag()
    private var items: [MyMemoryMessage] = []

    // MARK: - UI

    private let bannerView: MessageTypeBannerView = MessageTypeBannerView()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        view.backgroundColor = .clear
        view.register(
            MessageTextCardCell.self,
            forCellWithReuseIdentifier: String(describing: MessageTextCardCell.self)
        )
        view.register(
            MessagePhotoCardCell.self,
            forCellWithReuseIdentifier: String(describing: MessagePhotoCardCell.self)
        )
        view.dataSource = self
        return view
    }()

    // MARK: - Init

    public init(type: MyMemoryMessageType, viewModel: MyMemoryMessagesViewModel) {
        self.type = type
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setInitialValues()
        addSubviews()
        setLayout()
        bindViewModel()
        bindButton()
    }
}

// MARK: - Setup

extension MyMemoryMessageListViewController {
    private func setInitialValues() {
        view.backgroundColor = .white
        bannerView.update(for: type)
    }

    private func addSubviews() {
        view.addSubview(bannerView)
        view.addSubview(collectionView)
    }

    private func setLayout() {
        bannerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(120)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(bannerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - Binding

extension MyMemoryMessageListViewController {
    private func bindViewModel() {
        viewModel.messages(of: type)
            .drive(onNext: { [weak self] items in
                self?.items = items
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    private func bindButton() {
        bannerView.onPreviewTap = { [weak self] in
            self?.showBannerPreview()
        }
    }
}

// MARK: - Preview

extension MyMemoryMessageListViewController {
    private func showBannerPreview() {
        let title: String
        let body: String
        switch type {
        case .text:
            title = "메세지"
            body = "말하고 싶은 메시지를 작성해보세요."
        case .photo:
            title = "사진"
            body = "공유하고 싶은 사진을 등록해보세요."
        }
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "닫기", style: .default))
        present(alert, animated: true)
    }

    private func showItemPreview(for message: MyMemoryMessage) {
        let alert: UIAlertController
        switch message.type {
        case .text:
            alert = UIAlertController(
                title: "메시지 미리보기",
                message: message.textContent ?? "",
                preferredStyle: .alert
            )
        case .photo:
            alert = UIAlertController(
                title: "사진 미리보기",
                message: nil,
                preferredStyle: .alert
            )
        }
        alert.addAction(UIAlertAction(title: "닫기", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - DataSource

extension MyMemoryMessageListViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = items[indexPath.item]
        switch message.type {
        case .text:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: MessageTextCardCell.self),
                for: indexPath
            ) as? MessageTextCardCell
            cell?.configure(with: message, index: indexPath.item + 1)
            return cell ?? UICollectionViewCell()
        case .photo:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: MessagePhotoCardCell.self),
                for: indexPath
            ) as? MessagePhotoCardCell
            cell?.configure(with: message)
            cell?.onPreviewTap = { [weak self] in
                self?.showItemPreview(for: message)
            }
            return cell ?? UICollectionViewCell()
        }
    }
}

// MARK: - Layout Factory

extension MyMemoryMessageListViewController {
    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        switch type {
        case .text:
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)

            return UICollectionViewCompositionalLayout(section: section)

        case .photo:
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / 3.0),
                heightDimension: .fractionalWidth(1.0 / 3.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1.0 / 3.0)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 3
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)

            return UICollectionViewCompositionalLayout(section: section)
        }
    }
}
