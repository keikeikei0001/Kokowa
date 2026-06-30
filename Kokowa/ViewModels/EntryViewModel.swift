//
//  EntryViewModel.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import Combine
import SwiftUI
import SwiftData

final class EntryViewModel: ObservableObject {
    @Published var mentalScore = 5.0
    @Published var sleepHours = 9.5
    @Published var selectedCondition: EntryCondition = .good
    @Published var selectedStressLevel: StressLevel = .normal
    @Published var gratitudeDraftText = ""
    @Published var gratitudeTexts: [String] = []
    @Published var memoText = ""
    @Published var isTodayEntrySaved = false
    @Published var isKeyboardVisible = false
    
    private let dateHelper = DateHelper()
    private var userId: String?
    private var mentalEntryRepository: MentalEntryRepository?
    private var characterRepository: CharacterRepository?
    private var userProfileRepository: UserProfileRepository?

    private let saveExperiencePoint = 5
    private let maxGratitudeCount = 10

    /// 今日の日付表示用テキストを返す。
    var todayText: String {
        dateHelper.todayAddWeek()
    }

    /// メンタル点数を単位付きで返す。
    var mentalScoreText: String {
        String(format: "%.1f 点", mentalScore)
    }

    /// 概要カード用のメンタル点数を返す。
    var mentalScoreNumberText: String {
        String(format: "%.1f", mentalScore)
    }

    /// 睡眠時間を単位付きで返す。
    var sleepHoursText: String {
        String(format: "%.1f 時間", sleepHours)
    }

    /// 概要カード用の短い睡眠時間を返す。
    var sleepHoursShortText: String {
        String(format: "%.1fh", sleepHours)
    }

    /// 保存ボタンに表示する文言を返す。
    var saveButtonTitle: String {
        isTodayEntrySaved ? "変更" : "保存"
    }

    /// メモ欄のプレースホルダーを表示するか判定する。
    var shouldShowMemoPlaceholder: Bool {
        memoText.isEmpty
    }

    /// 感謝の新規入力欄を表示するか判定する。
    var shouldShowGratitudeDraftField: Bool {
        gratitudeTexts.count < maxGratitudeCount
    }

    /// 感謝の入力済み件数を返す。
    var gratitudeCountText: String {
        "\(gratitudeValues().count) / \(maxGratitudeCount)"
    }

    /// スコアバーの表示進捗を返す。
    func scoreProgress(value: Double, range: ClosedRange<Double>) -> CGFloat {
        let clampedValue = min(max(value, range.lowerBound), range.upperBound)
        let fullRange = range.upperBound - range.lowerBound
        guard fullRange > 0 else { return 0 }
        return CGFloat((clampedValue - range.lowerBound) / fullRange)
    }

    /// バー上の位置からステップに合わせたスコア値を返す。
    func scoreValue(locationX: CGFloat, trackWidth: CGFloat, range: ClosedRange<Double>, step: Double) -> Double {
        guard trackWidth > 0 else { return range.lowerBound }

        let progress = min(max(Double(locationX / trackWidth), 0), 1)
        let rawValue = range.lowerBound + ((range.upperBound - range.lowerBound) * progress)
        let steppedValue = (rawValue / step).rounded() * step
        return min(max(steppedValue, range.lowerBound), range.upperBound)
    }

    /// 指定した体調が選択中か判定する。
    func isSelectedCondition(_ condition: EntryCondition) -> Bool {
        selectedCondition == condition
    }

    /// 体調選択ボタンの文字色を返す。
    func conditionButtonForegroundColor(for condition: EntryCondition) -> Color {
        isSelectedCondition(condition) ? .white : .primaryTextBlack
    }

    /// 体調選択ボタンの背景色を返す。
    func conditionButtonBackgroundColor(for condition: EntryCondition) -> Color {
        isSelectedCondition(condition) ? .kokowaTeal : Color.white.opacity(0.56)
    }

    /// 指定したストレスレベルが選択中か判定する。
    func isSelectedStressLevel(_ stressLevel: StressLevel) -> Bool {
        selectedStressLevel == stressLevel
    }

