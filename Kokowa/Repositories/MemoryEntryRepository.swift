//
//  MemoryEntryRepository.swift
//  Kokowa
//
//  Created by Codex on 2026/07/01.
//

import Foundation
import SwiftData

protocol MemoryEntryRepository {
    /// 指定したユーザーIDの記憶記録を取得する。
    func fetchEntries(userId: String) throws -> [MemoryEntry]

    /// 記憶記録を保存する。
    func saveEntry(
        userId: String,
        title: String,
        period: MemoryPeriod,
        introspectionStatus: MemoryIntrospectionStatus,
        people: [String]
    ) throws

    /// 内観内容を保存する。
    func saveIntrospection(
        entry: MemoryEntry?,
        userId: String,
        title: String,
        period: MemoryPeriod,
        people: [String],
        introspectionStatus: MemoryIntrospectionStatus,
        schemaIds: [String],
        factText: String,
        emotionText: String,
        bodyReactionText: String,
        thoughtText: String,
        desiredResponseText: String,
        fearText: String,
        desiredActionText: String,
        insightText: String
    ) throws -> MemoryEntry

    /// 指定した記憶記録を削除する。
    func deleteEntry(_ entry: MemoryEntry) throws
}

final class LocalMemoryEntryRepository: MemoryEntryRepository {
    private let modelContext: ModelContext

    /// SwiftDataのModelContextで初期化する。
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 指定したユーザーIDの記憶記録を取得する。
    func fetchEntries(userId: String) throws -> [MemoryEntry] {
        let descriptor = FetchDescriptor<MemoryEntry>(
            predicate: #Predicate { entry in
                entry.userId == userId
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// 記憶記録を保存する。
    func saveEntry(
        userId: String,
        title: String,
        period: MemoryPeriod,
        introspectionStatus: MemoryIntrospectionStatus,
        people: [String]
    ) throws {
        let entry = MemoryEntry(
            userId: userId,
            title: title,
            period: period,
            introspectionStatus: introspectionStatus,
            people: people
        )
        modelContext.insert(entry)
        try modelContext.save()
    }

    /// 内観内容を保存する。
    func saveIntrospection(
        entry: MemoryEntry?,
        userId: String,
        title: String,
        period: MemoryPeriod,
        people: [String],
        introspectionStatus: MemoryIntrospectionStatus,
        schemaIds: [String],
        factText: String,
        emotionText: String,
        bodyReactionText: String,
        thoughtText: String,
        desiredResponseText: String,
        fearText: String,
        desiredActionText: String,
        insightText: String
    ) throws -> MemoryEntry {
        let savedEntry = entry ?? MemoryEntry(
            userId: userId,
            title: title,
            period: period,
            introspectionStatus: introspectionStatus,
            people: people
        )

        savedEntry.userId = userId
        savedEntry.title = title
        savedEntry.periodRawValue = period.rawValue
        savedEntry.people = people
        savedEntry.schemaIds = schemaIds
        savedEntry.introspectionStatusRawValue = introspectionStatus.rawValue
        savedEntry.factText = factText
        savedEntry.emotionText = emotionText
        savedEntry.bodyReactionText = bodyReactionText
        savedEntry.thoughtText = thoughtText
        savedEntry.desiredResponseText = desiredResponseText
        savedEntry.fearText = fearText
        savedEntry.desiredActionText = desiredActionText
        savedEntry.insightText = insightText
        savedEntry.updatedAt = Date()

        if entry == nil {
            modelContext.insert(savedEntry)
        }

        try modelContext.save()
        return savedEntry
    }

    /// 指定した記憶記録を削除する。
    func deleteEntry(_ entry: MemoryEntry) throws {
        modelContext.delete(entry)
        try modelContext.save()
    }
}
