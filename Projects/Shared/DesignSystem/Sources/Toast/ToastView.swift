//
//  ToastView.swift
//  DesignSystem
//
//  Created by 선민재 on 4/6/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

public enum ToastPosition {
    case top
    case bottom
}

public final class ToastView: UIView {
    // MARK: - UI
    private let blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    private let colorOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.043, green: 0.043, blue: 0.043, alpha: 0.48)
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = UIColor(red: 52/255, green: 120/255, blue: 246/255, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 14)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()

    // MARK: - Init
    private init(message: String) {
        super.init(frame: .zero)

        self.backgroundColor = .clear
        self.clipsToBounds = false

        // 그림자: Figma 디자인 값
        self.layer.shadowColor = UIColor(red: 0.314, green: 0.314, blue: 0.314, alpha: 1.0).cgColor
        self.layer.shadowOpacity = 0.16
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 8

        // 블러 contentView 안에 오버레이 배치 (블러 위에 색상이 얹힘)
        blurView.contentView.addSubview(colorOverlay)

        messageLabel.text = message

        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
    }

    // MARK: - Layout
    private func addSubviews() {
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(messageLabel)

        addSubview(blurView)
        addSubview(contentStackView)
    }

    private func setLayout() {
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        colorOverlay.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }
    }

    // MARK: - Show
    @discardableResult
    public static func show(
        on view: UIView,
        message: String,
        position: ToastPosition = .bottom
    ) -> ToastView {
        // 기존 토스트 제거
        view.subviews.compactMap { $0 as? ToastView }.forEach { $0.removeFromSuperview() }

        let toast = ToastView(message: message)
        view.addSubview(toast)

        toast.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)

            switch position {
            case .top:
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            case .bottom:
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8)
            }
        }

        // 초기 상태
        let slideOffset: CGFloat = position == .top ? -20 : 20
        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: slideOffset)

        // 등장 애니메이션
        UIView.animate(withDuration: 0.25) {
            toast.alpha = 1
            toast.transform = .identity
        }

        // 사라짐 애니메이션
        UIView.animate(
            withDuration: 0.25,
            delay: 2.0,
            options: [],
            animations: {
                toast.alpha = 0
                toast.transform = CGAffineTransform(translationX: 0, y: slideOffset)
            },
            completion: { _ in
                toast.removeFromSuperview()
            }
        )

        return toast
    }
}
