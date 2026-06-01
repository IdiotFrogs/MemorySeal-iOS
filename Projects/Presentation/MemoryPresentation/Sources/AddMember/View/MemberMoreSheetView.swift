//
//  MemberMoreSheetView.swift
//  MemoryPresentation
//
//  Created by 선민재 on 6/1/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

final class MemberMoreSheetView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let delegateRow: MemberMoreRowView = MemberMoreRowView(
        icon: DesignSystemAsset.ImageAssets.crownIcon.image,
        title: "방장 위임"
    )

    private let kickRow: MemberMoreRowView = MemberMoreRowView(
        icon: DesignSystemAsset.ImageAssets.kickIcon.image,
        title: "멤버 추방"
    )

    private let dividerView: DashedLineView = {
        let view = DashedLineView(
            lineColor: DesignSystemAsset.ColorAssests.grey1.color,
            lineWidth: 2,
            dashPattern: [4, 4]
        )
        view.isUserInteractionEnabled = false
        return view
    }()

    private let menuStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16
        return stack
    }()

    private weak var dimmingView: UIView?

    var delegateButtonDidTap: ControlEvent<Void> { delegateRow.tap }
    var kickButtonDidTap: ControlEvent<Void> { kickRow.tap }

    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear

        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    static func show(on view: UIView) -> MemberMoreSheetView {
        view.subviews.compactMap { $0 as? MemberMoreSheetView }.forEach { $0.removeFromSuperview() }

        let sheet = MemberMoreSheetView()

        let dimming = UIView()
        dimming.backgroundColor = UIColor(hex: "#444444")?.withAlphaComponent(0.24)
        dimming.alpha = 0
        view.addSubview(dimming)
        dimming.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.addSubview(sheet)
        sheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }

        sheet.dimmingView = dimming
        view.layoutIfNeeded()
        sheet.containerView.transform = CGAffineTransform(translationX: 0, y: sheet.containerView.bounds.height)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            dimming.alpha = 1
            sheet.containerView.transform = .identity
        }

        let tapGesture = UITapGestureRecognizer(target: sheet, action: #selector(sheet.handleDimTap))
        dimming.addGestureRecognizer(tapGesture)

        return sheet
    }

    @objc private func handleDimTap() {
        dismiss()
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        let perform = { [weak self] in
            self?.dimmingView?.removeFromSuperview()
            self?.removeFromSuperview()
            completion?()
        }

        guard animated else {
            perform()
            return
        }

        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.dimmingView?.alpha = 0
            self?.containerView.transform = CGAffineTransform(translationX: 0, y: self?.containerView.bounds.height ?? 300)
        }, completion: { _ in
            perform()
        })
    }
}

extension MemberMoreSheetView {
    private func addSubviews() {
        addSubview(containerView)

        menuStackView.addArrangedSubview(delegateRow)
        menuStackView.addArrangedSubview(dividerView)
        menuStackView.addArrangedSubview(kickRow)
        containerView.addSubview(menuStackView)
    }

    private func setLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        menuStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(32)
        }

        dividerView.snp.makeConstraints {
            $0.height.equalTo(2)
        }
    }
}
