//
//  LevelUpParticle.swift
//  Kokowa
//
//  Created by Codex on 2026/07/04.
//

import SwiftUI

/// レベルアップ演出で舞い上がる粒子の表示情報を保持する。
struct LevelUpParticle: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let delay: Double
}
