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
    var experiencePoint = 10
    var levelUpNeedExperience = 10
}

struct UserData {
    var currentMentalPoint = 8.0
    var mainCharacterState = MainCharacterState()
}

class MainViewModel: ObservableObject {
    @Published var character = MainCharacterState()
    @Published var userData = UserData()
    @Published var motion = MainCharacterMotion()
    @Published var alert: AlertContext?

    var characterExpText: String {
        "\(character.experiencePoint) / \(character.levelUpNeedExperience)"
    }

    var characterMentalText: String {
        "\(userData.currentMentalPoint)"
    }

    var characterImageSize: CGFloat {
        if character.imageName == "usaneko0001" {
            return DeviceModel.width / 1.93
        }
        return DeviceModel.width / 1.8
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
