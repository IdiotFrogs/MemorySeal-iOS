//
//  HomeContainerViewController.swift
//  HomePresentation
//
//  Created by 선민재 on 9/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

import DesignSystem

enum HomeContainerTab: Int, CaseIterable {
    case home
    case opened

    var title: String {
        switch self {
        case .home:
            return "홈"
        case .opened:
            return "오픈된 티켓"
        }
    }

    var icon: UIImage {
        switch self {
        case .home:
            return DesignSystemAsset.ImageAssets.tabHome24.image
                .withRenderingMode(.alwaysTemplate)
        case .opened:
            return DesignSystemAsset.ImageAssets.tabOpenedTicket24.image
                .withRenderingMode(.alwaysTemplate)
        }
    }
}

public final class HomeContainerViewController: UIViewController {

    private enum Layout {
        static let headerHeight: CGFloat = 56
        static let horizontalInset: CGFloat = 20
        static let profileButtonSize: CGFloat = 32
        static let profileButtonCornerRadius: CGFloat = 16
        static let bottomTabBarRowHeight: CGFloat = 80
        static let floatingButtonSize: CGFloat = 56
        static let menuSpacing: CGFloat = 16
        static let menuWidth: CGFloat = 176
        static let menuHeight: CGFloat = 90
        static let menuButtonHeight: CGFloat = 35
    }

    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: HomeContainerViewModel
    private let rxViewDidLoad: PublishRelay<Void> = .init()

    private var viewControllers: [UIViewController] = []
    private var currentTab: HomeContainerTab?
    private var currentChild: UIViewController?

    // MARK: - Header

    private let headerView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 24)
        return label
    }()

    private let userProfileButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        button.layer.cornerRadius = Layout.profileButtonCornerRadius
        button.clipsToBounds = true
        button.setImage(
            DesignSystemAsset.ImageAssets.userDefaultProfileImage.image,
            for: .normal
        )
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()

    // MARK: - Container

    private let containerView = UIView()

    private let bottomTabBarView = HomeBottomTabBarView()

    // MARK: - Floating Menu

    private let floatingButton = HomeFloatingButton()

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#444444")?.withAlphaComponent(0.24)
        return view
    }()

    private let menuContainerView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: .white,
            strokeColor: .white,
            lineWidth: 3
        )
        view.waveCornerRadius = 12
        return view
    }()

    private let createNewTicketButton: TextButton = {
        let button = TextButton(titleInsets: .init(
            top: 8.0,
            left: 8.0,
            bottom: -8.0,
            right: -8.0
        ))
        button.setTitle("새 티켓 생성하기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setFont(DesignSystemFontFamily.Pretendard.bold.font(size: 16))
        button.setTextAlignment(.left)
        button.setBackgroundColor(
            color: .white,
            forState: .normal
        )
        button.setBackgroundColor(
            color: DesignSystemAsset.ColorAssests.grey1.color,
            forState: .highlighted
        )
        button.layer.cornerRadius = 4
        return button
    }()

    private let enterTickButton: TextButton = {
        let button = TextButton(titleInsets: .init(
            top: 8.0,
            left: 8.0,
            bottom: -8.0,
            right: -8.0
        ))
        button.setTitle("참여코드로 합류하기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setFont(DesignSystemFontFamily.Pretendard.bold.font(size: 16))
        button.setTextAlignment(.left)
        button.setBackgroundColor(
            color: .white,
            forState: .normal
        )
        button.setBackgroundColor(
            color: DesignSystemAsset.ColorAssests.grey1.color,
            forState: .highlighted
        )
        button.layer.cornerRadius = 4
        return button
    }()

    public init(
        viewControllers: [UIViewController],
        with viewModel: HomeContainerViewModel
    ) {
        self.viewControllers = viewControllers
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setInitialValues()
        addSubviews()
        setLayout()
        bindViewModel()
        bindButtons()

        select(tab: .home)

        rxViewDidLoad.accept(())
    }

    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        bottomTabBarView.snp.updateConstraints {
            $0.height.equalTo(Layout.bottomTabBarRowHeight + view.safeAreaInsets.bottom)
        }
    }
}

