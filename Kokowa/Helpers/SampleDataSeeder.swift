//
//  SampleDataSeeder.swift
//  Kokowa
//
//  Created by Codex on 2026/07/01.
//

import Foundation
import SwiftData

enum SampleDataSeeder {
    private static let sampleMentalCount = 30
    private static let sampleMemoryCount = 30

    /// カレンダーと記憶見返しの確認用サンプルデータを不足分だけ作成する。
    static func seedIfNeeded(modelContext: ModelContext, userId: String?) {
        guard let userId else { return }

        do {
            try seedMentalEntriesIfNeeded(modelContext: modelContext, userId: userId)
            try seedMemoryEntriesIfNeeded(modelContext: modelContext, userId: userId)
            try modelContext.save()
        } catch {
            return
        }
    }

    /// 直近30日分のメンタル記録を作成する。
    private static func seedMentalEntriesIfNeeded(modelContext: ModelContext, userId: String) throws {
        let calendar = Calendar.current
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: Date()),
            let sampleEndDate = calendar.date(byAdding: .day, value: sampleMentalCount - 1, to: monthInterval.start)
        else {
            return
        }
        let startOfDay = calendar.startOfDay(for: monthInterval.start)
        let endOfDay = DateHelper().getStartAndEndOfDay(date: sampleEndDate).1

        let descriptor = FetchDescriptor<MentalEntry>(
            predicate: #Predicate { entry in
                entry.userId == userId && entry.entryDate >= startOfDay && entry.entryDate <= endOfDay
            }
        )
        let existingEntries = try modelContext.fetch(descriptor)

        for dayOffset in 0..<sampleMentalCount {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfDay) else { continue }
            let alreadyExists = existingEntries.contains { entry in
                calendar.isDate(entry.entryDate, inSameDayAs: date)
            }
            guard alreadyExists == false else { continue }

            let entry = sampleMentalEntry(userId: userId, date: date, index: dayOffset)
            modelContext.insert(entry)
        }
    }

    /// 見返し確認用の記憶記録を30件まで作成する。
    private static func seedMemoryEntriesIfNeeded(modelContext: ModelContext, userId: String) throws {
        let descriptor = FetchDescriptor<MemoryEntry>(
            predicate: #Predicate { entry in
                entry.userId == userId
            }
        )
        let existingEntries = try modelContext.fetch(descriptor)
        let missingCount = max(sampleMemoryCount - existingEntries.count, 0)
        guard missingCount > 0 else { return }

        let startIndex = existingEntries.count
        for offset in 0..<missingCount {
            let entry = sampleMemoryEntry(userId: userId, index: startIndex + offset)
            modelContext.insert(entry)
        }
    }

    /// 指定日のサンプルメンタル記録を作成する。
    private static func sampleMentalEntry(userId: String, date: Date, index: Int) -> MentalEntry {
        let mentalValues = [4.5, 5.0, 6.5, 7.5, 8.5, 6.0, 5.5, 7.0, 6.5, 8.0]
        let sleepValues = [6.0, 7.5, 8.0, 5.5, 9.0, 6.5, 7.0, 8.5, 6.0, 7.5]
        let conditions: [EntryCondition] = [.good, .slightlyBad, .excellent, .good, .bad]
        let stressLevels: [StressLevel] = [.normal, .high, .low, .normal, .veryHigh]
        let gratitudeSamples = [
            ["温かいご飯を食べられた", "少し眠れた", "空がきれいだった"],
            ["友達が返事をくれた", "散歩できた"],
            ["好きな音楽を聴けた", "予定をひとつ終えた"],
            ["ゆっくりお茶を飲めた"],
            ["自分の気持ちを書けた", "早めに休めた"]
        ]

        return MentalEntry(
            userId: userId,
            entryDate: date,
            mental: mentalValues[index % mentalValues.count],
            sleepHours: sleepValues[index % sleepValues.count],
            condition: conditions[index % conditions.count],
            stressLevel: stressLevels[index % stressLevels.count],
            gratitude: gratitudeSamples[index % gratitudeSamples.count],
            memo: "サンプルメモ \(index + 1)。今日感じたことを短く残しています。",
            createdAt: date,
            updatedAt: date
        )
    }

    /// 指定番号のサンプル記憶記録を作成する。
    private static func sampleMemoryEntry(userId: String, index: Int) -> MemoryEntry {
        let titles = [
            "母子手帳事件",
            "先生に強く注意された",
            "友達の一言が残った",
            "部活で責められた",
            "家族と比べられた",
            "職場で言い返せなかった",
            "約束を忘れられた",
            "発表で笑われた",
            "頼みごとを断れなかった",
            "大切にされていないと感じた"
        ]
        let periods: [MemoryPeriod] = [
            .preschool,
            .elementary,
            .juniorHigh,
            .highSchool,
            .universitySpecialized,
            .lateTeen,
            .early20s,
            .late20s,
            .early30s,
            .late30s
        ]
        let people = [
            ["母親"],
            ["先生"],
            ["友達", "同級生"],
            ["部活の先輩"],
            ["家族"],
            ["上司", "同僚"],
            ["恋人"],
            ["クラスメイト"],
            ["知人"],
            ["父親", "母親"]
        ]
        let statuses: [MemoryIntrospectionStatus] = [.notStarted, .inProgress, .completed]
        let createdAt = Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date()

        return MemoryEntry(
            userId: userId,
            title: titles[index % titles.count],
            period: periods[index % periods.count],
            introspectionStatus: statuses[index % statuses.count],
            people: people[index % people.count],
            createdAt: createdAt,
            updatedAt: createdAt
        )
    }
}
