//
//  enum.swift
//  LifeIsRpg
//
//  Created by けいけい on 2024/12/22.
//

import SwiftUI

enum EntryCondition: String, CaseIterable, Identifiable {
    case excellent = "とても良い"
    case good = "良い"
    case slightlyBad = "少し悪い"
    case bad = "悪い"

    var id: String { rawValue }
    var title: String { rawValue }

    var iconName: String {
        switch self {
        case .excellent:
            "sparkles"
        case .good:
            "leaf.fill"
        case .slightlyBad:
            "cloud.sun.fill"
        case .bad:
            "cloud.fill"
        }
    }
}

enum StressLevel: String, CaseIterable, Identifiable {
    case veryHigh = "かなり高い"
    case high = "高い"
    case normal = "少し高い"
    case low = "普通以下"

    var id: String { rawValue }
    var title: String { rawValue }

    var iconName: String {
        switch self {
        case .veryHigh:
            "flame.fill"
        case .high:
            "exclamationmark.triangle.fill"
        case .normal:
            "minus.circle.fill"
        case .low:
            "leaf.fill"
        }
    }
}

enum MemoryPeriod: String, CaseIterable, Identifiable {
    case preschool = "園児以下"
    case elementary = "小学生"
    case juniorHigh = "中学生"
    case highSchool = "高校生"
    case universitySpecialized = "大学・専門"
    case lateTeen = "10代後半"
    case early20s = "20代前半"
    case late20s = "20代後半"
    case early30s = "30代前半"
    case late30s = "30代後半"
    case early40s = "40代前半"
    case late40s = "40代後半"
    case early50s = "50代前半"
    case late50s = "50代後半"
    case early60s = "60代前半"
    case late60s = "60代後半"
    case early70s = "70代前半"
    case late70s = "70代後半"
    case early80s = "80代前半"
    case late80s = "80代後半"
    case early90s = "90代前半"
    case late90s = "90代後半"

    var id: String { rawValue }
    var title: String { rawValue }
}

enum MemoryIntrospectionStatus: String, CaseIterable, Identifiable {
    case notStarted = "未内観"
    case inProgress = "内観中"
    case completed = "内観済"

    var id: String { rawValue }
    var title: String { rawValue }

    var color: UIColor {
        switch self {
        case .notStarted:
            return .kokowaRose
        case .inProgress:
            return .kokowaTerracotta
        case .completed:
            return .kokowaTeal
        }
    }
}

enum CharacterMasterStore {
    private static let initialLevelOverride = [1: 1]

    static let characters: [CharacterMaster] = [
        CharacterMaster(
            id: "kumaneko0001",
            defaultName: "ねこ吉",
            imageName: "kumaneko0001",
            explanation: "ズボラな猫。リッスン姫に恋をするがズボラが原因で振られる。",
            homeImageWidthRatio: 1.86,
            homeImageAspectRatio: 747.0 / 729.0,
            homeFootOffsetX: 0,
            homeFootOffsetY: -18,
            homeMessageTopGap: 18,
            homeShadowWidth: 168,
            homeShadowFootGap: 2,
            experienceRule: CharacterExperienceRule(
                baseRequiredExperience: 3, // レベル1から2に必要な経験値
                levelGrowth: 0.4,          // レベルが上がるたびに増える量
                levelOverrides: initialLevelOverride // 例: [5: 80] と書くとレベル5だけ80に固定
            )
        ),
        CharacterMaster(
            id: "uruhuneko0001",
            defaultName: "ウルフン",
            imageName: "uruhuneko0001",
            explanation: "リッスン王国に住む盗賊の頭。金銀財宝が大好き。",
            homeImageWidthRatio: 1.86,
            homeImageAspectRatio: 746.0 / 758.0,
            homeFootOffsetX: 0,
            homeFootOffsetY: -14,
            homeMessageTopGap: 18,
            homeShadowWidth: 176,
            homeShadowFootGap: 2,
            experienceRule: CharacterExperienceRule(
                baseRequiredExperience: 3, // レベル1から2に必要な経験値
                levelGrowth: 0.4,          // レベルが上がるたびに増える量
                levelOverrides: initialLevelOverride // 例: [5: 80] と書くとレベル5だけ80に固定
            )
        ),
        CharacterMaster(
            id: "usaneko0001",
            defaultName: "リボン",
            imageName: "usaneko0001",
            explanation: "ねこ吉とは幼馴染。みんなの人気者で、密かにねこ吉に恋をする。",
            homeImageWidthRatio: 1.28,
            homeImageAspectRatio: 1200.0 / 796.0,
            homeFootOffsetX: -10,
            homeFootOffsetY: -22,
            homeMessageTopGap: 18,
            homeShadowWidth: 174,
            homeShadowFootGap: 2,
            experienceRule: CharacterExperienceRule(
                baseRequiredExperience: 3, // レベル1から2に必要な経験値
                levelGrowth: 0.4,          // レベルが上がるたびに増える量
                levelOverrides: initialLevelOverride // 例: [5: 80] と書くとレベル5だけ80に固定
            )
        )
    ]

    /// 指定したキャラクターIDのマスタ情報を返す。
    static func character(id: String) -> CharacterMaster? {
        characters.first { $0.id == id }
    }

    /// キャラクターIDと現在レベルに応じた必要経験値を返す。
    static func requiredExperience(characterId: String, level: Int) -> Int {
        (character(id: characterId) ?? characters[0]).experienceRule.requiredExperience(for: level)
    }
}
