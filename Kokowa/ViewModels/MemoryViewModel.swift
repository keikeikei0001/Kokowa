//
//  MemoryViewModel.swift
//  Kokowa
//
//  Created by Codex on 2026/07/01.
//

import Foundation
import Combine
import SwiftData
import SwiftUI

final class MemoryViewModel: ObservableObject {
    @Published var titleText = ""
    @Published var selectedPeriod: MemoryPeriod = .elementary
    @Published var personDraftText = ""
    @Published var people: [String] = []
    @Published var entries: [MemoryEntry] = []
    @Published var selectedPeriodFilter: MemoryPeriod?
    @Published var personSearchText = ""
    @Published var selectedIntrospectionStatusFilter: MemoryIntrospectionStatus?
    @Published var isKeyboardVisible = false
    @Published var alert: AlertContext?

    private let dateHelper = DateHelper()
    private var userId: String?
    private var memoryEntryRepository: MemoryEntryRepository?

    /// 今日の日付表示用テキストを返す。
    var todayText: String {
        dateHelper.todayAddWeek()
    }

    /// 時期の選択肢を返す。
    var periodOptions: [MemoryPeriod] {
        MemoryPeriod.allCases
    }

    /// 表示中の記憶記録の件数を返す。
    var entryCountText: String {
        "\(filteredEntries.count)件"
    }

    /// 追加ボタンを無効にするか判定する。
    var isAddButtonDisabled: Bool {
        trimmedTitleText.isEmpty
    }

    /// 追加ボタンの背景色を返す。
    var addButtonColor: Color {
        isAddButtonDisabled ? .secondaryTextGray.opacity(0.24) : .kokowaTeal
    }

    /// 相手追加ボタンを無効にするか判定する。
    var isAddPersonButtonDisabled: Bool {
        trimmedPersonDraftText.isEmpty
    }

    /// 絞り込み後の記憶記録を返す。
    var filteredEntries: [MemoryEntry] {
        entries.filter { entry in
            let matchesPeriod = selectedPeriodFilter.map { entry.period == $0 } ?? true
            let matchesPerson = trimmedPersonSearchText.isEmpty || entry.people.contains { person in
                person.localizedCaseInsensitiveContains(trimmedPersonSearchText)
            }
            let matchesStatus = selectedIntrospectionStatusFilter.map { entry.introspectionStatus == $0 } ?? true
            return matchesPeriod && matchesPerson && matchesStatus
        }
    }

    /// 内観ステータスの選択肢を返す。
    var introspectionStatusOptions: [MemoryIntrospectionStatus] {
        MemoryIntrospectionStatus.allCases
    }

    /// 時期フィルターの表示テキストを返す。
    var selectedPeriodFilterText: String {
        selectedPeriodFilter?.title ?? "すべて"
    }

    /// 内観フィルターの表示テキストを返す。
    var selectedIntrospectionStatusFilterText: String {
        selectedIntrospectionStatusFilter?.title ?? "すべて"
    }

    private var trimmedTitleText: String {
        titleText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedPersonDraftText: String {
        personDraftText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedPersonSearchText: String {
        personSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 保存データの読み込みに必要な情報をセットする。
    func configure(modelContext: ModelContext, userId: String?) {
        self.userId = userId
        self.memoryEntryRepository = LocalMemoryEntryRepository(modelContext: modelContext)
        loadEntries()
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

    /// 記憶記録を保存する。
    func addEntry() {
        guard
            isAddButtonDisabled == false,
            let userId,
            let memoryEntryRepository
        else {
            return
        }

        do {
            try memoryEntryRepository.saveEntry(
                userId: userId,
                title: trimmedTitleText,
                period: selectedPeriod,
                introspectionStatus: .notStarted,
                people: normalizedPeople()
            )
            resetInput()
            loadEntries()
        } catch {
            return
        }
    }

    /// 記憶記録を追加する前の確認アラートを表示する。
    func showAddEntryConfirmation() {
        guard isAddButtonDisabled == false else { return }

        alert = AlertContext(
            title: "出来事を追加しますか？",
            message: "入力した内容を記憶として保存します。保存後の内観ステータスは未内観になります。",
            actions: [
                AlertContext.Action(title: "キャンセル", role: .cancel) { [weak self] _ in
                    self?.alert = nil
                },
                AlertContext.Action(title: "追加", role: nil) { [weak self] _ in
                    self?.addEntry()
                    self?.alert = nil
                }
            ]
        )
    }

    /// 内観ステータスフィルターを切り替える。
    func selectIntrospectionStatusFilter(_ status: MemoryIntrospectionStatus?) {
        selectedIntrospectionStatusFilter = status
    }

    /// 記憶記録の相手表示テキストを返す。
    func peopleTags(_ entry: MemoryEntry) -> [String] {
        entry.people.isEmpty ? ["相手なし"] : entry.people
    }

    /// 記憶記録を読み込む。
    private func loadEntries() {
        guard let userId, let memoryEntryRepository else {
            entries = []
            return
        }

        do {
            entries = try memoryEntryRepository.fetchEntries(userId: userId)
        } catch {
            entries = []
        }
    }

    /// 入力中の内容を空に戻す。
    private func resetInput() {
        titleText = ""
        personDraftText = ""
        people = []
        selectedPeriod = .elementary
    }

    /// 保存用に相手リストを整える。
    private func normalizedPeople() -> [String] {
        (people + [personDraftText])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }
}
