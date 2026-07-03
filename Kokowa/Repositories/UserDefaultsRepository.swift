//
//  UserDefaultsRepository.swift
//  Kokowa
//
//  Created by Codex on 2026/07/03.
//

import SwiftUI
import Combine

class UserDefaultsRepository: ObservableObject {
    private enum Key {
        static let userId = "userId"
        static let hasPendingLevelUpEffect = "hasPendingLevelUpEffect"
    }

    /// ユーザーIDをUserDefaultsに保存する。
    func saveUserId(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: Key.userId)
    }

    /// UserDefaultsからユーザーIDを取得する。
    func loadUserId() -> String? {
        UserDefaults.standard.string(forKey: Key.userId)
    }

    /// UserDefaultsからユーザーIDを削除する。
    func deleteUserId() {
        UserDefaults.standard.removeObject(forKey: Key.userId)
    }

    /// レベルアップ演出が未再生であることを保存する。
    func savePendingLevelUpEffect() {
        UserDefaults.standard.set(true, forKey: Key.hasPendingLevelUpEffect)
    }

    /// レベルアップ演出が未再生かどうかを返す。
    func hasPendingLevelUpEffect() -> Bool {
        UserDefaults.standard.bool(forKey: Key.hasPendingLevelUpEffect)
    }

    /// 未再生のレベルアップ演出フラグを削除する。
    func deletePendingLevelUpEffect() {
        UserDefaults.standard.removeObject(forKey: Key.hasPendingLevelUpEffect)
    }
}
