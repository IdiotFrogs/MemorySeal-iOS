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
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)
        view.backgroundColor = UIColor(red: 11/255, green: 11/255, blue: 11/255, alpha: 0.48)
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

    private init(message: String) {
        super.init(frame: .zero)

        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        self.layer.shadowColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1.0).cgColor
        self.layer.shadowOpacity = 0.16
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 8

        blurView.layer.cornerRadius = 12
        blurView.clipsToBounds = true

        messageLabel.text = message

        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(messageLabel)

        addSubview(blurView)
        addSubview(contentStackView)

        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
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
