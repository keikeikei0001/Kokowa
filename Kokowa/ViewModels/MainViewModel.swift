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
    @Published var characterMessageText = ""
    @Published var alert: AlertContext?
    @Published var isLevelUpEffectActive = false
    @Published var isInteractionLocked = false
    @Published var levelUpBackdropOpacity: Double = 0
    @Published var levelUpFlashScale: CGFloat = 0.15
    @Published var levelUpFlashOpacity: Double = 0
    @Published var levelUpRingScale: CGFloat = 0.35
    @Published var levelUpRingOpacity: Double = 0
    @Published var levelUpCharacterScale: CGFloat = 1
    @Published var levelUpCharacterSilhouetteOpacity: Double = 0
    @Published var levelUpTextScale: CGFloat = 0.4
    @Published var levelUpTextOpacity: Double = 0
    @Published var levelUpParticleOpacity: Double = 0
    @Published var levelUpParticleProgress = false

    private var userId: String?
    private var characterRepository: CharacterRepository?
    private var userProfileRepository: UserProfileRepository?
    private var lastCharacterMessageShownAt: Date?
    private var characterMessageToken = 0
    private let baseCharacterLayoutWidth: CGFloat = 390
    private let baseShadowHeight: CGFloat = 30
    private let userDefaultsRepository = UserDefaultsRepository()
    private let soundPlayer = SoundPlayer()
    private let characterMessageCooldown: TimeInterval = 3
    private let characterMessageDisplayDuration: TimeInterval = 2
    private let characterMessages = [
        "おかえり。今日も会えてうれしいよ。",
        "今日も一日、おつかれさま。",
        "ここでは肩の力を抜いていいんだよ。",
        "今日の気持ち、少しだけ教えてくれる？",
        "どんな日でも、ここに来てくれてありがとう。",
        "無理に元気にならなくても大丈夫。",
        "今日はどんな景色を見てきたの？",
        "うれしかったことが一つでもあったら教えてね。",
        "つらかったことも、ここなら話して大丈夫だよ。",
        "少し休んでいこうか。",
        "今の気持ちに、正解も間違いもないよ。",
        "今日は自分に優しくできそうかな？",
        "深呼吸して、ゆっくりいこう。",
        "きみの毎日を、ぼくは見守っているよ。",
        "今日という日も、大切な一日だったね。",
        "心が疲れた日は、休むことも大事だよ。",
        "また話したくなったら、いつでも来てね。",
        "今日も会いに来てくれてありがとう。",
        "明日がどんな日でも、ぼくはここにいるよ。",
        "今日も本当に、おつかれさま。"
    ]
    let levelUpParticles: [LevelUpParticle] = [
        LevelUpParticle(id: 0, x: -84, y: -154, size: 5, delay: 0.00),
        LevelUpParticle(id: 1, x: -46, y: -128, size: 4, delay: 0.03),
        LevelUpParticle(id: 2, x: -12, y: -176, size: 6, delay: 0.06),
        LevelUpParticle(id: 3, x: 34, y: -142, size: 4, delay: 0.09),
        LevelUpParticle(id: 4, x: 76, y: -166, size: 5, delay: 0.12),
        LevelUpParticle(id: 5, x: 96, y: -92, size: 4, delay: 0.15),
        LevelUpParticle(id: 6, x: 52, y: -210, size: 6, delay: 0.18),
        LevelUpParticle(id: 7, x: -74, y: -214, size: 4, delay: 0.21),
        LevelUpParticle(id: 8, x: 6, y: -118, size: 5, delay: 0.24),
        LevelUpParticle(id: 9, x: -108, y: -104, size: 4, delay: 0.27),
        LevelUpParticle(id: 10, x: 118, y: -132, size: 5, delay: 0.30),
        LevelUpParticle(id: 11, x: -26, y: -232, size: 4, delay: 0.33)
    ]

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

    /// レベルアップ演出中のレベル表示テキストを返す。
    var levelUpText: String {
        "Lv.\(characterLevelText)"
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

    /// 表示領域に応じたキャラクター画像の高さを返す。
    func characterImageHeight(in screenSize: CGSize) -> CGFloat {
        characterImageWidth(in: screenSize) / characterMaster.homeImageAspectRatio
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

    /// ジャンプなどの一時的な動きを含まないキャラクター画像の縦位置調整量を返す。
    func characterBaseFootOffsetY(in screenSize: CGSize) -> CGFloat {
        characterMaster.homeFootOffsetY * characterLayoutScale(in: screenSize)
    }

    /// 表示領域に応じたキャラクターメッセージの横位置調整量を返す。
    func characterMessageOffsetX(in screenSize: CGSize) -> CGFloat {
        characterFootOffsetX(in: screenSize)
    }

    /// キャラクターの上端から少し離れた位置へメッセージを置くための縦位置を返す。
    func characterMessageOffsetY(in screenSize: CGSize) -> CGFloat {
        let messageGap = characterMaster.homeMessageTopGap * characterLayoutScale(in: screenSize)
        return characterBaseFootOffsetY(in: screenSize) - characterImageHeight(in: screenSize) - messageGap
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

        soundPlayer.playLevelUpSound()

        withAnimation(.easeOut(duration: 0.28)) {
            levelUpBackdropOpacity = 0.28
            levelUpFlashScale = 1.05
            levelUpFlashOpacity = 0.86
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.easeOut(duration: 0.62)) {
                self.levelUpFlashScale = 1.45
                self.levelUpFlashOpacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            self.levelUpRingOpacity = 0.9
            withAnimation(.easeOut(duration: 0.78)) {
                self.levelUpRingScale = 1.68
                self.levelUpRingOpacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.46)) {
                self.levelUpCharacterScale = 1.18
                self.levelUpCharacterSilhouetteOpacity = 0.9
            }
        }

        runLevelUpJumpSequence()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.52) {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.62)) {
                self.levelUpTextScale = 1
                self.levelUpTextOpacity = 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.68) {
            self.levelUpParticleOpacity = 1
            withAnimation(.easeOut(duration: 0.95)) {
                self.levelUpParticleProgress = true
                self.levelUpParticleOpacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.68)) {
                self.levelUpCharacterScale = 1
                self.levelUpCharacterSilhouetteOpacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.45) {
            withAnimation(.easeInOut(duration: 0.42)) {
                self.levelUpBackdropOpacity = 0
                self.levelUpTextOpacity = 0
                self.levelUpTextScale = 0.72
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.05) {
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

        showCharacterMessageIfAvailable()

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

    }

    /// キャラクターがジャンプする演出を実行する。
    private func occurCharacterJumpEffect() {
        let jumpHeight: CGFloat = -34
        let upDuration: TimeInterval = 0.18
        let downDuration: TimeInterval = 0.24

        showCharacterMessageIfAvailable()

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

    }

    private var characterMaster: CharacterMaster {
        guard let activeCharacter else {
            return CharacterMasterStore.character(id: "uruhuneko0001") ?? CharacterMasterStore.characters[0]
        }

        return CharacterMasterStore.character(id: activeCharacter.characterId) ?? CharacterMasterStore.characters[0]
    }

    /// タップ時に表示するキャラクターの言葉を更新する。
    private func updateCharacterMessage() {
        let nextMessage = characterMessages.randomElement() ?? ""
        guard characterMessages.count > 1 else {
            characterMessageText = nextMessage
            return
        }

        if nextMessage == characterMessageText {
            characterMessageText = characterMessages.first { $0 != characterMessageText } ?? nextMessage
        } else {
            characterMessageText = nextMessage
        }
    }

    /// 一定時間以上空けてタップされた場合だけキャラクターの言葉を表示する。
    private func showCharacterMessageIfAvailable() {
        let now = Date()
        if let lastCharacterMessageShownAt,
           now.timeIntervalSince(lastCharacterMessageShownAt) < characterMessageCooldown {
            return
        }

        lastCharacterMessageShownAt = now
        characterMessageToken += 1
        let currentToken = characterMessageToken

        updateCharacterMessage()
        motion.showMessage = true

        DispatchQueue.main.asyncAfter(deadline: .now() + characterMessageDisplayDuration) {
            guard self.characterMessageToken == currentToken else { return }

            withAnimation(.easeInOut(duration: 0.25)) {
                self.motion.showMessage = false
            }
        }
    }

    /// レベルアップ演出の値を初期化する。
    private func resetLevelUpEffectValues() {
        motion.jumpOffset = 0
        motion.shadowScale = 1
        motion.rotationAngle = 0
        motion.showMessage = false
        levelUpBackdropOpacity = 0
        levelUpFlashScale = 0.15
        levelUpFlashOpacity = 0
        levelUpRingScale = 0.35
        levelUpRingOpacity = 0
        levelUpCharacterScale = 1
        levelUpCharacterSilhouetteOpacity = 0
        levelUpTextScale = 0.4
        levelUpTextOpacity = 0
        levelUpParticleOpacity = 0
        levelUpParticleProgress = false
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
            title: "レベルアップおめでとう！！",
            message: "無理をしない程度にこの調子でやっていこう！！",
            actions: [
                AlertContext.Action(title: "OK", role: nil) { [weak self] _ in
                    self?.alert = nil
                    self?.isInteractionLocked = false
                }
            ]
        )
    }
}