// MARK: - Tab

extension HomeContainerViewController {
    private func select(tab: HomeContainerTab) {
        guard currentTab != tab,
              tab.rawValue < viewControllers.count else { return }

        closeFloatingMenu()
        detachCurrentChild()
        attach(viewControllers[tab.rawValue])

        currentTab = tab
        titleLabel.text = tab.title
        bottomTabBarView.select(index: tab.rawValue)
    }

    private func attach(_ viewController: UIViewController) {
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        viewController.didMove(toParent: self)
        currentChild = viewController
    }

    private func detachCurrentChild() {
        guard let child = currentChild else { return }

        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        currentChild = nil
    }
}

// MARK: - Bind

extension HomeContainerViewController {
    private func bindViewModel() {
        let input = HomeContainerViewModel.Input(
            rxViewDidLoad: rxViewDidLoad,
            createTicketButtonDidTap: createNewTicketButton.rx.tap,
            profileButtonDidTap: userProfileButton.rx.tap,
            enterTicketButtonDidTap: enterTickButton.rx.tap
        )
        let output = viewModel.translation(input)

        output.profileImageUrl
            .drive(with: self) { (self, urlString) in
                guard let urlString, let url = URL(string: urlString) else { return }
                self.userProfileButton.kf.setImage(with: url, for: .normal)
            }
            .disposed(by: disposeBag)
    }

    private func bindButtons() {
        floatingButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                if self.floatingButton.status == .closed {
                    self.showDimView()
                    self.showMenuContainer()
                    self.floatingButton.status = .opened
                } else {
                    self.closeFloatingMenu()
                }
            })
            .disposed(by: disposeBag)

        bottomTabBarView.homeTabButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.select(tab: .home)
            })
            .disposed(by: disposeBag)

        bottomTabBarView.openedTabButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.select(tab: .opened)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Floating Menu

extension HomeContainerViewController {
    private func closeFloatingMenu() {
        floatingButton.status = .closed
        dimView.removeFromSuperview()
        menuContainerView.removeFromSuperview()
    }

    private func showDimView() {
        view.addSubview(dimView)
        view.bringSubviewToFront(bottomTabBarView)
        view.bringSubviewToFront(floatingButton)
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func showMenuContainer() {
        view.addSubview(menuContainerView)
        menuContainerView.addSubview(createNewTicketButton)
        menuContainerView.addSubview(enterTickButton)

        createNewTicketButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(Layout.menuButtonHeight)
        }

        enterTickButton.snp.makeConstraints {
            $0.top.equalTo(createNewTicketButton.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(Layout.menuButtonHeight)
            $0.bottom.equalToSuperview().inset(8)
        }

        menuContainerView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.bottom.equalTo(floatingButton.snp.top).offset(-Layout.menuSpacing)
            $0.width.equalTo(Layout.menuWidth)
            $0.height.equalTo(Layout.menuHeight)
        }
    }
}

// MARK: - Layout

extension HomeContainerViewController {
    private func setInitialValues() {
        view.backgroundColor = .white
        containerView.backgroundColor = .white
    }

    private func addSubviews() {
        view.addSubview(containerView)

        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(userProfileButton)

        view.addSubview(bottomTabBarView)
        view.addSubview(floatingButton)
    }

    private func setLayout() {
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.headerHeight)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.horizontalInset)
            $0.centerY.equalToSuperview()
        }

        userProfileButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(Layout.profileButtonSize)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        bottomTabBarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(Layout.bottomTabBarRowHeight + view.safeAreaInsets.bottom)
        }

        floatingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.centerY.equalTo(bottomTabBarView.pillView.snp.centerY)
            $0.width.height.equalTo(Layout.floatingButtonSize)
        }
    }
}
