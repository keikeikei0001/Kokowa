//
//  MainViewModel.swift
//  Kokowa
//
//  Created by 松田圭右 on 2024/05/06.
//

import SwiftUI
import Combine

struct MainCharacterState {
    var name = "ウルフねこ"
    var imageName = "uruhuneko0001"
    var level = 1
    var experiencePoint = 0
    var nextLevelExperience = 10
    var currentHealthPoint: Double = 8
    var maxHealthPoint: Double = 10
}

struct MainCharacterMotion {
    var jumpOffset: CGFloat = 0
    var shadowScale: CGFloat = 1
    var rotationAngle: Double = 0
    var showMessage = false
}

class MainViewModel: ObservableObject {
    @Published var character = MainCharacterState()
    @Published var motion = MainCharacterMotion()
    @Published var alert: AlertContext?

    var hpRatio: Double {
        guard character.maxHealthPoint > 0 else { return 0 }
        return character.currentHealthPoint / character.maxHealthPoint
    }

    var expRatio: Double {
        guard character.nextLevelExperience > 0 else { return 0 }
        return Double(character.experiencePoint) / Double(character.nextLevelExperience)
    }

    var characterExpText: String {
        "\(character.experiencePoint) / \(character.nextLevelExperience)"
    }

    var characterHpText: String {
        "\(Int(character.currentHealthPoint)) / \(Int(character.maxHealthPoint))"
    }

    var characterImageSize: CGFloat {
        if character.imageName == "usaneko0001" {
            return DeviceModel.width / 1.45
        }
        return DeviceModel.width / 1.35
    }

    var characterMessageOpacity: Double {
        motion.showMessage ? 1 : 0
    }

    func handleOnAppear() {
        loadInitialCharacter()
    }

    func handleCharacterImageTap() {
        if Bool.random() {
            occurCharacterTiltEffect()
        } else {
            occurCharacterJumpEffect()
        }
    }

    private func loadInitialCharacter() {
        // TODO: キャラクター保存処理を作ったら、ここで保存済みデータを読み込む。
        character = MainCharacterState()
    }

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
