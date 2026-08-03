//
//  SplashViewController.swift
//  SplashPresentation
//
//  Created by 선민재 on 3/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

public final class SplashViewController: UIViewController {
    // MARK: - Constant
    private enum Metric {
        static let logoLeading: CGFloat = 29
        static let logoTop: CGFloat = 259
        static let logoSize: CGFloat = 335
    }

    private enum Constant {
        static let backgroundColorHex: String = "#F4F4CC"
        static let logoImageName: String = "MemorySealLogo"
    }

    private let viewModel: SplashViewModel

    // MARK: - UI
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constant.logoImageName)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Init
    public init(with viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.executeAutoSignIn()
    }
}

private extension SplashViewController {
    func setUpView() {
        view.backgroundColor = UIColor(hex: Constant.backgroundColorHex)
        view.addSubview(logoImageView)
    }

    func setUpConstraints() {
        logoImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Metric.logoLeading)
            $0.top.equalToSuperview().offset(Metric.logoTop)
            $0.width.equalTo(Metric.logoSize)
            $0.height.equalTo(Metric.logoSize)
        }
    }
}
