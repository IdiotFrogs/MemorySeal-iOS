//
//  SplashViewController.swift
//  SplashPresentation
//
//  Created by 선민재 on 3/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

public final class SplashViewController: UIViewController {
    private let viewModel: SplashViewModel

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MemorySeal_Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    public init(with viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.startAnimating()
        viewModel.executeAutoSignIn()
    }
}

private extension SplashViewController {
    func setUpView() {
        view.backgroundColor = .white
        view.addSubview(logoImageView)
        view.addSubview(activityIndicator)
    }

    func setUpConstraints() {
        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(200)
        }

        activityIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImageView.snp.bottom).offset(24)
        }
    }
}
