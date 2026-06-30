//
//  MainViewModel.swift
//  Kokowa
//
//  Created by 松田圭右 on 2024/05/06.
//

import SwiftUI
import Combine
import SwiftData

class MainViewModel: ObservableObject {
    @Published var activeCharacter: OwnedCharacter?
    @Published var userProfile: UserProfile?
    @Published var motion = MainCharacterMotion()
    @Published var alert: AlertContext?

    private var userId: String?
    private var characterRepository: CharacterRepository?
    private var userProfileRepository: UserProfileRepository?

    /// キャラクター名の表示用テキストを返す。
    var characterNameText: String {
        activeCharacter?.name ?? "相棒"
    }

    /// キャラクターレベルの表示用テキストを返す。
    var characterLevelText: String {
        "\(activeCharacter?.level ?? 1)"
    }

    /// キャラクターの経験値表示用テキストを返す。
    var characterExpText: String {
        guard let activeCharacter else {
            return "0 / 10"
        }

        let requiredExperience = characterRepository?.requiredExperience(for: activeCharacter.level) ?? 10
        return "\(activeCharacter.experiencePoint) / \(requiredExperience)"
    }

    /// ユーザーの現在メンタル値を表示用テキストで返す。
    var characterMentalText: String {
        guard let todayMental = userProfile?.todayMental else {
            return "ー"
        }
        return "\(todayMental)"
    }

    /// キャラクター画像名を返す。
    var characterImageName: String {
        guard let activeCharacter else {
            return "uruhuneko0001"
        }

        return CharacterMasterStore.character(id: activeCharacter.characterId)?.imageName ?? activeCharacter.characterId
    }

    /// キャラクター画像の表示幅を返す。
    var characterImageSize: CGFloat {
        if characterImageName == "usaneko0001" {
            return DeviceModel.width / 1.93
        }
        return DeviceModel.width / 1.8
    }

    /// キャラクターのメッセージを表示する透明度を返す。
    var characterMessageOpacity: Double {
        motion.showMessage ? 1 : 0
    }

    /// 表示に必要なリポジトリをセットする。
    func configure(modelContext: ModelContext, userId: String?) {
        self.userId = userId
        let userProfileRepository = LocalUserProfileRepository(modelContext: modelContext)
        self.userProfileRepository = userProfileRepository
        self.characterRepository = LocalCharacterRepository(
            modelContext: modelContext,
            userProfileRepository: userProfileRepository
        )
        loadInitialCharacter()
    }

    /// キャラクター画像タップ時のリアクションを実行する。
    func handleCharacterImageTap() {
        if Bool.random() {
            occurCharacterTiltEffect()
        } else {
            occurCharacterJumpEffect()
        }
    }

    /// キャラクターの影の縦位置を返す。
    func characterShadowOffsetY(sceneHeight: CGFloat) -> CGFloat {
        min(sceneHeight * 0.19, 96)
    }

    /// 初期表示用のキャラクター情報を読み込む。
    private func loadInitialCharacter() {
        guard
            let userId,
            let characterRepository,
            let userProfileRepository
        else {
            activeCharacter = nil
            userProfile = nil
            return
        }

        do {
            activeCharacter = try characterRepository.fetchActiveCharacter(userId: userId)
            userProfile = try userProfileRepository.fetchUserProfile(userId: userId)
        } catch {
            activeCharacter = nil
            userProfile = nil
        }
    }

    /// キャラクターが左右に揺れる演出を実行する。
    private func occurCharacterTiltEffect() {
        let tiltAngle: Double = 5
        let stepDuration: TimeInterval = 0.1

        motion.showMessage = true

        withAnimation(.easeInOut(duration: stepDuration)) {
            motion.rotationAngle = -tiltAngle
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
            withAnimation(.easeInOut(duration: stepDuration)) {
                self.motion.rotationAngle = tiltAngle
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * 2) {
            withAnimation(.easeInOut(duration: stepDuration)) {
                self.motion.rotationAngle = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.easeInOut(duration: 0.25)) {
                self.motion.showMessage = false
            }
        }
    }

    /// キャラクターがジャンプする演出を実行する。
    private func occurCharacterJumpEffect() {
        let jumpHeight: CGFloat = -34
        let upDuration: TimeInterval = 0.18
        let downDuration: TimeInterval = 0.24

        motion.showMessage = true

        withAnimation(.easeOut(duration: upDuration)) {
            motion.jumpOffset = jumpHeight
            motion.shadowScale = 0.72
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + upDuration) {
            withAnimation(.easeIn(duration: downDuration)) {
                self.motion.jumpOffset = 0
                self.motion.shadowScale = 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + upDuration + downDuration + 0.55) {
            withAnimation(.easeInOut(duration: 0.25)) {
                self.motion.showMessage = false
            }
        }
    }
}
