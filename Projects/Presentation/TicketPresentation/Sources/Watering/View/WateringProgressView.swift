import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

final class WateringProgressView: UIView {
    private let dropIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.wateringDropIcon.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let allDaysButton: UIButton = {
        let button = UIButton()
        button.setTitle("전체보기", for: .normal)
        button.setTitleColor(DesignSystemAsset.ColorAssests.grey3.color, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        return button
    }()

    private let progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.primaryLight.color
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        return view
    }()

    private let progressFillView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.primaryNormal.color
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        return view
    }()

    var allDaysDidTap: ControlEvent<Void> {
        return allDaysButton.rx.tap
    }

    func setAllDaysButtonHidden(_ isHidden: Bool) {
        allDaysButton.isHidden = isHidden
    }

    init() {
        super.init(frame: .zero)

        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(wateredDays: Int, totalDays: Int) {
        let attributedText = NSMutableAttributedString(
            string: "\(wateredDays)",
            attributes: [
                .font: DesignSystemFontFamily.Pretendard.bold.font(size: 14),
                .foregroundColor: DesignSystemAsset.ColorAssests.primaryNormal.color
            ]
        )
        attributedText.append(
            NSAttributedString(
                string: " / \(totalDays)일",
                attributes: [
                    .font: DesignSystemFontFamily.Pretendard.regular.font(size: 14),
                    .foregroundColor: DesignSystemAsset.ColorAssests.grey3.color
                ]
            )
        )
        countLabel.attributedText = attributedText
    }

    func setProgress(_ ratio: Double) {
        progressFillView.snp.remakeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            if ratio <= 0 {
                $0.width.equalTo(0)
            } else {
                $0.width.equalToSuperview().multipliedBy(ratio)
            }
        }
    }
}

extension WateringProgressView {
    private func addSubviews() {
        addSubview(dropIconImageView)
        addSubview(countLabel)
        addSubview(allDaysButton)
        addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
    }

    private func setLayout() {
        dropIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.width.height.equalTo(24)
        }

        countLabel.snp.makeConstraints {
            $0.centerY.equalTo(dropIconImageView)
            $0.leading.equalTo(dropIconImageView.snp.trailing).offset(6)
        }

        allDaysButton.snp.makeConstraints {
            $0.centerY.equalTo(dropIconImageView)
            $0.trailing.equalToSuperview().inset(8)
        }

        progressTrackView.snp.makeConstraints {
            $0.top.equalTo(dropIconImageView.snp.bottom).offset(11)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(18)
            $0.bottom.equalToSuperview()
        }

        progressFillView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(0)
        }
    }
}
