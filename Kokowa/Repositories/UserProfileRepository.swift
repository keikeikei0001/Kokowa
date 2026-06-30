//
//  UserProfileRepository.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import SwiftData

protocol UserProfileRepository {
    /// 指定したユーザーIDのユーザー情報を取得する。
    func fetchUserProfile(userId: String) throws -> UserProfile?

    /// ユーザー情報を作成または更新する。
    func saveUserProfile(userId: String, activeCharacterId: String?, todayMental: Double?) throws
}

final class LocalUserProfileRepository: UserProfileRepository {
    private let modelContext: ModelContext

    /// SwiftDataのModelContextで初期化する。
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 指定したユーザーIDのユーザー情報を取得する。
    func fetchUserProfile(userId: String) throws -> UserProfile? {
        var descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { profile in
                profile.userId == userId
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    /// ユーザー情報を作成または更新する。
    func saveUserProfile(userId: String, activeCharacterId: String?, todayMental: Double?) throws {
        let existingProfile = try fetchUserProfile(userId: userId)
        let profile = existingProfile ?? UserProfile(userId: userId)
        profile.activeCharacterId = activeCharacterId
        profile.todayMental = todayMental
        profile.updatedAt = Date()

        if existingProfile == nil {
            modelContext.insert(profile)
        }

        try modelContext.save()
    }
}
