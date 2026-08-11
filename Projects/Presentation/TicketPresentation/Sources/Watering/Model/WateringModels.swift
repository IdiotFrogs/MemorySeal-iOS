import UIKit

import DesignSystem
import TicketDomain

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
}

struct WateringDayItem {
    let isToday: Bool
    let state: WateringDayChipState
}

enum WateringDayItemBuilder {
    static func makeItems(
        days: [WateringDayEntity],
        totalDays: Int
    ) -> [WateringDayItem] {
        guard totalDays > 0 else { return [] }

        return (0..<totalDays).map { index in
            guard index < days.count else {
                return WateringDayItem(isToday: false, state: .upcoming(day: index + 1))
            }

            let day = days[index]
            let isToday = isToday(day)

            if day.isWatered {
                return WateringDayItem(
                    isToday: isToday,
                    state: .watered(profileImageUrl: day.profileImageUrl)
                )
            }
            return WateringDayItem(isToday: isToday, state: isToday ? .today : .missed)
        }
    }

    static func isWateredToday(_ days: [WateringDayEntity]) -> Bool {
        return days.first(where: isToday)?.isWatered ?? false
    }

    private static func isToday(_ day: WateringDayEntity) -> Bool {
        guard let wateredDate = day.wateredDate else { return false }
        return Calendar.current.isDateInToday(wateredDate)
    }
}
