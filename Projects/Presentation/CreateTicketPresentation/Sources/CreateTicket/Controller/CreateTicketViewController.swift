//
//  CreateTicketViewController.swift
//  HomePresentation
//
//  Created by 선민재 on 5/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class CreateTicketViewController: UIViewController {
    private let viewModel: CreateTicketViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private let rxViewDidLoad: PublishRelay<Void> = .init()
    
    public init(with viewModel: CreateTicketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        
        self.addSubviews()
        self.setLayout()
        
        self.bindViewModel()
        self.rxViewDidLoad.accept(())
    }
}

extension CreateTicketViewController {
    private func bindViewModel() {
        
    }
}

extension CreateTicketViewController {
    private func addSubviews() {
        
    }
    
    private func setLayout() {
        
    }
}
