//
//  IntrospectionViewModel.swift
//  Kokowa
//
//  Created by Codex on 2026/07/01.
//

import Foundation
import SwiftUI
import Combine
import SwiftData

struct NegativeEmotionCategory: Identifiable {
    let title: String
    let emotions: [String]

    var id: String { title }
}

struct FeelingReactionCategory: Identifiable {
    let title: String
    let feelings: [String]

    var id: String { title }
}

final class IntrospectionViewModel: ObservableObject {
    @Published var titleText = ""
    @Published var selectedPeriod: MemoryPeriod = .elementary
    @Published var personDraftText = ""
    @Published var people: [String] = []
    @Published var emotionReleaseText = ""
    @Published var factText = ""
    @Published var emotionText = ""
    @Published var feelingText = ""
    @Published var bodyReactionText = ""
    @Published var thoughtText = ""
    @Published var desiredResponseText = ""
    @Published var fearText = ""
    @Published var desiredActionText = ""
    @Published var insightText = ""
    @Published var isKeyboardVisible = false
    @Published var returnButtonTitle = "ホームに戻る"
    @Published var returnButtonIconName = "house.fill"
    @Published var saveResultText = ""

    private let dateHelper = DateHelper()
    private var userId: String?
    private var memoryEntry: MemoryEntry?
    private var memoryEntryRepository: MemoryEntryRepository?
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

    /// 新しく入力する相手欄の番号を返す。
    var personDraftNumberText: String {
        "\(people.count + 1)"
    }

    /// 感情吐き出し欄のプレースホルダーを表示するか判定する。
    var shouldShowEmotionReleasePlaceholder: Bool {
        emotionReleaseText.isEmpty
    }

    /// 事実欄のプレースホルダーを表示するか判定する。
    var shouldShowFactPlaceholder: Bool {
        factText.isEmpty
    }

    /// 選択済みの感情を配列で返す。
    var selectedEmotions: [String] {
        emotionText
            .components(separatedBy: "、")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }

    /// 選択済みの気持ちを配列で返す。
    var selectedFeelings: [String] {
        feelingText
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

    /// 気持ちの選択肢をカテゴリごとに返す。
    var feelingReactionCategories: [FeelingReactionCategory] {
        [
            FeelingReactionCategory(
                title: "傷つき・圧迫",
                feelings: [
                    "あざけられた",
                    "あやつられた",
                    "威圧された",
                    "息が詰まった",
                    "いらだった",
                    "裏切られた",
                    "追い出された",
                    "追いつめられた",
                    "脅かされた",
                    "おとしめられた",
                    "格下げされた",
                    "価値を下げられた"
                ]
            ),
            FeelingReactionCategory(
                title: "拒絶・攻撃",
                feelings: [
                    "傷つけられた",
                    "気分を害された",
                    "拒絶された",
                    "嫌われた",
                    "軽蔑された",
                    "攻撃された",
                    "告発された",
                    "裁かれた",
                    "しつこく悩まされた",
                    "叱責された"
                ]
            ),
            FeelingReactionCategory(
                title: "支配・侵害",
                feelings: [
                    "支配された",
                    "侵入された",
                    "捨てられた",
                    "責められた",
                    "だまされた",
                    "付け込まれた",
                    "つぶされた",
                    "なおざりにされた",
                    "盗まれた",
                    "離れた"
                ]
            ),
            FeelingReactionCategory(
                title: "否定・孤立",
                feelings: [
                    "はねつけられた",
                    "否定された",
                    "侮辱された",
                    "暴行された",
                    "見捨てられた",
                    "むごく扱われた",
                    "無視された",
                    "汚された",
                    "理解されない",
                    "利用された",
                    "罠にはめられた",
                    "笑いものにされた"
                ]
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

    /// 何を恐れていたのか欄のプレースホルダーを表示するか判定する。
    var shouldShowFearPlaceholder: Bool {
        fearText.isEmpty
    }

    /// どうしたかったのか欄のプレースホルダーを表示するか判定する。
    var shouldShowDesiredActionPlaceholder: Bool {
        desiredActionText.isEmpty
    }

    /// 出来事による気づき欄のプレースホルダーを表示するか判定する。
    var shouldShowInsightPlaceholder: Bool {
        insightText.isEmpty
    }

    /// 内観保存ボタンを無効にするか判定する。
    var isIntrospectionSaveDisabled: Bool {
        userId == nil
    }

    private var trimmedPersonDraftText: String {
        personDraftText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 記憶記録の内容を内観画面の入力欄へ反映する。
    func configure(modelContext: ModelContext, userId: String?, memoryEntry: MemoryEntry?) {
        self.userId = userId
        self.memoryEntryRepository = LocalMemoryEntryRepository(modelContext: modelContext)

        updateReturnButton(memoryEntry: memoryEntry)
        guard hasConfiguredMemoryEntry == false, let memoryEntry else { return }

        self.memoryEntry = memoryEntry
        titleText = memoryEntry.title
        selectedPeriod = memoryEntry.period
        personDraftText = ""
        people = memoryEntry.people
        factText = memoryEntry.factText
        emotionText = memoryEntry.emotionText
        feelingText = memoryEntry.feelingText
        bodyReactionText = memoryEntry.bodyReactionText
        thoughtText = memoryEntry.thoughtText
        desiredResponseText = memoryEntry.desiredResponseText
        fearText = memoryEntry.fearText
        desiredActionText = memoryEntry.desiredActionText
        insightText = memoryEntry.insightText
        hasConfiguredMemoryEntry = true
    }

    /// 内観を保存し、内観ステータスを内観中にする。
    func saveInProgressIntrospection() {
        saveIntrospection(status: .inProgress)
    }

    /// 内観を保存し、内観ステータスを内観済にする。
    func completeIntrospection() {
        saveIntrospection(status: .completed)
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

    /// 指定した気持ちを選択または解除する。
    func toggleFeeling(_ feeling: String) {
        var feelings = selectedFeelings
        if let index = feelings.firstIndex(of: feeling) {
            feelings.remove(at: index)
        } else {
            feelings.append(feeling)
        }
        feelingText = feelings.joined(separator: "、")
    }

    /// 指定した気持ちが選択済みか判定する。
    func isFeelingSelected(_ feeling: String) -> Bool {
        selectedFeelings.contains(feeling)
    }

    /// 選択中の気持ちをすべて解除する。
    func clearFeelings() {
        feelingText = ""
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

    /// 感情吐き出し欄以外の内観内容を保存する。
    private func saveIntrospection(status: MemoryIntrospectionStatus) {
        guard
            let userId,
            let memoryEntryRepository
        else {
            return
        }

        do {
            memoryEntry = try memoryEntryRepository.saveIntrospection(
                entry: memoryEntry,
                userId: userId,
                title: normalizedTitleText(),
                period: selectedPeriod,
                people: normalizedPeople(),
                introspectionStatus: status,
                factText: factText,
                emotionText: emotionText,
                feelingText: feelingText,
                bodyReactionText: bodyReactionText,
                thoughtText: thoughtText,
                desiredResponseText: desiredResponseText,
                fearText: fearText,
                desiredActionText: desiredActionText,
                insightText: insightText
            )
            saveResultText = status == .completed ? "内観済として保存しました" : "内観中として保存しました"
        } catch {
            saveResultText = "保存できませんでした"
        }
    }

    /// 保存用にタイトルを整える。
    private func normalizedTitleText() -> String {
        let title = titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        return title.isEmpty ? "無題の出来事" : title
    }

    /// 保存用に相手リストを整える。
    private func normalizedPeople() -> [String] {
        (people + [personDraftText])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }
}
