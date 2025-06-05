//
//  MemorySealCalendarView.swift
//  DesignSystem
//
//  Created by 선민재 on 6/4/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final public class MemorySealCalendarView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "2025년 6월"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        return label
    }()
    
    private let previousMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(DesignSystemAsset.ImageAssets.leftArrowImage.image, for: .normal)
        return button
    }()
    
    private let nextMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(DesignSystemAsset.ImageAssets.rightArrowImage.image, for: .normal)
        return button
    }()
    
    private let weekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCalendarLayout()
        )
        collectionView.register(
            MemorySealCalendarCollectionViewCell.self,
            forCellWithReuseIdentifier: MemorySealCalendarCollectionViewCell.reuseIdentifier
        )
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubviews()
        self.setLayout()
        
        self.setWeek()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var nextMonthButtonDidTap: ControlEvent<Void> {
        return nextMonthButton.rx.tap
    }
    
    public var previousMonthButtonDidTap: ControlEvent<Void> {
        return previousMonthButton.rx.tap
    }
}

extension MemorySealCalendarView {
    public func setTitleLabel(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let titleLabelText: String = dateFormatter.string(from: date)
        titleLabel.text = titleLabelText
    }
}

extension MemorySealCalendarView {
    private func setWeek() {
        let week: [String] = ["일", "월", "화", "수", "목", "금", "토"]
        
        week.forEach { day in
            let dayLabel: UILabel = {
                let label = UILabel()
                label.text = day
                label.textColor = DesignSystemAsset.ColorAssests.grey4.color
                label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
                label.textAlignment = .center
                return label
            }()
            
            weekStackView.addArrangedSubview(dayLabel)
        }
    }
    
    private func createCalendarLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            return self.getCalendarLayout()
        }
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
        return layout
    }
    
    private func getCalendarLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 7.0),
            heightDimension: .fractionalWidth(1.0 / 7.0)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / 7.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 7
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.contentInsets = .zero

        return section
    }
    
    public func remakeCollectionViewLayout() {
        collectionView.snp.remakeConstraints {
            $0.top.equalTo(weekStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(collectionView.contentSize.height)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(nextMonthButton)
        addSubview(previousMonthButton)
        addSubview(weekStackView)
        addSubview(collectionView)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(12)
        }
        
        nextMonthButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12.5)
            $0.trailing.equalToSuperview().inset(12)
            $0.width.height.equalTo(16)
        }
        
        previousMonthButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12.5)
            $0.trailing.equalTo(nextMonthButton.snp.leading).offset(-8)
            $0.width.height.equalTo(16)
        }
        
        weekStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(weekStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.greaterThanOrEqualTo(200)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
}
