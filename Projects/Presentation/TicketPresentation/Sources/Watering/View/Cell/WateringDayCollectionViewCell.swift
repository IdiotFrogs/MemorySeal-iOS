import UIKit
import SnapKit

import DesignSystem

final class WateringDayCollectionViewCell: UICollectionViewCell {
    private let chipBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        photoImageView.layer.cornerRadius = photoImageView.bounds.width / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        photoImageView.isHidden = true
        titleLabel.isHidden = false
    }

    func configure(with item: WateringDayItem) {
        titleLabel.text = item.title
        titleLabel.font = item.isToday
            ? DesignSystemFontFamily.Pretendard.bold.font(size: 14)
            : DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        titleLabel.textColor = item.isToday
            ? DesignSystemAsset.ColorAssests.grey5.color
            : DesignSystemAsset.ColorAssests.grey3.color

        chipBackgroundImageView.image = item.isWatered
            ? DesignSystemAsset.ImageAssets.wateringDayChipDone.image
            : DesignSystemAsset.ImageAssets.wateringDayChip.image

        photoImageView.isHidden = !item.isWatered
        titleLabel.isHidden = item.isWatered
    }
}

extension WateringDayCollectionViewCell {
    private func addSubviews() {
        contentView.addSubview(chipBackgroundImageView)
        contentView.addSubview(photoImageView)
        contentView.addSubview(titleLabel)
    }

    private func setLayout() {
        chipBackgroundImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(chipBackgroundImageView.snp.width)
        }

        photoImageView.snp.makeConstraints {
            $0.center.equalTo(chipBackgroundImageView)
            $0.width.height.equalTo(chipBackgroundImageView.snp.width).multipliedBy(0.53)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
