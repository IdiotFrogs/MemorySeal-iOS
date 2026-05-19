import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import PhotosUI
import Tabman
import Pageboy
import DesignSystem

// MARK: - MyMemoryMessagesTab

enum MyMemoryMessagesTab: Int, CaseIterable {
    case text
    case photo

    var title: String {
        switch self {
        case .text: return "메세지"
        case .photo: return "사진"
        }
    }

    var messageType: MyMemoryMessageType {
        switch self {
        case .text: return .text
        case .photo: return .photo
        }
    }
}

// MARK: - MyMemoryMessagesViewController

public final class MyMemoryMessagesViewController: TabmanViewController {

    // MARK: - Properties

    private let viewModel: MyMemoryMessagesViewModel
    private let listViewControllers: [UIViewController]
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - UI

    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("나의 추억 메시지")
        view.setTitleFont(DesignSystemFontFamily.Pretendard.bold.font(size: 20))
        return view
    }()

    private let customContainerView: UIView = UIView()

    private let tabManBar: TMBar.ButtonBar = {
        let bar = TMBar.ButtonBar()
        bar.buttons.customize { button in
            button.selectedTintColor = DesignSystemAsset.ColorAssests.grey5.color
            button.tintColor = UIColor(hex: "#919191")
            button.selectedFont = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
            button.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        }
        bar.indicator.weight = .custom(value: 8)
        bar.indicator.tintColor = .clear
        bar.layout.transitionStyle = .snap
        bar.layout.alignment = .centerDistributed
        bar.layout.contentMode = .fit
        bar.backgroundView.style = .flat(color: .clear)
        bar.buttons.transitionStyle = .snap
        return bar
    }()

    private let indicatorImageView: UIImageView = {
        let imageView = UIImageView(
            image: DesignSystemAsset.ImageAssets.tabIndicatorLine.image
        )
        imageView.contentMode = .scaleToFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return imageView
    }()

    private let floatingButton: FloatingButton = FloatingButton()

    // MARK: - Init

    public init(
        viewControllers: [UIViewController],
        with viewModel: MyMemoryMessagesViewModel
    ) {
        self.listViewControllers = viewControllers
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.bounces = false

        setInitialValues()
        addSubviews()
        setLayout()
        bindButton()

        addBar(
            tabManBar,
            dataSource: self,
            at: .custom(view: customContainerView, layout: nil)
        )

        tabManBar.indicator.addSubview(indicatorImageView)
        indicatorImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalTo(6)
        }
        disableClipping(in: tabManBar)
    }

    private func disableClipping(in view: UIView) {
        view.clipsToBounds = false
        view.subviews.forEach { disableClipping(in: $0) }
    }
}

// MARK: - Setup

extension MyMemoryMessagesViewController {
    private func setInitialValues() {
        view.backgroundColor = .white
    }

    private func addSubviews() {
        view.addSubview(navigationView)
        view.addSubview(customContainerView)
        view.addSubview(floatingButton)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.height.equalTo(56)
        }

        customContainerView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        floatingButton.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.width.height.equalTo(79)
        }
    }
}

// MARK: - Binding

extension MyMemoryMessagesViewController {
    private func bindButton() {
        navigationView.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        floatingButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                let index = self.currentIndex ?? 0
                guard let tab = MyMemoryMessagesTab(rawValue: index) else { return }
                switch tab {
                case .text:
                    self.presentMessageInput()
                case .photo:
                    self.presentPhotoPicker()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - BottomSheet

extension MyMemoryMessagesViewController {
    private func presentMessageInput() {
        let sheet = MessageInputBottomSheet()
        sheet.didSubmitText
            .withUnretained(self)
            .subscribe(onNext: { (self, text) in
                let message = MyMemoryMessage(type: .text, textContent: text, imageData: nil)
                self.viewModel.appendMessage(message)
            })
            .disposed(by: disposeBag)
        present(sheet, animated: true)
    }
}

// MARK: - PHPicker

extension MyMemoryMessagesViewController: PHPickerViewControllerDelegate {
    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }

        let group = DispatchGroup()
        var orderedData: [Data?] = Array(repeating: nil, count: results.count)

        for (index, result) in results.enumerated() {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] obj, _ in
                defer { group.leave() }
                guard let self, let image = obj as? UIImage else { return }
                orderedData[index] = self.downscale(image, maxDimension: 800)
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            for data in orderedData {
                guard let data else { continue }
                let message = MyMemoryMessage(type: .photo, textContent: nil, imageData: data)
                self.viewModel.appendMessage(message)
            }
        }
    }

    private func downscale(_ image: UIImage, maxDimension: CGFloat) -> Data? {
        let scale = min(1.0, maxDimension / max(image.size.width, image.size.height))
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized?.jpegData(compressionQuality: 0.5)
    }
}

// MARK: - TMBarDataSource

extension MyMemoryMessagesViewController: TMBarDataSource {
    public func barItem(
        for bar: any Tabman.TMBar,
        at index: Int
    ) -> any Tabman.TMBarItemable {
        return TMBarItem(title: MyMemoryMessagesTab(rawValue: index)?.title ?? "")
    }
}

// MARK: - PageboyViewControllerDataSource

extension MyMemoryMessagesViewController: PageboyViewControllerDataSource {
    public func numberOfViewControllers(
        in pageboyViewController: Pageboy.PageboyViewController
    ) -> Int {
        return listViewControllers.count
    }

    public func viewController(
        for pageboyViewController: Pageboy.PageboyViewController,
        at index: Pageboy.PageboyViewController.PageIndex
    ) -> UIViewController? {
        return listViewControllers[index]
    }

    public func defaultPage(
        for pageboyViewController: Pageboy.PageboyViewController
    ) -> Pageboy.PageboyViewController.Page? {
        return .at(index: MyMemoryMessagesTab.text.rawValue)
    }
}
