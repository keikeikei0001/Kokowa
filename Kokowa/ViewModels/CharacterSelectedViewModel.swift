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
    
    var characterImageSize: CGFloat {
        if self.selectedCharacterIndex == 2 {
            DeviceModel.width / 1.8
        } else {
            DeviceModel.width / 2.5
        }
    }
    
    // キャラクターの情報（個体名と画像と説明）
    let characters: [(name: String, imageName: String, explanation: String)] = [
        ("ねこ吉", "kumaneko0001", "ズボラな猫。リッスン姫に恋をするがズボラが原因で振られる。"),
        ("ウルフン", "uruhuneko0001", "リッスン王国に住む盗賊の頭。金銀財宝が大好き。"),
        ("リボン", "usaneko0001", "ねこ吉とは幼馴染。みんなの人気者で、密かにねこ吉に恋をする。")
    ]
}
