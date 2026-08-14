import UIKit

import DesignSystem

enum TicketStageDecoration {
    case leaf
    case flower
    case greenFruit
    case ripeFruit

    static let ticketWidth: CGFloat = 335
    static let bottomOverhang: CGFloat = 15

    init?(stage: Int) {
        switch stage {
        case 2: self = .leaf
        case 3: self = .flower
        case 4: self = .greenFruit
        case 5: self = .ripeFruit
        default: return nil
        }
    }

    var image: UIImage {
        switch self {
        case .leaf: return DesignSystemAsset.ImageAssets.ticketStageLeaf.image
        case .flower: return DesignSystemAsset.ImageAssets.ticketStageFlower.image
        case .greenFruit: return DesignSystemAsset.ImageAssets.ticketStageGreenFruit.image
        case .ripeFruit: return DesignSystemAsset.ImageAssets.ticketStageRipeFruit.image
        }
    }

    func frame(fittingTicketBounds bounds: CGRect) -> CGRect {
        let scale = bounds.width / Self.ticketWidth
        let size = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        return CGRect(
            x: bounds.midX - size.width / 2,
            y: bounds.maxY + Self.bottomOverhang * scale - size.height,
            width: size.width,
            height: size.height
        )
    }
}
