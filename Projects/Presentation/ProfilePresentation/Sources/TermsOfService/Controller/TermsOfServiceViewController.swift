//
//  TermsOfServiceViewController.swift
//  ProfilePresentation
//
//  Created by 선민재 on 10/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class TermsOfServiceViewController: UIViewController {

    // MARK: - Properties

    private let url: URL
    private let moveToBack: () -> Void
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - UI

    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("이용 약관")
        return view
    }()

    private let webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = true
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        return webView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = DesignSystemAsset.ColorAssests.grey3.color
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Init

    public init(url: URL, moveToBack: @escaping () -> Void) {
        self.url = url
        self.moveToBack = moveToBack
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setInitialValues()
        addSubviews()
        setLayout()
        bindViewModel()

        webView.load(URLRequest(url: url))
    }
}

// MARK: - Setup

extension TermsOfServiceViewController {
    private func setInitialValues() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        webView.navigationDelegate = self
        loadingIndicator.startAnimating()
    }

    private func addSubviews() {
        view.addSubview(navigationView)
        view.addSubview(webView)
        view.addSubview(loadingIndicator)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }

        webView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        loadingIndicator.snp.makeConstraints {
            $0.center.equalTo(webView)
        }
    }
}

// MARK: - Binding

extension TermsOfServiceViewController {
    private func bindViewModel() {
        navigationView.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.moveToBack()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - WKNavigationDelegate

extension TermsOfServiceViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoadingView()
    }

    public func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        hideLoadingView()
        showLoadFailure()
    }

    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        hideLoadingView()
        showLoadFailure()
    }

    private func hideLoadingView() {
        loadingIndicator.stopAnimating()
    }

    private func showLoadFailure() {
        ToastView.show(
            on: view,
            message: "이용 약관을 불러오지 못했습니다. 다시 시도해주세요.",
            position: .top
        )
    }
}
