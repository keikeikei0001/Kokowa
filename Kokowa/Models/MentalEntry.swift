//
//  MentalEntry.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import SwiftData

@Model
final class MentalEntry {
    @Attribute(.unique) var id: UUID
    var userId: String
    var entryDate: Date
    var mental: Double
    var sleepHours: Double
    var conditionRawValue: String
    var stressLevelRawValue: String
    var gratitudeData: Data
    var memo: String
    var createdAt: Date
    var updatedAt: Date

    /// メンタル記録を初期化する。
    init(
        id: UUID = UUID(),
        userId: String,
        entryDate: Date,
        mental: Double,
        sleepHours: Double,
        condition: EntryCondition,
        stressLevel: StressLevel,
        gratitude: [String],
        memo: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.entryDate = entryDate
        self.mental = mental
        self.sleepHours = sleepHours
        self.conditionRawValue = condition.rawValue
        self.stressLevelRawValue = stressLevel.rawValue
        self.gratitudeData = Self.encodeGratitude(gratitude)
        self.memo = memo
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// 感謝リストを保存用Dataへ変換する。
    private static func encodeGratitude(_ gratitude: [String]) -> Data {
        (try? JSONEncoder().encode(gratitude)) ?? Data()
    }

    /// 保存用Dataを感謝リストへ変換する。
    private static func decodeGratitude(_ data: Data) -> [String] {
        (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    /// 保存した感謝リストを配列として返す。
    var gratitude: [String] {
        get {
            Self.decodeGratitude(gratitudeData)
        }
        set {
            gratitudeData = Self.encodeGratitude(newValue)
        }
    }

    /// 保存した体調をenumとして返す。
    var condition: EntryCondition {
        EntryCondition(rawValue: conditionRawValue) ?? .good
    }

    /// 保存したストレスレベルをenumとして返す。
    var stressLevel: StressLevel {
        StressLevel(rawValue: stressLevelRawValue) ?? .normal
    }
}
