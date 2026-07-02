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

struct EarlyMaladaptiveSchemaItem: Identifiable {
    let id: String
    let title: String
    let description: String
}

struct EarlyMaladaptiveSchemaCategory: Identifiable {
    let title: String
    let description: String
    let schemas: [EarlyMaladaptiveSchemaItem]

    var id: String { title }
}

final class IntrospectionViewModel: ObservableObject {
    @Published var titleText = ""
    @Published var selectedPeriod: MemoryPeriod = .elementary
    @Published var personDraftText = ""
    @Published var people: [String] = []
    @Published var emotionReleaseText = ""
    @Published var selectedSchemaIds: [String] = []
    @Published var factText = ""
    @Published var actionText = ""
    @Published var emotionText = ""
    @Published var bodyReactionText = ""
    @Published var thoughtText = ""
    @Published var futureActionText = ""
    @Published var insightText = ""
    @Published var isKeyboardVisible = false
    @Published var returnButtonTitle = "ホームに戻る"
    @Published var returnButtonIconName = "house.fill"
    @Published var saveResultText = ""
    @Published var alert: AlertContext?

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

    /// 行動欄のプレースホルダーを表示するか判定する。
    var shouldShowActionPlaceholder: Bool {
        actionText.isEmpty
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

    /// 早期不適応スキーマの選択肢をカテゴリごとに返す。
    var earlyMaladaptiveSchemaCategories: [EarlyMaladaptiveSchemaCategory] {
        [
            EarlyMaladaptiveSchemaCategory(
                title: "第1領域: 人との関わりが断絶されること",
                description: "「愛してもらいたい」「守ってもらいたい」「理解してもらいたい」という中核的感情欲求が満たされなかった時に生まれやすい領域です。",
                schemas: [
                    EarlyMaladaptiveSchemaItem(
                        id: "abandonment",
                        title: "見捨てられスキーマ",
                        description: "人は自分を見捨てていく、自分はいつも見捨てられると感じやすい心のパターンです。相手がそばにいても、いつか去っていくと強く信じやすくなります。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "mistrust_abuse",
                        title: "不信・虐待スキーマ",
                        description: "人は自分を攻撃する、奪う、だますかもしれないと警戒しやすい心のパターンです。親切にされても裏があるのではないかと疑いやすくなります。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "emotional_deprivation",
                        title: "「愛されない」「わかってもらえない」スキーマ",
                        description: "自分は愛されない、理解されない、守られないと感じやすい心のパターンです。愛されたい、わかってほしいという願いが強く出ることもあります。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "defectiveness_shame",
                        title: "欠陥・恥スキーマ",
                        description: "自分は根本的にダメな人間で、そんな自分は恥ずかしい存在だと感じやすい心のパターンです。欠陥が人に知られないように振る舞いやすくなります。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "social_isolation",
                        title: "孤立スキーマ",
                        description: "自分は変わり者で、世界から孤立していて、誰とも交われないと感じやすい心のパターンです。本当は居場所を求めている場合もあります。"
                    )
                ]
            ),
            EarlyMaladaptiveSchemaCategory(
                title: "第2領域: 「できない自分」にしかなれないこと",
                description: "「有能な人間になりたい」「いろんなことがうまくできるようになりたい」という中核的感情欲求が満たされなかった時に生まれやすい領域です。",
                schemas: [
                    EarlyMaladaptiveSchemaItem(
                        id: "dependence_incompetence",
                        title: "無能・依存スキーマ",
                        description: "自分はできない人間で、自分ひとりではまともにできないと感じやすい心のパターンです。新しい課題に尻込みしたり、人の助けを求めやすくなります。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "vulnerability",
                        title: "「世の中は何があるかわからないし、自分は簡単にやられてしまう」スキーマ",
                        description: "自分の身に恐ろしいことが起きるかもしれず、起きたら自分では対処できないと感じやすい心のパターンです。身体の異変や周囲の変化に敏感になりやすくなります。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "enmeshment",
                        title: "巻き込まれスキーマ",
                        description: "自分は誰かに巻き込まれていて、自分というものがないと感じやすい心のパターンです。相手の考えや感情を、自分のもののように感じることがあります。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "failure",
                        title: "失敗スキーマ",
                        description: "自分は何をやっても失敗する、これからも失敗ばかりするだろうと感じやすい心のパターンです。挑戦を避けたり、課題を先延ばしにしやすくなります。"
                    )
                ]
            ),
            EarlyMaladaptiveSchemaCategory(
                title: "第3領域: 他者を優先し、自分を抑えること",
                description: "「自分の感情や思いを自由に表現したい」「自分の意志を大切にしたい」という中核的感情欲求が満たされなかった時に生まれやすい領域です。",
                schemas: [
                    EarlyMaladaptiveSchemaItem(
                        id: "subjugation",
                        title: "服従スキーマ",
                        description: "嫌われたくない、見捨てられたくない、攻撃されたくないという思いから、相手に従いやすくなる心のパターンです。自分の感情や欲求を置き去りにしやすくなります。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "self_sacrifice",
                        title: "自己犠牲スキーマ",
                        description: "自分より相手を優先するのは当然だと感じやすい心のパターンです。相手のつらさを減らすために、自分が何とかしなければならないと感じやすくなります。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "approval_seeking",
                        title: "「ほめられたい」「評価されたい」スキーマ",
                        description: "他人の評価がすべてで、認められたい、ほめられたいという思いが強くなりやすい心のパターンです。自分の好みや意志より、評価されるかどうかで行動を選びやすくなります。"
                    )
                ]
            ),
            EarlyMaladaptiveSchemaCategory(
                title: "第4領域: 物事を悲観し、自分や他人を追い詰めること",
                description: "「自由にのびのびと動きたい」「楽しく遊びたい」「生き生きと楽しみたい」という中核的感情欲求が満たされなかった時に生まれやすい領域です。",
                schemas: [
                    EarlyMaladaptiveSchemaItem(
                        id: "negativity_pessimism",
                        title: "否定・悲観スキーマ",
                        description: "人生や物事の否定的な面ばかりを見て、悲観しやすい心のパターンです。常に悪い方向を考え、心配や警戒が強くなりやすいです。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "emotional_inhibition",
                        title: "感情抑制スキーマ",
                        description: "怒り、楽しさ、悲しみなどの感情を感じたり外に出したりしてはならないと抑えやすい心のパターンです。感情がないかのように淡々と振る舞うことがあります。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "unrelenting_standards",
                        title: "完璧主義「べき」スキーマ",
                        description: "物事は完璧にこなさなければならない、休まず達成しなければならないと自分を追い詰めやすい心のパターンです。自分にも他人にも高い基準を向けることがあります。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "punitiveness",
                        title: "「できなければ罰されるべき」スキーマ",
                        description: "うまくできなかった人は罰されるべきだと感じ、自分や他人を許しにくくなる心のパターンです。失敗した自分を強く責めやすくなります。"
                    )
                ]
            ),
            EarlyMaladaptiveSchemaCategory(
                title: "第5領域: 自分勝手になりすぎること",
                description: "「自律性のある人間になりたい」「ある程度自分をコントロールできるようになりたい」という中核的感情欲求が満たされなかった時に生まれやすい領域です。",
                schemas: [
                    EarlyMaladaptiveSchemaItem(
                        id: "entitlement",
                        title: "「オレ様・女王様」スキーマ",
                        description: "自分は他人と違う特別な存在で、特別扱いされるべきだと感じやすい心のパターンです。自分のやりたいようにするために、相手を利用してもよいと感じることがあります。"
                    ),
                    EarlyMaladaptiveSchemaItem(
                        id: "insufficient_self_control",
                        title: "「自分をコントロールできない」スキーマ",
                        description: "楽しいことや欲しいものを今すぐ求め、我慢や計画を後回しにしやすい心のパターンです。やるべきことより、やりたいことを優先しやすくなります。"
                    )
                ]
            )
        ]
    }

    /// 選択済みのスキーマをカテゴリ順で返す。
    var selectedSchemaItems: [EarlyMaladaptiveSchemaItem] {
        earlyMaladaptiveSchemaCategories
            .flatMap(\.schemas)
            .filter { selectedSchemaIds.contains($0.id) }
    }

    /// 身体反応欄のプレースホルダーを表示するか判定する。
    var shouldShowBodyReactionPlaceholder: Bool {
        bodyReactionText.isEmpty
    }

    /// 思考欄のプレースホルダーを表示するか判定する。
    var shouldShowThoughtPlaceholder: Bool {
        thoughtText.isEmpty
    }

    /// これからどうしたいのか欄のプレースホルダーを表示するか判定する。
    var shouldShowFutureActionPlaceholder: Bool {
        futureActionText.isEmpty
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
        selectedSchemaIds = memoryEntry.schemaIds
        factText = memoryEntry.factText
        actionText = memoryEntry.actionText
        emotionText = memoryEntry.emotionText
        bodyReactionText = memoryEntry.bodyReactionText
        thoughtText = memoryEntry.thoughtText
        futureActionText = memoryEntry.futureActionText
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

    /// 内観完了の確認アラートを表示する。
    func showCompleteConfirmation() {
        alert = AlertContext(
            title: "内観を完了しますか？",
            message: "入力内容を保存し、内観ステータスを内観済にします。",
            actions: [
                AlertContext.Action(title: "キャンセル", role: .cancel) { [weak self] _ in
                    self?.alert = nil
                },
                AlertContext.Action(title: "完了する", role: nil) { [weak self] _ in
                    self?.completeIntrospection()
                    self?.alert = nil
                }
            ]
        )
    }

    /// 出来事カードの入力内容を画面上だけリセットする。
    func resetEventCard() {
        titleText = ""
        selectedPeriod = .elementary
        personDraftText = ""
        people = []
    }

    /// 出来事を分解するカードの入力内容を画面上だけリセットする。
    func resetDecompositionCard() {
        factText = ""
        actionText = ""
        bodyReactionText = ""
        emotionText = ""
        thoughtText = ""
    }

    /// 感情を吐き出すカードの入力内容を画面上だけリセットする。
    func resetEmotionReleaseCard() {
        emotionReleaseText = ""
    }

    /// スキーマカードの選択内容を画面上だけリセットする。
    func resetSchemaCard() {
        selectedSchemaIds = []
    }

    /// 心の声カードの入力内容を画面上だけリセットする。
    func resetInnerVoiceCard() {
        futureActionText = ""
    }

    /// 気づきカードの入力内容を画面上だけリセットする。
    func resetInsightCard() {
        insightText = ""
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

    /// 指定したスキーマを選択または解除する。
    func toggleSchema(_ schema: EarlyMaladaptiveSchemaItem) {
        if let index = selectedSchemaIds.firstIndex(of: schema.id) {
            selectedSchemaIds.remove(at: index)
        } else {
            selectedSchemaIds.append(schema.id)
        }
    }

    /// 指定したスキーマが選択済みか判定する。
    func isSchemaSelected(_ schema: EarlyMaladaptiveSchemaItem) -> Bool {
        selectedSchemaIds.contains(schema.id)
    }

    /// 選択中のスキーマをすべて解除する。
    func clearSchemas() {
        selectedSchemaIds = []
    }

    /// 出来事削除の確認アラートを表示する。
    func showDeleteConfirmation(onDelete: @escaping () -> Void) {
        alert = AlertContext(
            title: "この出来事を削除しますか？",
            message: "この出来事に保存されている情報をすべて削除します。この操作は取り消せません。",
            actions: [
                AlertContext.Action(title: "キャンセル", role: .cancel) { [weak self] _ in
                    self?.alert = nil
                },
                AlertContext.Action(title: "削除", role: .destructive) { [weak self] _ in
                    if self?.deleteCurrentEntry() == true {
                        self?.alert = nil
                        onDelete()
                    }
                }
            ]
        )
    }

    /// カード内の入力内容を画面上だけ消す確認アラートを表示する。
    func showResetConfirmation(title: String, onReset: @escaping () -> Void) {
        alert = AlertContext(
            title: "入力内容をリセットしますか？",
            message: "\(title)の内容を画面上だけ消します。保存済みデータは、保存ボタンを押すまで変更されません。",
            actions: [
                AlertContext.Action(title: "キャンセル", role: .cancel) { [weak self] _ in
                    self?.alert = nil
                },
                AlertContext.Action(title: "リセット", role: .destructive) { [weak self] _ in
                    onReset()
                    self?.alert = nil
                }
            ]
        )
    }

    /// 不適応スキーマの説明アラートを表示する。
    func showSchemaInfoAlert() {
        alert = AlertContext(
            title: "スキーマとは？",
            message: "幼少期の経験などから作られた、自分、他人、世界に対する深い信念、価値観、イメージです。出来事に対して湧いてくる思考には、このスキーマが影響しています。\n\n例えば、メッセージがなかなか返ってこないという出来事があったとします。その出来事を「自分は見捨てられる人間なんだ」というスキーマを持つAさんと「自分は愛される人間なんだ」というスキーマを持つBさんの両方が経験したとします。この場合、Aさんはその出来事に対して「自分は嫌われたのかもしれない」と考え、Bさんは「相手は今忙しいんだな」と考えるかもしれません。このようにスキーマは、自分の思考に大きく影響を及ぼします。\n\nスキーマ療法では18種類の代表的な生きづらさにつながるスキーマが提唱されています。それらのスキーマは、早期不適応スキーマと呼ばれています。",
            actions: [
                AlertContext.Action(title: "OK", role: nil) { [weak self] _ in
                    self?.alert = nil
                }
            ]
        )
    }

    /// スキーマ選択完了後の注意アラートを表示する。
    func showSchemaSelectionCompletedAlert() {
        alert = AlertContext(
            title: "選んだスキーマについて",
            message: "選んだスキーマは「あなた自身」を表すものではありません。\n今回の出来事で反応した可能性がある心のパターンです。",
            actions: [
                AlertContext.Action(title: "OK", role: nil) { [weak self] _ in
                    self?.alert = nil
                }
            ]
        )
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

    /// 現在の出来事を保存データから削除する。
    private func deleteCurrentEntry() -> Bool {
        guard let memoryEntry, let memoryEntryRepository else {
            resetAllInput()
            return true
        }

        do {
            try memoryEntryRepository.deleteEntry(memoryEntry)
            resetAllInput()
            return true
        } catch {
            saveResultText = "削除できませんでした"
            return false
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
                schemaIds: selectedSchemaIds,
                factText: factText,
                actionText: actionText,
                emotionText: emotionText,
                bodyReactionText: bodyReactionText,
                thoughtText: thoughtText,
                futureActionText: futureActionText,
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

    /// 画面上のすべての入力内容を空にする。
    private func resetAllInput() {
        resetEventCard()
        resetDecompositionCard()
        resetEmotionReleaseCard()
        resetSchemaCard()
        resetInnerVoiceCard()
        resetInsightCard()
        saveResultText = ""
    }
}
