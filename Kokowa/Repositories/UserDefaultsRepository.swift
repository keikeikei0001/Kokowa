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
}