    /// ストレスレベル選択ボタンの文字色を返す。
    func stressLevelButtonForegroundColor(for stressLevel: StressLevel) -> Color {
        isSelectedStressLevel(stressLevel) ? .white : .primaryTextBlack
    }

    /// ストレスレベル選択ボタンの背景色を返す。
    func stressLevelButtonBackgroundColor(for stressLevel: StressLevel) -> Color {
        isSelectedStressLevel(stressLevel) ? .kokowaRose : Color.white.opacity(0.56)
    }

    /// 保存に必要なリポジトリをセットする。
    func configure(modelContext: ModelContext, userId: String?) {
        self.userId = userId
        let userProfileRepository = LocalUserProfileRepository(modelContext: modelContext)
        self.userProfileRepository = userProfileRepository
        self.mentalEntryRepository = LocalMentalEntryRepository(modelContext: modelContext)
        self.characterRepository = LocalCharacterRepository(
            modelContext: modelContext,
            userProfileRepository: userProfileRepository
        )
        loadTodayEntry()
    }

    /// 選択中の体調を更新する。
    func selectCondition(_ condition: EntryCondition) {
        selectedCondition = condition
    }

    /// 選択中のストレスレベルを更新する。
    func selectStressLevel(_ stressLevel: StressLevel) {
        selectedStressLevel = stressLevel
    }

    /// 新しく入力した感謝を入力済みリストの先頭へ移す。
    func commitGratitudeDraftIfNeeded() {
        let trimmedText = gratitudeDraftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText.isEmpty == false, gratitudeTexts.count < maxGratitudeCount else { return }

        gratitudeTexts.insert(trimmedText, at: 0)
        gratitudeDraftText = ""
    }

    /// 指定した位置の感謝テキストを更新する。
    func updateGratitudeText(at index: Int, text: String) {
        guard gratitudeTexts.indices.contains(index) else { return }
        gratitudeTexts[index] = text
    }

    /// 入力内容の保存処理を実行する。
    func handleSaveTap() {
        guard
            let userId,
            let mentalEntryRepository,
            let characterRepository,
            let userProfileRepository
        else {
            return
        }

        do {
            let result = try mentalEntryRepository.saveEntry(
                userId: userId,
                date: Date(),
                mental: mentalScore,
                sleepHours: sleepHours,
                condition: selectedCondition,
                stressLevel: selectedStressLevel,
                gratitude: gratitudeValues(),
                memo: memoText
            )

            if result.isFirstSaveOfDay, let activeCharacter = try characterRepository.fetchActiveCharacter(userId: userId) {
                try characterRepository.addExperience(to: activeCharacter, amount: saveExperiencePoint)
            }

            let activeCharacterId = try userProfileRepository.fetchUserProfile(userId: userId)?.activeCharacterId
            try userProfileRepository.saveUserProfile(
                userId: userId,
                activeCharacterId: activeCharacterId,
                todayMental: mentalScore
            )
            isTodayEntrySaved = true
        } catch {
            return
        }
    }

    /// 今日の記録があれば入力画面へ反映する。
    private func loadTodayEntry() {
        guard let userId, let mentalEntryRepository else { return }

        do {
            guard let entry = try mentalEntryRepository.fetchEntry(userId: userId, date: Date()) else {
                isTodayEntrySaved = false
                return
            }

            mentalScore = entry.mental
            sleepHours = entry.sleepHours
            selectedCondition = entry.condition
            selectedStressLevel = entry.stressLevel
            gratitudeDraftText = ""
            gratitudeTexts = Array(entry.gratitude.prefix(maxGratitudeCount))
            memoText = entry.memo
            isTodayEntrySaved = true
        } catch {
            isTodayEntrySaved = false
        }
    }

    /// 空欄を除いた感謝リストを返す。
    private func gratitudeValues() -> [String] {
        let draftValues = [gratitudeDraftText]
        return (draftValues + gratitudeTexts)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .prefix(maxGratitudeCount)
            .map { $0 }
    }
}
