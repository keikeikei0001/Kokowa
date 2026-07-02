//
//  CharacterMaster.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import SwiftUI

struct CharacterMaster: Identifiable {
    let id: String
    let defaultName: String
    let imageName: String
    let explanation: String
    let homeImageWidthRatio: CGFloat
    let homeFootOffsetY: CGFloat
    let homeShadowWidth: CGFloat
    let homeShadowHeight: CGFloat
    let homeShadowOffsetY: CGFloat

    /// キャラクターのマスター情報を初期化する。
    init(
        id: String,
        defaultName: String,
        imageName: String,
        explanation: String,
        homeImageWidthRatio: CGFloat = 1.8,
        homeFootOffsetY: CGFloat = 0,
        homeShadowWidth: CGFloat = 180,
        homeShadowHeight: CGFloat = 34,
        homeShadowOffsetY: CGFloat = 86
    ) {
        self.id = id
        self.defaultName = defaultName
        self.imageName = imageName
        self.explanation = explanation
        self.homeImageWidthRatio = homeImageWidthRatio
        self.homeFootOffsetY = homeFootOffsetY
        self.homeShadowWidth = homeShadowWidth
        self.homeShadowHeight = homeShadowHeight
        self.homeShadowOffsetY = homeShadowOffsetY
    }
}

enum CharacterMasterStore {
    static let characters: [CharacterMaster] = [
        CharacterMaster(
            id: "kumaneko0001",
            defaultName: "ねこ吉",
            imageName: "kumaneko0001",
            explanation: "ズボラな猫。リッスン姫に恋をするがズボラが原因で振られる。",
            homeImageWidthRatio: 1.86,
            homeFootOffsetY: -18,
            homeShadowWidth: 168,
            homeShadowHeight: 30,
            homeShadowOffsetY: 70
        ),
        CharacterMaster(
            id: "uruhuneko0001",
            defaultName: "ウルフン",
            imageName: "uruhuneko0001",
            explanation: "リッスン王国に住む盗賊の頭。金銀財宝が大好き。",
            homeImageWidthRatio: 1.86,
            homeFootOffsetY: -14,
            homeShadowWidth: 176,
            homeShadowHeight: 32,
            homeShadowOffsetY: 74
        ),
        CharacterMaster(
            id: "usaneko0001",
            defaultName: "リボン",
            imageName: "usaneko0001",
            explanation: "ねこ吉とは幼馴染。みんなの人気者で、密かにねこ吉に恋をする。",
            homeImageWidthRatio: 1.28,
            homeFootOffsetY: -22,
            homeShadowWidth: 174,
            homeShadowHeight: 31,
            homeShadowOffsetY: 70
        )
    ]

    /// 指定したキャラクターIDのマスタ情報を返す。
    static func character(id: String) -> CharacterMaster? {
        characters.first { $0.id == id }
    }
}
