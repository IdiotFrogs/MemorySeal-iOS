//
//  EditProfileImageBottomSheetView.swift
//  ProfilePresentation
//
//  Created by 선민재 on 9/1/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

final class EditProfileImageBottomSheetView: UIView {

    private enum Layout {
        static let sheetHeight: CGFloat = 152
        static let cornerRadius: CGFloat = 16
        static let horizontalInset: CGFloat = 20
        static let topPadding: CGFloat = 20
        static let rowHeight: CGFloat = 52
        static let separatorHeight: CGFloat = 1
        static let animationDuration: TimeInterval = 0.3
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        view.isUserInteractionEnabled = true
        return view
    }()

    private let sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Layout.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let selectFromAlbumButton: UIButton = {
        let button = UIButton()
        button.setTitle("앨범에서 이미지 선택", for: .normal)
        button.setTitleColor(DesignSystemAsset.ColorAssests.grey5.color, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        button.contentHorizontalAlignment = .left
        return button
    }()

    private let dashedSeparator = DashedLineView()

    private let applyDefaultImageButton: UIButton = {
        let button = UIButton()
        button.setTitle("기본 이미지 적용", for: .normal)
        button.setTitleColor(DesignSystemAsset.ColorAssests.grey5.color, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        button.contentHorizontalAlignment = .left
        return button
    }()

    var selectFromAlbumDidTap: ControlEvent<Void> {
        return selectFromAlbumButton.rx.tap
    }

    var applyDefaultImageDidTap: ControlEvent<Void> {
        return applyDefaultImageButton.rx.tap
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews()
        setLayout()
        bindDimming()

        isHidden = true
        sheetView.transform = CGAffineTransform(translationX: 0, y: Layout.sheetHeight)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        isHidden = false
        sheetView.transform = CGAffineTransform(translationX: 0, y: Layout.sheetHeight)

        UIView.animate(withDuration: Layout.animationDuration, delay: 0, options: .curveEaseOut) {
            self.dimmingView.alpha = 1
            self.sheetView.transform = .identity
        }
    }

    func hide(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: Layout.animationDuration,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.dimmingView.alpha = 0
                self.sheetView.transform = CGAffineTransform(translationX: 0, y: Layout.sheetHeight)
            },
            completion: { [weak self] _ in
                self?.isHidden = true
                completion?()
            }
        )
    }
}

// MARK: - Bind

extension EditProfileImageBottomSheetView {
    private func bindDimming() {
        let tapDimming = UITapGestureRecognizer()
        dimmingView.addGestureRecognizer(tapDimming)

        tapDimming.rx.event
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.hide()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Layout

extension EditProfileImageBottomSheetView {
    private func addSubviews() {
        addSubview(dimmingView)
        addSubview(sheetView)

        sheetView.addSubview(selectFromAlbumButton)
        sheetView.addSubview(dashedSeparator)
        sheetView.addSubview(applyDefaultImageButton)
    }

    private func setLayout() {
        dimmingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        sheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(Layout.sheetHeight)
        }

        selectFromAlbumButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.topPadding)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.height.equalTo(Layout.rowHeight)
        }

        dashedSeparator.snp.makeConstraints {
            $0.top.equalTo(selectFromAlbumButton.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.height.equalTo(Layout.separatorHeight)
        }

        applyDefaultImageButton.snp.makeConstraints {
            $0.top.equalTo(dashedSeparator.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.height.equalTo(Layout.rowHeight)
        }
    }
}
