//
//  DateHelper.swift
//  LifeIsRpg
//
//  Created by けいけい on 2025/01/03.
//

import SwiftUI

class DateHelper {
    /// 2つの日時の日付単位の差を出す
    func calculateDaysBetween(_ startDate: Date, _ endDate: Date) -> Int? {
        let calendar = Calendar.current
        
        // 時間を切り捨てて日付のみにする
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.startOfDay(for: endDate)
        
        // 日数の差を取得
        let components = calendar.dateComponents([.day], from: startOfDay, to: endOfDay)
        return components.day
    }
    
    /// 日時をyyyy年M月d日にフォーマット
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }
    
    /// 日時をH:mmにフォーマット
    func formattedTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm"
        return formatter.string(from: date)
    }
    
    /// その日の始まりと終わりを取得
    func getStartAndEndOfDay(date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = startOfDay.addingTimeInterval((60 * 60 * 24) - 0.0001)
        return (startOfDay, endOfDay)
    }
    
    /// 日付を文字列にdに変換
    func formatDayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    /// カレンダー月をyyyy年 M月に変換
    func formatMonthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年　M月"
        return formatter.string(from: date)
    }
    
    /// その日付の月初めを取得
    func getStartOfMonth(from date: Date) -> Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date))
    }
    
    /// 曜日を取得する処理
    func getJapaneseWeekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    /// 配列の中に特定の日付があるか確認する処理
    func checkContainSelectedDate(dateArray: [Date], date: Date) -> Bool {
        let calendar = Calendar.current
        return dateArray.contains { day in
            calendar.isDate(day, inSameDayAs: date)
        }
    }

    /// 今日の日付を年月日曜日の形式に変換
    func todayAddWeek() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日 EEEE"
        return formatter.string(from: Date())
    }
}
