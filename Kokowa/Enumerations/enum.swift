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
    case university = "大学生"
    case adult = "社会人"
    case other = "その他"

    var id: String { rawValue }
    var title: String { rawValue }
}

enum MemoryIntrospectionStatus: String, CaseIterable, Identifiable {
    case notStarted = "未内観"
    case inProgress = "内観中"
    case completed = "内観済"

    var id: String { rawValue }
    var title: String { rawValue }
}
