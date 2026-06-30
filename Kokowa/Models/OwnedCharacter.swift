//
//  OwnedCharacter.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import SwiftData

@Model
final class OwnedCharacter {
    @Attribute(.unique) var id: UUID
    var userId: String
    var characterId: String
    var name: String
    var level: Int
    var experiencePoint: Int
    var createdAt: Date
    var updatedAt: Date

    /// 所有キャラクター情報を初期化する。
    init(
        id: UUID = UUID(),
        userId: String,
        characterId: String,
        name: String,
        level: Int = 1,
        experiencePoint: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.characterId = characterId
        self.name = name
        self.level = level
        self.experiencePoint = experiencePoint
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
