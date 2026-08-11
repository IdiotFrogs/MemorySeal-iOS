import UIKit

import DesignSystem

public enum WateringGrowthStage {
    case sprout
    case tree
    case flower
    case fruit

    static func stage(serverStage: Int) -> WateringGrowthStage {
        switch serverStage {
        case ..<2: return .sprout
        case 2: return .tree
        case 3: return .flower
        default: return .fruit
        }
    }

    var image: UIImage {
        switch self {
        case .sprout: return DesignSystemAsset.ImageAssets.wateringPlantSprout.image
        case .tree: return DesignSystemAsset.ImageAssets.wateringPlantTree.image
        case .flower: return DesignSystemAsset.ImageAssets.wateringPlantFlower.image
        case .fruit: return DesignSystemAsset.ImageAssets.wateringPlantFruit.image
        }
    }

    var size: CGSize {
        switch self {
        case .sprout: return CGSize(width: 94, height: 88)
        case .tree: return CGSize(width: 116, height: 209)
        case .flower, .fruit: return CGSize(width: 137, height: 250)
        }
    }
}

enum WateringDayChipState {
    case watered(profileImageUrl: String?)
    case today
    case missed
    case upcoming(day: Int)

    var chipImage: UIImage {
        switch self {
        case .watered: return DesignSystemAsset.ImageAssets.wateringDayChipDone.image
        case .today, .upcoming: return DesignSystemAsset.ImageAssets.wateringDayChip.image
        case .missed: return DesignSystemAsset.ImageAssets.wateringDayChipEmpty.image
        }
    }
}

struct WateringDayItem {
    let isToday: Bool
    let state: WateringDayChipState
}
