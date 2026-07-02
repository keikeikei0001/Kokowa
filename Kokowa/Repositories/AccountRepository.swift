//
//  AccountRepository.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import SwiftData

protocol AccountRepository {
    /// この端末に保存されているアプリ内データをすべて削除する。
    func deleteAllLocalData() throws
}

final class LocalAccountRepository: AccountRepository {
    private let modelContext: ModelContext

    /// SwiftDataのModelContextで初期化する。
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// この端末に保存されているアプリ内データをすべて削除する。
    func deleteAllLocalData() throws {
        try deleteAllUserProfiles()
        try deleteAllOwnedCharacters()
        try deleteAllMentalEntries()
        try deleteAllMemoryEntries()
        try modelContext.save()
    }

    /// すべてのユーザー情報を削除する。
    private func deleteAllUserProfiles() throws {
        try modelContext.fetch(FetchDescriptor<UserProfile>()).forEach { profile in
            modelContext.delete(profile)
        }
    }

    /// すべての所有キャラクターを削除する。
    private func deleteAllOwnedCharacters() throws {
        try modelContext.fetch(FetchDescriptor<OwnedCharacter>()).forEach { character in
            modelContext.delete(character)
        }
    }

    /// すべてのメンタル記録を削除する。
    private func deleteAllMentalEntries() throws {
        try modelContext.fetch(FetchDescriptor<MentalEntry>()).forEach { entry in
            modelContext.delete(entry)
        }
    }

    /// すべての記憶記録を削除する。
    private func deleteAllMemoryEntries() throws {
        try modelContext.fetch(FetchDescriptor<MemoryEntry>()).forEach { entry in
            modelContext.delete(entry)
        }
    }
}
