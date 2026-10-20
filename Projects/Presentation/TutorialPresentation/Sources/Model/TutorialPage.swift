//
//  TutorialPage.swift
//  TutorialPresentation
//
//  Created by 선민재 on 10/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import DesignSystem

public struct TutorialPage {
    let illustration: UIImage
    let title: String
    let body: String
    let buttonTitle: String
    let isSkippable: Bool
}

extension TutorialPage {
    static let all: [TutorialPage] = [
        TutorialPage(
            illustration: DesignSystemAsset.ImageAssets.tutorialIllust01.image,
            title: "함께 열 타임 티켓을 만들어요",
            body: "+ 버튼을 눌러 새 티켓을 만들거나\n친구에게 받은 참여 코드로 합류할 수 있어요.",
            buttonTitle: "다음",
            isSkippable: true
        ),
        TutorialPage(
            illustration: DesignSystemAsset.ImageAssets.tutorialIllust02.image,
            title: "친구를 티켓에 초대해요",
            body: "참여 코드나 초대 링크를 보내면\n친구가 바로 티켓에 들어올 수 있어요.",
            buttonTitle: "다음",
            isSkippable: true
        ),
        TutorialPage(
            illustration: DesignSystemAsset.ImageAssets.tutorialIllust03.image,
            title: "추억 메시지를 담아요",
            body: "글, 사진, 음성으로 지금의 마음을 남겨요.\n티켓이 열리는 날 모두 함께 볼 수 있어요.",
            buttonTitle: "다음",
            isSkippable: true
        ),
        TutorialPage(
            illustration: DesignSystemAsset.ImageAssets.tutorialIllust04.image,
            title: "오픈일을 정하고 묻어요",
            body: "티켓을 열 날짜를 정하고 묻으면\n그날까지 추억이 천천히 익어가요.",
            buttonTitle: "다음",
            isSkippable: true
        ),
        TutorialPage(
            illustration: DesignSystemAsset.ImageAssets.tutorialIllust05.image,
            title: "오픈일에 함께 열어봐요",
            body: "오픈일에 티켓을 열고\n모두의 추억 메시지를 확인해요.",
            buttonTitle: "메실 시작하기",
            isSkippable: false
        )
    ]
}
