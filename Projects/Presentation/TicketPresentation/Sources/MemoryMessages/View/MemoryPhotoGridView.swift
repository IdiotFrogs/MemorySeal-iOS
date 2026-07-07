import UIKit
import SnapKit
import Kingfisher

import DesignSystem

final class MemoryPhotoGridView: UIView {

    // MARK: - UI

    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fill
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = MemoryMessageMetrics.bubbleCornerRadius
        clipsToBounds = true
        backgroundColor = MemoryMessageMetrics.photoPlaceholderColor
        addSubview(verticalStack)
        verticalStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(imageUrls: [String]) {
        verticalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        var index = 0
        while index < imageUrls.count {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 0
            verticalStack.addArrangedSubview(rowStack)
            rowStack.snp.makeConstraints {
                $0.height.equalTo(MemoryMessageMetrics.photoCardSize.height)
            }

            let end = min(index + 2, imageUrls.count)
            for offset in index..<end {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.backgroundColor = MemoryMessageMetrics.photoPlaceholderColor
                if let url = URL(string: imageUrls[offset]) {
                    imageView.kf.setImage(with: url)
                }
                rowStack.addArrangedSubview(imageView)
            }
            index += 2
        }
    }
}
