//
//  ToastView.swift
//  DesignSystem
//
//  Created by 선민재 on 4/6/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

public final class ToastView: UIView {
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
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.numberOfLines = 0
        return label
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private init(message: String) {
        super.init(frame: .zero)

        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 8

        messageLabel.text = message

        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(messageLabel)

        addSubview(contentStackView)

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func show(on view: UIView, message: String) {
        view.subviews.compactMap { $0 as? ToastView }.forEach { $0.removeFromSuperview() }
        let toast = ToastView(message: message)
        view.addSubview(toast)

        toast.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: -20)
        UIView.animate(withDuration: 0.25) {
            toast.alpha = 1
            toast.transform = .identity
        }

        UIView.animate(
            withDuration: 0.25,
            delay: 2.0,
            options: [],
            animations: {
                toast.alpha = 0
                toast.transform = CGAffineTransform(translationX: 0, y: -20)
            },
            completion: { _ in
                toast.removeFromSuperview()
            }
        )
    }
}
