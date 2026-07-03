//
//  MainViewModel.swift
//  Kokowa
//
//  Created by 松田圭右 on 2024/05/06.
//

import SwiftUI
import Combine
import SwiftData
import AudioToolbox

class MainViewModel: ObservableObject {
    @Published var activeCharacter: OwnedCharacter?
    @Published var userProfile: UserProfile?
    @Published var motion = MainCharacterMotion()
    @Published var alert: AlertContext?
    @Published var isLevelUpEffectActive = false
    @Published var isInteractionLocked = false
    @Published var levelUpRingScale: CGFloat = 0.25
    @Published var levelUpRingOpacity: Double = 0
    @Published var levelUpSparkleScale: CGFloat = 0.4
    @Published var levelUpSparkleOpacity: Double = 0
    @Published var levelUpSparkleRotation: Double = 0

    private var userId: String?
    private var characterRepository: CharacterRepository?
    private var userProfileRepository: UserProfileRepository?
    private let baseCharacterLayoutWidth: CGFloat = 390
    private let baseShadowHeight: CGFloat = 30
    private let userDefaultsRepository = UserDefaultsRepository()
    private let soundPlayer = SoundPlayer()

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

        let requiredExperience = characterRepository?.requiredExperience(
            characterId: activeCharacter.characterId,
            level: activeCharacter.level
        ) ?? 10
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
        characterMaster.imageName
    }

    /// キャラクターのメッセージを表示する透明度を返す。
    var characterMessageOpacity: Double {
        motion.showMessage ? 1 : 0
    }

    /// 表示領域に応じたキャラクターステージの高さを返す。
    func characterStageHeight(in screenSize: CGSize) -> CGFloat {
        min(max(screenSize.height * 0.42, 240), 420)
    }

    /// 表示領域に応じたキャラクター画像の幅を返す。
    func characterImageWidth(in screenSize: CGSize) -> CGFloat {
        screenSize.width / characterMaster.homeImageWidthRatio
    }

    /// キャラクター画像の表示倍率を返す。
    func characterLayoutScale(in screenSize: CGSize) -> CGFloat {
        let baseImageWidth = baseCharacterLayoutWidth / characterMaster.homeImageWidthRatio
        return characterImageWidth(in: screenSize) / baseImageWidth
    }

    /// 表示領域に応じたキャラクター画像の横位置調整量を返す。
    func characterFootOffsetX(in screenSize: CGSize) -> CGFloat {
        characterMaster.homeFootOffsetX * characterLayoutScale(in: screenSize)
    }

    /// 表示領域に応じたキャラクター画像の縦位置調整量を返す。
    func characterFootOffsetY(in screenSize: CGSize) -> CGFloat {
        (characterMaster.homeFootOffsetY * characterLayoutScale(in: screenSize)) + motion.jumpOffset
    }

    /// 表示領域に応じたキャラクター影の幅を返す。
    func characterShadowWidth(in screenSize: CGSize) -> CGFloat {
        characterMaster.homeShadowWidth * characterLayoutScale(in: screenSize) * motion.shadowScale
    }

    /// 表示領域に応じたキャラクター影の高さを返す。
    func characterShadowHeight(in screenSize: CGSize) -> CGFloat {
        baseShadowHeight * characterLayoutScale(in: screenSize) * motion.shadowScale
    }

    /// 表示領域に応じたキャラクター影の縦位置を返す。
    func characterShadowOffsetY(in screenSize: CGSize) -> CGFloat {
        (characterMaster.homeFootOffsetY + characterMaster.homeShadowFootGap) * characterLayoutScale(in: screenSize)
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

    /// 予約済みのレベルアップ演出があれば開始する。
    func startPendingLevelUpEffectIfNeeded() {
        guard userDefaultsRepository.hasPendingLevelUpEffect() else { return }
        userDefaultsRepository.deletePendingLevelUpEffect()
        startLevelUpEffect()
    }

    /// キャラクター画像タップ時のリアクションを実行する。
    func handleCharacterImageTap() {
        guard isInteractionLocked == false else { return }

        if Bool.random() {
            occurCharacterTiltEffect()
        } else {
            occurCharacterJumpEffect()
        }
    }

    /// レベルアップ演出を開始する。
    func startLevelUpEffect() {
        guard isLevelUpEffectActive == false else { return }

        loadInitialCharacter()
        resetLevelUpEffectValues()
        isInteractionLocked = true
        isLevelUpEffectActive = true
        withAnimation(.easeOut(duration: 1.1)) {
            levelUpRingScale = 1.45
            levelUpRingOpacity = 0.9
            levelUpSparkleScale = 1
            levelUpSparkleOpacity = 1
            levelUpSparkleRotation = 120
            soundPlayer.playLevelUpSound()
        }

        runLevelUpJumpSequence()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.55) {
            withAnimation(.easeInOut(duration: 0.72)) {
                self.levelUpRingScale = 2.1
                self.levelUpRingOpacity = 0
                self.levelUpSparkleOpacity = 0
                self.levelUpSparkleRotation = 220
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.35) {
            self.isLevelUpEffectActive = false
            self.showLevelUpAlert()
        }
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

    private var characterMaster: CharacterMaster {
        guard let activeCharacter else {
            return CharacterMasterStore.character(id: "uruhuneko0001") ?? CharacterMasterStore.characters[0]
        }

        return CharacterMasterStore.character(id: activeCharacter.characterId) ?? CharacterMasterStore.characters[0]
    }

    /// レベルアップ演出の値を初期化する。
    private func resetLevelUpEffectValues() {
        motion.jumpOffset = 0
        motion.shadowScale = 1
        motion.rotationAngle = 0
        motion.showMessage = false
        levelUpRingScale = 0.25
        levelUpRingOpacity = 0
        levelUpSparkleScale = 0.4
        levelUpSparkleOpacity = 0
        levelUpSparkleRotation = 0
    }

    /// レベルアップ時のジャンプ演出を実行する。
    private func runLevelUpJumpSequence() {
        let jumpHeight: CGFloat = -52
        let upDuration: TimeInterval = 0.18
        let downDuration: TimeInterval = 0.22

        withAnimation(.easeOut(duration: upDuration)) {
            motion.jumpOffset = jumpHeight
            motion.shadowScale = 0.62
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + upDuration) {
            withAnimation(.easeIn(duration: downDuration)) {
                self.motion.jumpOffset = 0
                self.motion.shadowScale = 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.54) {
            withAnimation(.easeOut(duration: upDuration)) {
                self.motion.jumpOffset = jumpHeight * 0.72
                self.motion.shadowScale = 0.74
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.54 + upDuration) {
            withAnimation(.easeIn(duration: downDuration)) {
                self.motion.jumpOffset = 0
                self.motion.shadowScale = 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.08) {
            withAnimation(.easeOut(duration: upDuration)) {
                self.motion.jumpOffset = jumpHeight * 0.46
                self.motion.shadowScale = 0.84
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.08 + upDuration) {
            withAnimation(.easeIn(duration: downDuration)) {
                self.motion.jumpOffset = 0
                self.motion.shadowScale = 1
            }
        }
    }

    /// レベルアップ完了後のアラートを表示する。
    private func showLevelUpAlert() {
        alert = AlertContext(
            title: "おめでとう！！",
            message: "この調子で頑張ろう！！",
            actions: [
                AlertContext.Action(title: "OK", role: nil) { [weak self] _ in
                    self?.alert = nil
                    self?.isInteractionLocked = false
                }
            ]
        )
    }
}
