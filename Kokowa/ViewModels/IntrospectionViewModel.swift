//
//  IntrospectionViewModel.swift
//  Kokowa
//
//  Created by Codex on 2026/07/01.
//

import Foundation
import SwiftUI
import Combine

final class IntrospectionViewModel: ObservableObject {
    @Published var titleText = ""
    @Published var selectedPeriod: MemoryPeriod = .elementary
    @Published var personDraftText = ""
    @Published var people: [String] = []
    @Published var isKeyboardVisible = false

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

    private var trimmedPersonDraftText: String {
        personDraftText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 記憶記録の内容を内観画面の入力欄へ反映する。
    func configure(memoryEntry: MemoryEntry?) {
        guard hasConfiguredMemoryEntry == false, let memoryEntry else { return }

        titleText = memoryEntry.title
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
}
