//
//  MentalEntryRepository.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import SwiftData

protocol MentalEntryRepository {
    /// 指定日のメンタル記録を取得する。
    func fetchEntry(userId: String, date: Date) throws -> MentalEntry?

    /// 指定期間のメンタル記録を取得する。
    func fetchEntries(userId: String, from startDate: Date, to endDate: Date) throws -> [MentalEntry]

    /// メンタル記録を新規保存または更新する。
    func saveEntry(
        userId: String,
        date: Date,
        mental: Double,
        sleepHours: Double,
        condition: EntryCondition,
        stressLevel: StressLevel,
        gratitude: [String],
        memo: String
    ) throws -> (entry: MentalEntry, isFirstSaveOfDay: Bool)
}

final class LocalMentalEntryRepository: MentalEntryRepository {
    private let modelContext: ModelContext
    private let dateHelper = DateHelper()

    /// SwiftDataのModelContextで初期化する。
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 指定日のメンタル記録を取得する。
    func fetchEntry(userId: String, date: Date) throws -> MentalEntry? {
        let dayRange = dateHelper.getStartAndEndOfDay(date: date)
        let startOfDay = dayRange.0
        let endOfDay = dayRange.1

        var descriptor = FetchDescriptor<MentalEntry>(
            predicate: #Predicate { entry in
                entry.userId == userId && entry.entryDate >= startOfDay && entry.entryDate <= endOfDay
            },
            sortBy: [SortDescriptor(\.entryDate, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    /// 指定期間のメンタル記録を取得する。
    func fetchEntries(userId: String, from startDate: Date, to endDate: Date) throws -> [MentalEntry] {
        let startOfDay = Calendar.current.startOfDay(for: startDate)
        let endOfDay = dateHelper.getStartAndEndOfDay(date: endDate).1

        let descriptor = FetchDescriptor<MentalEntry>(
            predicate: #Predicate { entry in
                entry.userId == userId && entry.entryDate >= startOfDay && entry.entryDate <= endOfDay
            },
            sortBy: [SortDescriptor(\.entryDate)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// メンタル記録を新規保存または更新する。
    func saveEntry(
        userId: String,
        date: Date,
        mental: Double,
        sleepHours: Double,
        condition: EntryCondition,
        stressLevel: StressLevel,
        gratitude: [String],
        memo: String
    ) throws -> (entry: MentalEntry, isFirstSaveOfDay: Bool) {
        if let entry = try fetchEntry(userId: userId, date: date) {
            entry.mental = mental
            entry.sleepHours = sleepHours
            entry.conditionRawValue = condition.rawValue
            entry.stressLevelRawValue = stressLevel.rawValue
            entry.gratitude = gratitude
            entry.memo = memo
            entry.updatedAt = Date()
            try modelContext.save()
            return (entry, false)
        }

        let entry = MentalEntry(
            userId: userId,
            entryDate: date,
            mental: mental,
            sleepHours: sleepHours,
            condition: condition,
            stressLevel: stressLevel,
            gratitude: gratitude,
            memo: memo
        )
        modelContext.insert(entry)
        try modelContext.save()
        return (entry, true)
    }
}
