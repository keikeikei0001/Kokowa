//
//  AuthViewModel.swift
//  LifeIsRpg
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI
import Combine

class AuthManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var userId: String?

    private enum UserDefaultsKey {
        static let isSignedIn = "isSignedIn"
    }

    private let userDefaultsRepository = UserDefaultsRepository()

    /// 保存済みのログイン状態とユーザーIDを復元する。
    init() {
        userId = userDefaultsRepository.loadUserId()
        isSignedIn = UserDefaults.standard.bool(forKey: UserDefaultsKey.isSignedIn)
    }

    /// ログイン済みだがユーザーIDが未作成か判定する。
    var needsInitialUserSetup: Bool {
        isSignedIn && userId == nil
    }

    /// ログイン状態だけを保存する。
    func SignIn() {
        DispatchQueue.main.async {
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.isSignedIn)
            self.isSignedIn = true
        }
    }

    /// 指定したユーザーIDを保存してログイン状態にする。
    func SignIn(userId: String) {
        userDefaultsRepository.saveUserId(userId)
        DispatchQueue.main.async {
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.isSignedIn)
            self.userId = userId
            self.isSignedIn = true
        }
    }

    /// ログイン状態だけを解除する。
    func SignOut() {
        UserDefaults.standard.set(false, forKey: UserDefaultsKey.isSignedIn)
        self.isSignedIn = false
    }

    /// ログイン状態と保存済みユーザーIDを削除する。
    func DeleteAccount() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.isSignedIn)
        self.isSignedIn = false
        self.userId = nil
        userDefaultsRepository.deletePendingLevelUpEffect()
        userDefaultsRepository.deleteUserId()
    }
}
