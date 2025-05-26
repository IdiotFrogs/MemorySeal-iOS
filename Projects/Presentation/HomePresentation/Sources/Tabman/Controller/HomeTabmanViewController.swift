//
//  HomeTabmanViewController.swift
//  SplashFeature
//
//  Created by 선민재 on 5/19/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Tabman
import Pageboy

import DesignSystem

enum HomeTabMenu: Int, CaseIterable {
    case create
    case invited
    
    var title: String {
        switch self {
        case .create:
            return "생성한 티켓"
        case .invited:
            return "합류한 티켓"
        }
    }
}

public final class HomeTabmanViewController: TabmanViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private var viewControllers: [UIViewController] = []
    
    private let tabManBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "타임 티켓"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 24)
        return label
    }()
    
    private let userProfileButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.setImage(
            DesignSystemAsset.ImageAssets.userDefaultProfileImage.image,
            for: .normal
        )
        return button
    }()
    
    private let customContainerView = UIView()
    
    private let homeTabManBar: TMBar.ButtonBar = {
        let tabmanBar = TMBar.ButtonBar()
        tabmanBar.buttons.customize { button in
            button.selectedTintColor = .black
            button.tintColor = DesignSystemAsset.ColorAssests.grey3.color
            button.selectedFont = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
            button.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        }
        tabmanBar.indicator.weight = .custom(value: 2)
        tabmanBar.indicator.tintColor = .black
        tabmanBar.layout.transitionStyle = .snap
        tabmanBar.layout.alignment = .centerDistributed
        tabmanBar.layout.contentMode = .fit
        tabmanBar.backgroundView.style = .flat(color: .clear)
        tabmanBar.buttons.transitionStyle = .snap
        return tabmanBar
    }()
    
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        return view
    }()
    
    private let floatingButton: FloatingButton = {
        let button = FloatingButton()
        button.layer.cornerRadius = 28
        return button
    }()
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#444444")?.withAlphaComponent(0.24)
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
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 12
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        return stackView
    }()
    
    public init(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.bounces = false
        
        self.addSubViews()
        self.setLayout()
        
        self.bindButtons()
        
        self.addBar(
            homeTabManBar,
            dataSource: self,
            at: .custom(view: customContainerView, layout: nil)
        )
    }
}

extension HomeTabmanViewController {
    private func bindButtons() {
        floatingButton.rx.tap
            .map { self.floatingButton.status }
            .withUnretained(self)
            .subscribe(onNext: { (self, status) in
                if status == .closed {
                    self.showDimView()
                    self.showStackView()
                    self.floatingButton.status = .opened
                } else {
                    self.floatingButton.status = .closed
                    self.dimView.removeFromSuperview()
                    self.stackView.removeFromSuperview()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension HomeTabmanViewController {
    private func showDimView() {
        view.addSubview(dimView)
        view.bringSubviewToFront(floatingButton)
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func showStackView() {
        view.addSubview(stackView)
        stackView.addSubview(createNewTicketButton)
        stackView.addSubview(enterTickButton)
        
        createNewTicketButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(35)
        }
        
        enterTickButton.snp.makeConstraints {
            $0.top.equalTo(createNewTicketButton.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(35)
            $0.bottom.equalToSuperview().inset(8)
        }
        
        stackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(floatingButton.snp.top).offset(-16)
            $0.width.equalTo(176)
            $0.height.equalTo(90)
        }
    }
    
    private func addSubViews() {
        view.addSubview(tabManBackgroundView)
        tabManBackgroundView.addSubview(underLineView)
        tabManBackgroundView.addSubview(titleLabel)
        tabManBackgroundView.addSubview(userProfileButton)
        tabManBackgroundView.addSubview(customContainerView)
        
        view.addSubview(floatingButton)
    }
    
    private func setLayout() {
        tabManBackgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        underLineView.snp.makeConstraints {
            $0.top.equalTo(tabManBackgroundView.snp.bottom).inset(1)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        userProfileButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(32)
        }
        
        customContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(19)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(tabManBackgroundView.snp.bottom)
            $0.height.equalTo(40)
        }
        
        floatingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            $0.width.height.equalTo(56)
        }
    }
}

extension HomeTabmanViewController: TMBarDataSource {
    public func barItem(
        for bar: any Tabman.TMBar,
        at index: Int
    ) -> any Tabman.TMBarItemable {
        return TMBarItem(title: HomeTabMenu(rawValue: index)?.title ?? "")
    }
}

extension HomeTabmanViewController: PageboyViewControllerDataSource {
    public func numberOfViewControllers(
        in pageboyViewController: Pageboy.PageboyViewController
    ) -> Int {
        return viewControllers.count
    }
    
    public func viewController(
        for pageboyViewController: Pageboy.PageboyViewController,
        at index: Pageboy.PageboyViewController.PageIndex
    ) -> UIViewController? {
        return viewControllers[index]
    }
    
    public func defaultPage(
        for pageboyViewController: Pageboy.PageboyViewController
    ) -> Pageboy.PageboyViewController.Page? {
        return .at(index: HomeTabMenu.create.rawValue)
    }
}
