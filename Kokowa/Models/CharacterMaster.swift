//
//  CharacterMaster.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation

struct CharacterMaster: Identifiable {
    let id: String
    let defaultName: String
    let imageName: String
    let explanation: String
}

enum CharacterMasterStore {
    static let characters: [CharacterMaster] = [
        CharacterMaster(
            id: "kumaneko0001",
            defaultName: "ねこ吉",
            imageName: "kumaneko0001",
            explanation: "ズボラな猫。リッスン姫に恋をするがズボラが原因で振られる。"
        ),
        CharacterMaster(
            id: "uruhuneko0001",
            defaultName: "ウルフン",
            imageName: "uruhuneko0001",
            explanation: "リッスン王国に住む盗賊の頭。金銀財宝が大好き。"
        ),
        CharacterMaster(
            id: "usaneko0001",
            defaultName: "リボン",
            imageName: "usaneko0001",
            explanation: "ねこ吉とは幼馴染。みんなの人気者で、密かにねこ吉に恋をする。"
        )
    ]

    /// 指定したキャラクターIDのマスタ情報を返す。
    static func character(id: String) -> CharacterMaster? {
        characters.first { $0.id == id }
    }
}
