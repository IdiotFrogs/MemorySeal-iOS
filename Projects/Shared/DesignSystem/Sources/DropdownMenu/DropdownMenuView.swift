//
//  DropdownMenuView.swift
//  DesignSystem
//
//  Created by 선민재 on 4/6/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

public final class DropdownMenuView: UIView {
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private let itemRelay: PublishRelay<Int> = .init()

    public var itemDidTap: Observable<Int> {
        return itemRelay.asObservable()
    }

    private weak var dimmingView: UIView?
    private let disposeBag = DisposeBag()

    public init(items: [String]) {
        super.init(frame: .zero)

        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 12

        self.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        }

        for (index, title) in items.enumerated() {
            let button = makeItemButton(title: title)
            button.rx.tap
                .withUnretained(self)
                .subscribe(onNext: { (self, _) in
                    self.itemRelay.accept(index)
                    self.dismiss()
                })
                .disposed(by: disposeBag)

            stackView.addArrangedSubview(button)
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeItemButton(title: String) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = DesignSystemAsset.ColorAssests.grey5.color
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        let button = UIButton(configuration: config)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 14)
        button.contentHorizontalAlignment = .leading
        return button
    }

    @discardableResult
    public static func show(
        on view: UIView,
        anchorView: UIView,
        items: [String]
    ) -> DropdownMenuView {
        let dropdown = DropdownMenuView(items: items)

        let dimming = UIView()
        dimming.backgroundColor = .clear
        view.addSubview(dimming)
        dimming.snp.makeConstraints { $0.edges.equalToSuperview() }

        let tapGesture = UITapGestureRecognizer()
        dimming.addGestureRecognizer(tapGesture)
        tapGesture.rx.event
            .subscribe(onNext: { _ in
                dropdown.dismiss()
            })
            .disposed(by: dropdown.disposeBag)

        view.addSubview(dropdown)

        let anchorFrame = anchorView.convert(anchorView.bounds, to: view)
        dropdown.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(anchorFrame.maxY + 4)
            $0.trailing.equalTo(view.snp.trailing).inset(20)
            $0.width.equalTo(160)
        }

        dropdown.dimmingView = dimming
        dropdown.alpha = 0
        dropdown.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(withDuration: 0.2) {
            dropdown.alpha = 1
            dropdown.transform = .identity
        }

        return dropdown
    }

    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        let performDismiss = { [weak self] in
            self?.dimmingView?.removeFromSuperview()
            self?.removeFromSuperview()
            completion?()
        }

        guard animated else {
            performDismiss()
            return
        }

        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            self?.alpha = 0
        }, completion: { _ in
            performDismiss()
        })
    }
}
