//
//  ManageTicketViewController.swift
//  MemoryPresentation
//
//  Created by 선민재 on 4/7/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class ManageTicketViewController: UIViewController {
    private let viewModel: ManageTicketViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let didConfirmDelete: PublishRelay<Void> = .init()

    // MARK: - Navigation
    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("관리")
        return view
    }()

    // MARK: - Delete Button
    private let deleteTicketButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        button.layer.cornerRadius = 10

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "trash")?.withTintColor(
            DesignSystemAsset.ColorAssests.grey4.color,
            renderingMode: .alwaysOriginal
        )
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

        var titleAttr = AttributedString("티켓 삭제")
        titleAttr.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 16)
        titleAttr.foregroundColor = DesignSystemAsset.ColorAssests.grey4.color
        config.attributedTitle = titleAttr

        button.configuration = config
        button.contentHorizontalAlignment = .leading
        return button
    }()

    public init(with viewModel: ManageTicketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        addSubviews()
        setLayout()
        bindViewModel()
        bindButtons()
    }
}

// MARK: - Bind
extension ManageTicketViewController {
    private func bindViewModel() {
        let input = ManageTicketViewModel.Input(
            didConfirmDelete: didConfirmDelete
        )
        let _ = viewModel.transform(input)

        navigationView.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func bindButtons() {
        deleteTicketButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.showDeleteDialog()
            })
            .disposed(by: disposeBag)
    }

    private func showDeleteDialog() {
        let ticketName = viewModel.ticketName
        let dialog = DeleteConfirmDialogView.show(
            on: self.view,
            message: "삭제를 위해 티켓 이름\"\(ticketName)\"을\n입력해주세요.",
            placeholder: ticketName,
            confirmText: ticketName,
            cancelTitle: "취소",
            confirmTitle: "삭제"
        )

        dialog.confirmButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                dialog.dismiss()
                self.didConfirmDelete.accept(())
            })
            .disposed(by: disposeBag)

        dialog.cancelButtonDidTap
            .subscribe(onNext: {
                dialog.dismiss()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Layout
extension ManageTicketViewController {
    private func addSubviews() {
        view.addSubview(navigationView)
        view.addSubview(deleteTicketButton)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        deleteTicketButton.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        }
    }
}
