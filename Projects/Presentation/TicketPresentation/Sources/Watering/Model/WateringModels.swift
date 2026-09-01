import UIKit

import DesignSystem
import TicketDomain

public enum WateringGrowthStage {
    case sprout
    case tree
    case flower
    case fruit
    case ripeFruit

    static func stage(serverStage: Int) -> WateringGrowthStage {
        switch serverStage {
        case ..<2: return .sprout
        case 2: return .tree
        case 3: return .flower
        case 4: return .fruit
        default: return .ripeFruit
        }
    }

    var image: UIImage {
        switch self {
        case .sprout: return DesignSystemAsset.ImageAssets.wateringPlantSprout.image
        case .tree: return DesignSystemAsset.ImageAssets.wateringPlantTree.image
        case .flower: return DesignSystemAsset.ImageAssets.wateringPlantFlower.image
        case .fruit: return DesignSystemAsset.ImageAssets.wateringPlantFruit.image
        case .ripeFruit: return DesignSystemAsset.ImageAssets.wateringPlantRipeFruit.image
        }
    }

    var size: CGSize {
        switch self {
        case .sprout: return CGSize(width: 94, height: 88)
        case .tree: return CGSize(width: 116, height: 209)
        case .flower, .fruit, .ripeFruit: return CGSize(width: 137, height: 250)
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
        daysByDate: [Date: WateringDayEntity],
        startDate: Date?,
        totalDays: Int
    ) -> [WateringDayItem] {
        guard totalDays > 0 else { return [] }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<totalDays).map { index in
            guard let startDate,
                  let date = calendar.date(byAdding: .day, value: index, to: startDate) else {
                return WateringDayItem(isToday: false, state: .upcoming(day: index + 1))
            }

            let isToday = date == today
            let day = daysByDate[date]

            if let day, day.isWatered {
                return WateringDayItem(
                    isToday: isToday,
                    state: .watered(profileImageUrl: day.profileImageUrl)
                )
            }

            if isToday {
                return WateringDayItem(isToday: true, state: .today)
            }

            if date > today || day == nil {
                return WateringDayItem(isToday: false, state: .upcoming(day: index + 1))
            }

            return WateringDayItem(isToday: false, state: .missed)
        }
    }

    static func isWateredToday(_ daysByDate: [Date: WateringDayEntity]) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return daysByDate[today]?.isWatered ?? false
    }
}
