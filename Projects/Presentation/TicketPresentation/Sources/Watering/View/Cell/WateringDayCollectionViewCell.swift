import UIKit
import SnapKit
import Kingfisher

import DesignSystem

final class WateringDayCollectionViewCell: UICollectionViewCell {
    private let chipView: WateringDayChipView = {
        let view = WateringDayChipView()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        chipView.photoImageView.kf.cancelDownloadTask()
        chipView.photoImageView.image = nil
    }

    func configure(with item: WateringDayItem) {
        chipView.configure(with: item.state)

        if case .watered(let profileImageUrl) = item.state {
            setProfileImage(urlString: profileImageUrl)
        }
    }

    private func setProfileImage(urlString: String?) {
        let placeholder = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        guard let urlString, let url = URL(string: urlString) else {
            chipView.photoImageView.image = placeholder
            return
        }
        chipView.photoImageView.kf.setImage(with: url, placeholder: placeholder)
    }
}

extension WateringDayCollectionViewCell {
    private func addSubviews() {
        contentView.addSubview(chipView)
    }

    private func setLayout() {
        chipView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(chipView.snp.width)
        }
    }
}
