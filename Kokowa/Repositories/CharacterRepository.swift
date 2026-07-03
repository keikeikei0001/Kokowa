//
//  CharacterRepository.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import SwiftData

protocol CharacterRepository {
    /// 使用中キャラクターを取得する。
    func fetchActiveCharacter(userId: String) throws -> OwnedCharacter?

    /// 所有キャラクターを作成し、使用中キャラクターとして保存する。
    func createInitialCharacter(userId: String, characterId: String, name: String) throws -> OwnedCharacter

    /// 指定したキャラクターに経験値を追加する。
    func addExperience(to character: OwnedCharacter, amount: Int) throws

    /// キャラクターIDとレベルに応じた必要経験値を返す。
    func requiredExperience(characterId: String, level: Int) -> Int
}

final class LocalCharacterRepository: CharacterRepository {
    private let modelContext: ModelContext
    private let userProfileRepository: UserProfileRepository

    /// SwiftDataのModelContextで初期化する。
    init(modelContext: ModelContext, userProfileRepository: UserProfileRepository) {
        self.modelContext = modelContext
        self.userProfileRepository = userProfileRepository
    }

    /// 使用中キャラクターを取得する。
    func fetchActiveCharacter(userId: String) throws -> OwnedCharacter? {
        guard let activeCharacterId = try userProfileRepository.fetchUserProfile(userId: userId)?.activeCharacterId else {
            return nil
        }

        var descriptor = FetchDescriptor<OwnedCharacter>(
            predicate: #Predicate { character in
                character.userId == userId && character.characterId == activeCharacterId
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    /// 所有キャラクターを作成し、使用中キャラクターとして保存する。
    func createInitialCharacter(userId: String, characterId: String, name: String) throws -> OwnedCharacter {
        let character = OwnedCharacter(
            userId: userId,
            characterId: characterId,
            name: name.isEmpty ? (CharacterMasterStore.character(id: characterId)?.defaultName ?? "相棒") : name
        )
        modelContext.insert(character)
        try userProfileRepository.saveUserProfile(userId: userId, activeCharacterId: characterId, todayMental: nil)
        try modelContext.save()
        return character
    }

    /// 指定したキャラクターに経験値を追加する。
    func addExperience(to character: OwnedCharacter, amount: Int) throws {
        character.experiencePoint += amount

        var nextLevelExperience = requiredExperience(characterId: character.characterId, level: character.level)
        while character.experiencePoint >= nextLevelExperience {
            character.experiencePoint -= nextLevelExperience
            character.level += 1
            nextLevelExperience = requiredExperience(characterId: character.characterId, level: character.level)
        }

        character.updatedAt = Date()
        try modelContext.save()
    }

    /// キャラクターIDとレベルに応じた必要経験値を返す。
    func requiredExperience(characterId: String, level: Int) -> Int {
        CharacterMasterStore.requiredExperience(characterId: characterId, level: level)
    }
}
