//
//  UserProfile.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var userId: String
    var activeCharacterId: String?
    var todayMental: Double?
    var createdAt: Date
    var updatedAt: Date

    /// ユーザー情報を初期化する。
    init(
        userId: String,
        activeCharacterId: String? = nil,
        todayMental: Double? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.userId = userId
        self.activeCharacterId = activeCharacterId
        self.todayMental = todayMental
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
