//
//  IntrospectionViewModel.swift
//  Kokowa
//
//  Created by Codex on 2026/07/01.
//

import Foundation
import SwiftUI
import Combine

struct NegativeEmotionCategory: Identifiable {
    let title: String
    let emotions: [String]

    var id: String { title }
}

final class IntrospectionViewModel: ObservableObject {
    @Published var titleText = ""
    @Published var selectedPeriod: MemoryPeriod = .elementary
    @Published var personDraftText = ""
    @Published var people: [String] = []
    @Published var eventDetailText = ""
    @Published var emotionText = ""
    @Published var bodyReactionText = ""
    @Published var thoughtText = ""
    @Published var desiredResponseText = ""
    @Published var desiredActionText = ""
    @Published var isKeyboardVisible = false
    @Published var returnButtonTitle = "ホームに戻る"
    @Published var returnButtonIconName = "house.fill"

    private let dateHelper = DateHelper()
    private var hasConfiguredMemoryEntry = false

    /// 今日の日付表示用テキストを返す。
    var todayText: String {
        dateHelper.todayAddWeek()
    }

    /// 時期の選択肢を返す。
    var periodOptions: [MemoryPeriod] {
        MemoryPeriod.allCases
    }

    /// 相手追加ボタンを無効にするか判定する。
    var isAddPersonButtonDisabled: Bool {
        trimmedPersonDraftText.isEmpty
    }

    /// 出来事欄のプレースホルダーを表示するか判定する。
    var shouldShowEventDetailPlaceholder: Bool {
        eventDetailText.isEmpty
    }

    /// 選択済みの感情を配列で返す。
    var selectedEmotions: [String] {
        emotionText
            .components(separatedBy: "、")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }

    /// 感情の選択肢をカテゴリごとに返す。
    var negativeEmotionCategories: [NegativeEmotionCategory] {
        [
            NegativeEmotionCategory(
                title: "不安・心配",
                emotions: ["不安", "心配", "懸念", "危惧", "焦燥", "動揺", "疑念", "気掛かり", "気掛け", "憂慮"]
            ),
            NegativeEmotionCategory(
                title: "恐れ・怯え",
                emotions: ["恐怖", "恐れ", "怯え", "戦慄", "震え", "おののき", "畏怖", "怖気", "危機感", "寒気", "恐慌", "怯懦"]
            ),
            NegativeEmotionCategory(
                title: "怒り・苛立ち",
                emotions: ["怒り", "憤り", "激怒", "立腹", "苛立ち", "憤怒", "憎悪", "不快", "不満", "むしゃくしゃ", "腹立たしさ"]
            ),
            NegativeEmotionCategory(
                title: "悲しみ・喪失",
                emotions: ["悲しみ", "哀しみ", "落胆", "失望", "絶望", "嘆き", "哀愁", "喪失感", "痛惜", "哀痛", "切なさ", "憂い"]
            ),
            NegativeEmotionCategory(
                title: "虚しさ・倦怠",
                emotions: ["虚無", "空虚", "虚脱", "徒労感", "空疎", "味気なさ", "やるせなさ", "むなしさ", "白け", "倦怠"]
            ),
            NegativeEmotionCategory(
                title: "後悔・自責",
                emotions: ["後悔", "自責", "罪悪感", "悔恨", "反省", "悔しさ", "自省", "慚愧", "負い目", "呵責", "自戒", "苦い思い"]
            ),
            NegativeEmotionCategory(
                title: "恥・屈辱",
                emotions: ["羞恥", "恥辱", "赤面", "面目失墜", "屈辱", "恥ずかしさ", "気まずさ", "いたたまれなさ", "肩身の狭さ"]
            ),
            NegativeEmotionCategory(
                title: "嫉妬・劣等感",
                emotions: ["嫉妬", "妬み", "羨望", "嫉視", "やきもち", "僻み", "劣等感", "敵愾心", "ねたましさ", "焼ける思い", "羨ましさ"]
            ),
            NegativeEmotionCategory(
                title: "嫌悪・拒絶",
                emotions: ["嫌悪", "拒絶", "拒否感", "嫌気", "不快感", "反発", "嫌忌", "毛嫌い", "敬遠", "忌避", "厭悪"]
            ),
            NegativeEmotionCategory(
                title: "疲れ・無力感",
                emotions: ["疲労感", "倦怠感", "無気力", "疲弊", "消耗感", "脱力感", "気疲れ", "倦み", "厭世", "虚脱感", "無力感", "燃え尽き"]
            )
        ]
    }

    /// 身体反応欄のプレースホルダーを表示するか判定する。
    var shouldShowBodyReactionPlaceholder: Bool {
        bodyReactionText.isEmpty
    }

    /// 思考欄のプレースホルダーを表示するか判定する。
    var shouldShowThoughtPlaceholder: Bool {
        thoughtText.isEmpty
    }

    /// どうして欲しかったのか欄のプレースホルダーを表示するか判定する。
    var shouldShowDesiredResponsePlaceholder: Bool {
        desiredResponseText.isEmpty
    }

    /// どうしたかったのか欄のプレースホルダーを表示するか判定する。
    var shouldShowDesiredActionPlaceholder: Bool {
        desiredActionText.isEmpty
    }

    private var trimmedPersonDraftText: String {
        personDraftText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 記憶記録の内容を内観画面の入力欄へ反映する。
    func configure(memoryEntry: MemoryEntry?) {
        updateReturnButton(memoryEntry: memoryEntry)
        guard hasConfiguredMemoryEntry == false, let memoryEntry else { return }

        titleText = memoryEntry.title
        eventDetailText = memoryEntry.title
        selectedPeriod = memoryEntry.period
        personDraftText = memoryEntry.people.first ?? ""
        people = Array(memoryEntry.people.dropFirst())
        hasConfiguredMemoryEntry = true
    }

    /// 相手入力欄の内容を相手リストへ追加する。
    func addPerson() {
        let person = trimmedPersonDraftText
        guard person.isEmpty == false else { return }

        people.append(person)
        personDraftText = ""
    }

    /// 指定した相手を入力中の相手リストから削除する。
    func removePerson(at index: Int) {
        guard people.indices.contains(index) else { return }
        people.remove(at: index)
    }

    /// 指定した相手の入力内容を更新する。
    func updatePerson(at index: Int, text: String) {
        guard people.indices.contains(index) else { return }
        people[index] = text
    }

    /// 指定した感情を選択または解除する。
    func toggleEmotion(_ emotion: String) {
        var emotions = selectedEmotions
        if let index = emotions.firstIndex(of: emotion) {
            emotions.remove(at: index)
        } else {
            emotions.append(emotion)
        }
        emotionText = emotions.joined(separator: "、")
    }

    /// 指定した感情が選択済みか判定する。
    func isEmotionSelected(_ emotion: String) -> Bool {
        selectedEmotions.contains(emotion)
    }

    /// 選択中の感情をすべて解除する。
    func clearEmotions() {
        emotionText = ""
    }

    /// 遷移元に合わせて戻るボタンの表示を切り替える。
    private func updateReturnButton(memoryEntry: MemoryEntry?) {
        if memoryEntry == nil {
            returnButtonTitle = "ホームに戻る"
            returnButtonIconName = "house.fill"
        } else {
            returnButtonTitle = "記憶画面に戻る"
            returnButtonIconName = "heart.text.square.fill"
        }
    }
}
