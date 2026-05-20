import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

import DesignSystem
import MemoryDomain

// MARK: - MyMemoryMessageListViewController

public final class MyMemoryMessageListViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: MyMemoryMessagesViewModel
    private let type: MyMemoryMessageType
    private let disposeBag: DisposeBag = DisposeBag()

    private var textItems: [CapsuleContent] = []
    private var photoUrls: [String] = []

    private var isSelectionMode: Bool = false
    private var selectedTextIds: Set<Int> = []
    private var selectedPhotoUrls: Set<String> = []

    public var onSelectionModeChanged: ((Bool) -> Void)?

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
        view.delegate = self
        return view
    }()

    private let actionBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.setTitleColor(UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1.0), for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0).cgColor
        button.clipsToBounds = true
        return button
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("삭제", for: .normal)
        button.setTitleColor(UIColor(red: 218/255, green: 27/255, blue: 27/255, alpha: 0.35), for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.backgroundColor = UIColor(red: 243/255, green: 187/255, blue: 187/255, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor(red: 243/255, green: 187/255, blue: 187/255, alpha: 1.0).cgColor
        button.clipsToBounds = true
        return button
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

    // MARK: - Public

    public func enterSelectionMode() {
        guard !isSelectionMode else { return }
        isSelectionMode = true
        selectedTextIds.removeAll()
        selectedPhotoUrls.removeAll()
        actionBarView.isHidden = false
        updateDeleteButtonState()
        updateCollectionViewLayoutConstraints()
        collectionView.reloadData()
        onSelectionModeChanged?(true)
    }

    public func exitSelectionMode() {
        guard isSelectionMode else { return }
        isSelectionMode = false
        selectedTextIds.removeAll()
        selectedPhotoUrls.removeAll()
        actionBarView.isHidden = true
        updateCollectionViewLayoutConstraints()
        collectionView.reloadData()
        onSelectionModeChanged?(false)
    }

    public var isInSelectionMode: Bool {
        return isSelectionMode
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
        view.addSubview(actionBarView)
        actionBarView.addSubview(cancelButton)
        actionBarView.addSubview(deleteButton)
    }

    private func setLayout() {
        bannerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(120)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        actionBarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(80)
        }

        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }

        deleteButton.snp.makeConstraints {
            $0.leading.equalTo(cancelButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(16)
            $0.height.equalTo(48)
            $0.width.equalTo(cancelButton)
        }

        updateCollectionViewLayoutConstraints()
    }

    private func updateCollectionViewLayoutConstraints() {
        collectionView.snp.remakeConstraints {
            $0.top.equalTo(bannerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            if isSelectionMode {
                $0.bottom.equalTo(actionBarView.snp.top)
            } else {
                $0.bottom.equalToSuperview()
            }
        }
    }
}

// MARK: - Binding

extension MyMemoryMessageListViewController {
    private func bindViewModel() {
        switch type {
        case .text:
            viewModel.textContents()
                .drive(onNext: { [weak self] items in
                    guard let self else { return }
                    self.textItems = items
                    let validIds = Set(items.map { $0.id })
                    self.selectedTextIds = self.selectedTextIds.intersection(validIds)
                    self.updateDeleteButtonState()
                    self.collectionView.reloadData()
                })
                .disposed(by: disposeBag)
        case .photo:
            viewModel.photoImageUrls()
                .drive(onNext: { [weak self] urls in
                    guard let self else { return }
                    self.photoUrls = urls
                    let validUrls = Set(urls)
                    self.selectedPhotoUrls = self.selectedPhotoUrls.intersection(validUrls)
                    self.updateDeleteButtonState()
                    self.collectionView.reloadData()
                })
                .disposed(by: disposeBag)
        }
    }

    private func bindButton() {
        bannerView.onPreviewTap = { [weak self] in
            self?.showBannerPreview()
        }

        cancelButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.exitSelectionMode()
            })
            .disposed(by: disposeBag)

        deleteButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.handleDeleteTap()
            })
            .disposed(by: disposeBag)
    }

    private func handleDeleteTap() {
        switch type {
        case .text:
            guard !selectedTextIds.isEmpty else { return }
            viewModel.deleteTextContents(selectedTextIds)
        case .photo:
            guard !selectedPhotoUrls.isEmpty else { return }
            viewModel.deletePhotoUrls(selectedPhotoUrls)
        }
        exitSelectionMode()
    }

    private func updateDeleteButtonState() {
        let hasSelection: Bool = {
            switch type {
            case .text: return !selectedTextIds.isEmpty
            case .photo: return !selectedPhotoUrls.isEmpty
            }
        }()
        deleteButton.isEnabled = hasSelection
        let activeColor = UIColor(red: 237/255, green: 30/255, blue: 47/255, alpha: 1.0)
        let disabledColor = UIColor(red: 243/255, green: 187/255, blue: 187/255, alpha: 1.0)
        if hasSelection {
            deleteButton.backgroundColor = activeColor
            deleteButton.layer.borderColor = activeColor.cgColor
            deleteButton.setTitleColor(.white, for: .normal)
        } else {
            deleteButton.backgroundColor = disabledColor
            deleteButton.layer.borderColor = disabledColor.cgColor
            deleteButton.setTitleColor(UIColor(red: 218/255, green: 27/255, blue: 27/255, alpha: 0.35), for: .normal)
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

    private func showTextPreview(for content: CapsuleContent) {
        guard case .text(_, let value) = content else { return }
        let modal = MessageDetailModalViewController(messageText: value)
        modal.onEditTap = { [weak self] text in
            guard let self else { return }
            let sheet = MessageInputBottomSheet(initialText: text)
            sheet.didSubmitText
                .subscribe(onNext: { [weak self] newText in
                    let updated = MyMemoryMessage(type: .text, textContent: newText, imageData: nil)
                    self?.viewModel.appendMessage(updated)
                })
                .disposed(by: self.disposeBag)
            self.present(sheet, animated: true)
        }
        present(modal, animated: true)
    }

    private func showPhotoPreview() {
        let alert = UIAlertController(
            title: "사진 미리보기",
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "닫기", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Delegate

extension MyMemoryMessageListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch type {
        case .text:
            guard indexPath.item < textItems.count else { return }
            let content = textItems[indexPath.item]
            let contentId = content.id
            if isSelectionMode {
                if selectedTextIds.contains(contentId) {
                    selectedTextIds.remove(contentId)
                } else {
                    selectedTextIds.insert(contentId)
                }
                updateDeleteButtonState()
                collectionView.reloadItems(at: [indexPath])
                return
            }
            showTextPreview(for: content)

        case .photo:
            guard indexPath.item < photoUrls.count else { return }
            let url = photoUrls[indexPath.item]
            if isSelectionMode {
                if selectedPhotoUrls.contains(url) {
                    selectedPhotoUrls.remove(url)
                } else {
                    selectedPhotoUrls.insert(url)
                }
                updateDeleteButtonState()
                collectionView.reloadItems(at: [indexPath])
                return
            }
            showPhotoPreview()
        }
    }
}

// MARK: - DataSource

extension MyMemoryMessageListViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch type {
        case .text: return textItems.count
        case .photo: return photoUrls.count
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch type {
        case .text:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: MessageTextCardCell.self),
                for: indexPath
            ) as? MessageTextCardCell
            let content = textItems[indexPath.item]
            cell?.configure(with: content, index: indexPath.item + 1)
            cell?.setSelection(
                isSelectionMode: isSelectionMode,
                isSelected: selectedTextIds.contains(content.id)
            )
            return cell ?? UICollectionViewCell()
        case .photo:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: MessagePhotoCardCell.self),
                for: indexPath
            ) as? MessagePhotoCardCell
            let url = photoUrls[indexPath.item]
            cell?.configure(with: url)
            cell?.setSelection(
                isSelectionMode: isSelectionMode,
                isSelected: selectedPhotoUrls.contains(url)
            )
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
