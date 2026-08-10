import UIKit

import DesignSystem

public enum WateringGrowthStage {
    case sprout
    case tree
    case flower
    case fruit

    static func stage(wateredDays: Int, totalDays: Int) -> WateringGrowthStage {
        guard totalDays > 0 else { return .sprout }
        switch Double(wateredDays) / Double(totalDays) {
        case ..<0.25: return .sprout
        case ..<0.5: return .tree
        case ..<0.75: return .flower
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

struct WateringDayItem {
    let title: String
    let isToday: Bool
    let isWatered: Bool
}
