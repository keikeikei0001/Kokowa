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

enum CharacterExperienceTable {
    private static let initialLevelOverride = [1: 1]

    private static let defaultRule = CharacterExperienceRule(
        baseRequiredExperience: 3,
        levelGrowth: 0.5,
        levelOverrides: initialLevelOverride
    )

    static let rulesByCharacterId: [String: CharacterExperienceRule] = [
        "kumaneko0001": CharacterExperienceRule(
            baseRequiredExperience: 3, // レベル1から2に必要な経験値
            levelGrowth: 0.5,          // レベルが上がるたびに増える量
            levelOverrides: initialLevelOverride // 例: [5: 80] と書くとレベル5だけ80に固定
        ),
        "uruhuneko0001": CharacterExperienceRule(
            baseRequiredExperience: 3, // レベル1から2に必要な経験値
            levelGrowth: 0.5,          // レベルが上がるたびに増える量
            levelOverrides: initialLevelOverride // 例: [5: 80] と書くとレベル5だけ80に固定
        ),
        "usaneko0001": CharacterExperienceRule(
            baseRequiredExperience: 3, // レベル1から2に必要な経験値
            levelGrowth: 0.5,          // レベルが上がるたびに増える量
            levelOverrides: initialLevelOverride // 例: [5: 80] と書くとレベル5だけ80に固定
        )
    ]

    /// キャラクターIDと現在レベルに応じた必要経験値を返す。
    static func requiredExperience(characterId: String, level: Int) -> Int {
        let rule = rulesByCharacterId[characterId] ?? defaultRule
        return rule.requiredExperience(for: level)
    }
}
