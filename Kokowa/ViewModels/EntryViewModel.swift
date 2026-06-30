//
//  EntryViewModel.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import Combine

final class EntryViewModel: ObservableObject {
    @Published var mentalScore = 5.0
    @Published var sleepHours = 9.5
    @Published var selectedCondition: EntryCondition = .good
    @Published var gratitudeText = ""
    @Published var memoText = ""
    
    private let dateHelper = DateHelper()

    var todayText: String {
        dateHelper.todayAddWeek()
    }

    var mentalScoreText: String {
        String(format: "%.1f 点", mentalScore)
    }

    var mentalScoreNumberText: String {
        String(format: "%.1f", mentalScore)
    }

    var sleepHoursText: String {
        String(format: "%.1f 時間", sleepHours)
    }

    var sleepHoursShortText: String {
        String(format: "%.1fh", sleepHours)
    }

    func selectCondition(_ condition: EntryCondition) {
        selectedCondition = condition
    }

    func handleSaveTap() {
        // データ保存方法は後で決めるため、今は何もしない。
    }
}
