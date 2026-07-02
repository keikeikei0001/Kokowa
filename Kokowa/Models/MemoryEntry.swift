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
    var schemaIdsData: Data = Data()
    var factText: String = ""
    var emotionText: String = ""
    var bodyReactionText: String = ""
    var thoughtText: String = ""
    var desiredResponseText: String = ""
    var fearText: String = ""
    var desiredActionText: String = ""
    var insightText: String = ""
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
        schemaIds: [String] = [],
        factText: String = "",
        emotionText: String = "",
        bodyReactionText: String = "",
        thoughtText: String = "",
        desiredResponseText: String = "",
        fearText: String = "",
        desiredActionText: String = "",
        insightText: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.periodRawValue = period.rawValue
        self.introspectionStatusRawValue = introspectionStatus.rawValue
        self.peopleData = Self.encodeStringArray(people)
        self.schemaIdsData = Self.encodeStringArray(schemaIds)
        self.factText = factText
        self.emotionText = emotionText
        self.bodyReactionText = bodyReactionText
        self.thoughtText = thoughtText
        self.desiredResponseText = desiredResponseText
        self.fearText = fearText
        self.desiredActionText = desiredActionText
        self.insightText = insightText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// 文字列リストを保存用Dataへ変換する。
    private static func encodeStringArray(_ values: [String]) -> Data {
        (try? JSONEncoder().encode(values)) ?? Data()
    }

    /// 保存用Dataを文字列リストへ変換する。
    private static func decodeStringArray(_ data: Data) -> [String] {
        (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    /// 保存した相手リストを配列として返す。
    var people: [String] {
        get {
            Self.decodeStringArray(peopleData)
        }
        set {
            peopleData = Self.encodeStringArray(newValue)
        }
    }

    /// 保存したスキーマIDを配列として返す。
    var schemaIds: [String] {
        get {
            Self.decodeStringArray(schemaIdsData)
        }
        set {
            schemaIdsData = Self.encodeStringArray(newValue)
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
