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

    private var wavyStrokeLayer: WavyStrokeLayer?

    private let colorOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.043, green: 0.043, blue: 0.043, alpha: 0.48)
        return view
    }()

    private let secondaryShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1.0).cgColor
        view.layer.shadowOpacity = 0.16
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 8
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

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 8

        blurView.contentView.addSubview(colorOverlay)

        messageLabel.text = message

        addSubviews()
        setLayout()
        setupWavyStroke()
    }

    private func setupWavyStroke() {
        wavyStrokeLayer = self.addWavyStrokeLayer(
            strokeColor: DesignSystemAsset.ColorAssests.grey4.color,
            lineWidth: 3,
            cornerRadius: 12,
            alignment: .outside
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        self.layer.shadowPath = path
        secondaryShadowView.layer.shadowPath = path

        if let wavyStrokeLayer, wavyStrokeLayer.frame != bounds {
            wavyStrokeLayer.frame = bounds
            wavyStrokeLayer.setNeedsPathRefresh()
        }
    }

    // MARK: - Layout
    private func addSubviews() {
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(messageLabel)

        addSubview(secondaryShadowView)
        addSubview(blurView)
        addSubview(contentStackView)
    }

    private func setLayout() {
        secondaryShadowView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

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
            $0.edges.equalToSuperview().inset(
                UIEdgeInsets(
                    top: 12,
                    left: 16,
                    bottom: 12,
                    right: 16
                )
            )
        }
    }

    // MARK: - Show
    @discardableResult
    public static func show(
        on view: UIView,
        message: String,
        position: ToastPosition = .bottom
    ) -> ToastView {
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

        let slideOffset: CGFloat = position == .top ? -20 : 20
        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: slideOffset)

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
                toast.transform = CGAffineTransform(translationX: 0, y: slideOffset)
            },
            completion: { _ in
                toast.removeFromSuperview()
            }
        )

        return toast
    }
}
