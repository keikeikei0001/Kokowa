//
//  CharacterMaster.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import SwiftUI

struct CharacterMaster: Identifiable {
    let id: String
    let defaultName: String
    let imageName: String
    let explanation: String
    let homeImageWidthRatio: CGFloat
    let homeImageAspectRatio: CGFloat
    let homeFootOffsetX: CGFloat
    let homeFootOffsetY: CGFloat
    let homeMessageTopGap: CGFloat
    let homeShadowWidth: CGFloat
    let homeShadowFootGap: CGFloat
    let experienceRule: CharacterExperienceRule

    /// キャラクターのマスター情報を初期化する。
    init(
        id: String,
        defaultName: String,
        imageName: String,
        explanation: String,
        homeImageWidthRatio: CGFloat = 1.8,
        homeImageAspectRatio: CGFloat = 1,
        homeFootOffsetX: CGFloat = 0,
        homeFootOffsetY: CGFloat = 0,
        homeMessageTopGap: CGFloat = 18,
        homeShadowWidth: CGFloat = 180,
        homeShadowFootGap: CGFloat = 8,
        experienceRule: CharacterExperienceRule = CharacterExperienceRule(
            baseRequiredExperience: 3,
            levelGrowth: 0.4,
            levelOverrides: [1: 1]
        )
    ) {
        self.id = id
        self.defaultName = defaultName
        self.imageName = imageName
        self.explanation = explanation
        self.homeImageWidthRatio = homeImageWidthRatio
        self.homeImageAspectRatio = homeImageAspectRatio
        self.homeFootOffsetX = homeFootOffsetX
        self.homeFootOffsetY = homeFootOffsetY
        self.homeMessageTopGap = homeMessageTopGap
        self.homeShadowWidth = homeShadowWidth
        self.homeShadowFootGap = homeShadowFootGap
        self.experienceRule = experienceRule
    }
}
