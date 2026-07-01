//
//  AccountRepository.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import SwiftData

protocol AccountRepository {
    /// 指定したユーザーIDに紐づくローカル保存データを削除する。
    func deleteAccountData(userId: String) throws
}

final class LocalAccountRepository: AccountRepository {
    private let modelContext: ModelContext

    /// SwiftDataのModelContextで初期化する。
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 指定したユーザーIDに紐づくローカル保存データを削除する。
    func deleteAccountData(userId: String) throws {
        try deleteUserProfiles(userId: userId)
        try deleteOwnedCharacters(userId: userId)
        try deleteMentalEntries(userId: userId)
        try deleteMemoryEntries(userId: userId)
        try modelContext.save()
    }

    /// 指定したユーザーIDのユーザー情報を削除する。
    private func deleteUserProfiles(userId: String) throws {
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { profile in
                profile.userId == userId
            }
        )
        try modelContext.fetch(descriptor).forEach { profile in
            modelContext.delete(profile)
        }
    }

    /// 指定したユーザーIDの所有キャラクターを削除する。
    private func deleteOwnedCharacters(userId: String) throws {
        let descriptor = FetchDescriptor<OwnedCharacter>(
            predicate: #Predicate { character in
                character.userId == userId
            }
        )
        try modelContext.fetch(descriptor).forEach { character in
            modelContext.delete(character)
        }
    }

    /// 指定したユーザーIDのメンタル記録を削除する。
    private func deleteMentalEntries(userId: String) throws {
        let descriptor = FetchDescriptor<MentalEntry>(
            predicate: #Predicate { entry in
                entry.userId == userId
            }
        )
        try modelContext.fetch(descriptor).forEach { entry in
            modelContext.delete(entry)
        }
    }

    /// 指定したユーザーIDの記憶記録を削除する。
    private func deleteMemoryEntries(userId: String) throws {
        let descriptor = FetchDescriptor<MemoryEntry>(
            predicate: #Predicate { entry in
                entry.userId == userId
            }
        )
        try modelContext.fetch(descriptor).forEach { entry in
            modelContext.delete(entry)
        }
    }
}
