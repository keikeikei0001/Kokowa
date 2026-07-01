//
//  MemoryEntry.swift
//  Kokowa
//
//  Created by Codex on 2026/07/01.
//

import Foundation
import SwiftData

@Model
final class MemoryEntry {
    @Attribute(.unique) var id: UUID
    var userId: String
    var title: String
    var periodRawValue: String
    var introspectionStatusRawValue: String = MemoryIntrospectionStatus.notStarted.rawValue
    var peopleData: Data
    var createdAt: Date
    var updatedAt: Date

    /// ネガティブな出来事の記録を初期化する。
    init(
        id: UUID = UUID(),
        userId: String,
        title: String,
        period: MemoryPeriod,
        introspectionStatus: MemoryIntrospectionStatus = .notStarted,
        people: [String],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.periodRawValue = period.rawValue
        self.introspectionStatusRawValue = introspectionStatus.rawValue
        self.peopleData = Self.encodePeople(people)
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// 相手リストを保存用Dataへ変換する。
    private static func encodePeople(_ people: [String]) -> Data {
        (try? JSONEncoder().encode(people)) ?? Data()
    }

    /// 保存用Dataを相手リストへ変換する。
    private static func decodePeople(_ data: Data) -> [String] {
        (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    /// 保存した相手リストを配列として返す。
    var people: [String] {
        get {
            Self.decodePeople(peopleData)
        }
        set {
            peopleData = Self.encodePeople(newValue)
        }
    }

    /// 保存した時期をenumとして返す。
    var period: MemoryPeriod {
        MemoryPeriod(rawValue: periodRawValue) ?? .preschool
    }

    /// 保存した内観ステータスをenumとして返す。
    var introspectionStatus: MemoryIntrospectionStatus {
        MemoryIntrospectionStatus(rawValue: introspectionStatusRawValue) ?? .notStarted
    }
}
