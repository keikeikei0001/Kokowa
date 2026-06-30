//
//  CharacterSelectViewModel.swift
//  LifeIsRpg
//
//  Created by けいけい on 2024/11/25.
//

import SwiftUI
import Combine

class CharacterSelectedViewModel: ObservableObject {
    @Published var selectedCharacterIndex = 0

    /// 選択中キャラクター画像の表示サイズを返す。
    var characterImageSize: CGFloat {
        if self.selectedCharacterIndex == 2 {
            DeviceModel.width / 1.8
        } else {
            DeviceModel.width / 2.5
        }
    }

    /// 選択中キャラクターの名前を返す。
    var selectedCharacterName: String {
        characters[selectedCharacterIndex].defaultName
    }

    /// 選択中キャラクターの画像名を返す。
    var selectedCharacterImageName: String {
        characters[selectedCharacterIndex].imageName
    }

    /// 選択中キャラクターの説明文を返す。
    var selectedCharacterExplanation: String {
        characters[selectedCharacterIndex].explanation
    }

    /// キャラクターの情報を保持する。
    let characters = CharacterMasterStore.characters
}
