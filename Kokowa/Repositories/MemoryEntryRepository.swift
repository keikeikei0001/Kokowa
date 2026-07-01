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

    /// 指定した記憶記録を削除する。
    func deleteEntry(_ entry: MemoryEntry) throws {
        modelContext.delete(entry)
        try modelContext.save()
    }
}
