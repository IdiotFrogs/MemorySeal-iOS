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
    private let didConfirmLeave: PublishRelay<Void> = .init()

    // MARK: - Navigation
    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("티켓 관리")
        view.setTitleFont(DesignSystemFontFamily.Pretendard.bold.font(size: 20))
        return view
    }()

    // MARK: - Menu
    private let menuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()

    private let memberRow: ManageTicketMenuRowView = ManageTicketMenuRowView(
        iconName: "ManageTicketMemberIcon",
        title: "멤버"
    )

    private let exitTicketRow: ManageTicketMenuRowView = ManageTicketMenuRowView(
        iconName: "ManageTicketExitIcon",
        title: "티켓 나가기"
    )

    private let deleteTicketRow: ManageTicketMenuRowView = ManageTicketMenuRowView(
        iconName: "ManageTicketTrashIcon",
        title: "티켓 삭제"
    )

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
            didConfirmDelete: didConfirmDelete,
            didConfirmLeave: didConfirmLeave
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
        deleteTicketRow.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.showDeleteDialog()
            })
            .disposed(by: disposeBag)

        exitTicketRow.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.didConfirmLeave.accept(())
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
        view.addSubview(menuStackView)

        menuStackView.addArrangedSubview(memberRow)
        menuStackView.addArrangedSubview(exitTicketRow)
        menuStackView.addArrangedSubview(deleteTicketRow)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        menuStackView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
