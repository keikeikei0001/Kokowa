//
//  CharacterExperienceTable.swift
//  Kokowa
//
//  Created by Codex on 2026/07/02.
//

import Foundation

struct CharacterExperienceRule {
    let baseRequiredExperience: Double
    let levelGrowth: Double
    let levelOverrides: [Int: Int]

    /// 指定したレベルから次のレベルに上がるための必要経験値を返す。
    func requiredExperience(for level: Int) -> Int {
        if let override = levelOverrides[level] {
            return max(1, override)
        }

        let requiredExperience = baseRequiredExperience + (Double(max(level, 1) - 1) * levelGrowth)
        return max(1, Int(requiredExperience.rounded()))
    }
}
