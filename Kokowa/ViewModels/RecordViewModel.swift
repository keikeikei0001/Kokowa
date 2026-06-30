//
//  RecordViewModel.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import Combine
import SwiftData
import SwiftUI

class RecordViewModel: ObservableObject {
    @Published var displayedMonth = Date()
    @Published var selectedDate = Date()
    @Published var monthEntries: [MentalEntry] = []
    @Published var recentWeekEntries: [MentalEntry] = []

    private var userId: String?
    private var mentalEntryRepository: MentalEntryRepository?
    private let calendar = Calendar.current
    private let dateHelper = DateHelper()

    /// カレンダーの曜日見出しを返す。
    let weekdaySymbols = ["日", "月", "火", "水", "木", "金", "土"]

    /// カレンダーの列設定を返す。
    let calendarColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    /// 選択日詳細の列設定を返す。
    let detailColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    private var selectedEntry: MentalEntry? {
        entry(for: selectedDate)
    }

    private var weekEntries: [MentalEntry] {
        recentWeekEntries
    }

    /// 今日の日付表示用テキストを返す。
    var todayText: String {
        dateHelper.todayAddWeek()
    }

    /// 表示中の年月テキストを返す。
    var displayedMonthText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: displayedMonth)
    }

    /// 選択日の見出しテキストを返す。
    var selectedDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: selectedDate)
    }

    /// 1週間のメンタル平均を返す。
    var weeklyMentalText: String {
        guard weekEntries.isEmpty == false else { return "ー" }
        let average = weekEntries.map(\.mental).reduce(0, +) / Double(weekEntries.count)
        return String(format: "%.1f", average)
    }

    /// 1週間の睡眠平均を返す。
    var weeklySleepText: String {
        guard weekEntries.isEmpty == false else { return "ー" }
        let average = weekEntries.map(\.sleepHours).reduce(0, +) / Double(weekEntries.count)
        return String(format: "%.1fh", average)
    }

    /// 1週間で一番多い体調を返す。
    var weeklyConditionText: String {
        mostFrequentText(values: weekEntries.map { $0.condition.title })
    }

    /// 1週間で一番多いストレスレベルを返す。
    var weeklyStressText: String {
        mostFrequentText(values: weekEntries.map { $0.stressLevel.title })
    }

    /// 選択日のメンタルを返す。
    var selectedMentalText: String {
        guard let selectedEntry else { return "ー" }
        return String(format: "%.1f 点", selectedEntry.mental)
    }

    /// 選択日の睡眠時間を返す。
    var selectedSleepText: String {
        guard let selectedEntry else { return "ー" }
        return String(format: "%.1fh", selectedEntry.sleepHours)
    }

    /// 選択日の体調を返す。
    var selectedConditionText: String {
        selectedEntry?.condition.title ?? "ー"
    }

    /// 選択日のストレスレベルを返す。
    var selectedStressText: String {
        selectedEntry?.stressLevel.title ?? "ー"
    }

    /// 選択日の感謝リストを返す。
    var selectedGratitudeTexts: [String] {
        selectedEntry?.gratitude
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false } ?? []
    }

    /// 選択日に表示できる感謝があるか判定する。
    var hasSelectedGratitude: Bool {
        selectedGratitudeTexts.isEmpty == false
    }

    /// 選択日のメモを返す。
    var selectedMemoText: String {
        selectedEntry?.memo.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    /// 選択日に表示できるメモがあるか判定する。
    var hasSelectedMemo: Bool {
        selectedMemoText.isEmpty == false
    }

    /// 選択日に記録があるか判定する。
    var hasSelectedEntry: Bool {
        selectedEntry != nil
    }

    /// 保存データの読み込みに必要な情報をセットする。
    func configure(modelContext: ModelContext, userId: String?) {
        self.userId = userId
        self.mentalEntryRepository = LocalMentalEntryRepository(modelContext: modelContext)
        loadMonthEntries()
        loadRecentWeekEntries()
    }

    /// 前月の記録を表示する。
    func showPreviousMonth() {
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) else { return }
        displayedMonth = previousMonth
        selectedDate = previousMonth
        loadMonthEntries()
    }

    /// 翌月の記録を表示する。
    func showNextMonth() {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else { return }
        displayedMonth = nextMonth
        selectedDate = nextMonth
        loadMonthEntries()
    }

    /// 指定日を選択する。
    func selectDate(_ date: Date) {
        selectedDate = date
    }

    /// カレンダー表示用の日付配列を返す。
    func calendarDays() -> [RecordCalendarDay] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let numberOfDays = calendar.dateComponents([.day], from: monthInterval.start, to: monthInterval.end).day
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingBlankCount = firstWeekday - 1
        let blanks = (0..<leadingBlankCount).map { _ in RecordCalendarDay(date: nil, entry: nil) }
        let days = (0..<numberOfDays).compactMap { dayOffset -> RecordCalendarDay? in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: monthInterval.start) else { return nil }
            return RecordCalendarDay(date: date, entry: entry(for: date))
        }

        return blanks + days
    }

    /// 指定日のメンタル表示用テキストを返す。
    func mentalText(for entry: MentalEntry?) -> String {
        guard let entry else { return "・" }
        return String(format: "%.1f", entry.mental)
    }

    /// 指定日が選択中か判定する。
    func isSelectedDate(_ date: Date?) -> Bool {
        guard let date else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }

    /// 指定日の日にちテキストを返す。
    func dayNumberText(_ date: Date?) -> String {
        guard let date else { return "" }
        return "\(calendar.component(.day, from: date))"
    }

    /// 表示中の月の記録を読み込む。
    private func loadMonthEntries() {
        guard
            let userId,
            let mentalEntryRepository,
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let endDate = calendar.date(byAdding: .day, value: -1, to: monthInterval.end)
        else {
            monthEntries = []
            return
        }

        do {
            monthEntries = try mentalEntryRepository.fetchEntries(
                userId: userId,
                from: monthInterval.start,
                to: endDate
            )
        } catch {
            monthEntries = []
        }
    }

    /// 直近1週間の記録を読み込む。
    private func loadRecentWeekEntries() {
        guard
            let userId,
            let mentalEntryRepository,
            let startDate = calendar.date(byAdding: .day, value: -6, to: Date())
        else {
            recentWeekEntries = []
            return
        }

        do {
            recentWeekEntries = try mentalEntryRepository.fetchEntries(
                userId: userId,
                from: startDate,
                to: Date()
            )
        } catch {
            recentWeekEntries = []
        }
    }

    /// 指定日の記録を返す。
    private func entry(for date: Date) -> MentalEntry? {
        monthEntries.first { entry in
            calendar.isDate(entry.entryDate, inSameDayAs: date)
        }
    }

    /// 最も多く出現する文字列を返す。
    private func mostFrequentText(values: [String]) -> String {
        guard values.isEmpty == false else { return "ー" }
        let groupedValues = Dictionary(grouping: values) { $0 }
        return groupedValues.max { $0.value.count < $1.value.count }?.key ?? "ー"
    }
}

struct RecordCalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
    let entry: MentalEntry?
}
