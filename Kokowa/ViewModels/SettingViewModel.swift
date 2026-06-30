//
//  SettingViewModel.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import Combine
import SwiftData

final class SettingViewModel: ObservableObject {
    private var authManager: AuthManager?
    private var accountRepository: AccountRepository?

    /// AuthManagerをViewModelにセットする。
    func setAuthManager(authManager: AuthManager) {
        self.authManager = authManager
    }

    /// アカウント削除に必要なリポジトリをセットする。
    func setModelContext(_ modelContext: ModelContext) {
        self.accountRepository = LocalAccountRepository(modelContext: modelContext)
    }

    /// ログイン状態だけを解除して最初の画面へ戻る。
    func handleLogoutTap() {
        authManager?.SignOut()
    }

    /// ローカル保存データと認証情報を削除する。
    func handleDeleteAccountTap() {
        guard let userId = authManager?.userId else {
            authManager?.DeleteAccount()
            return
        }

        do {
            try accountRepository?.deleteAccountData(userId: userId)
            authManager?.DeleteAccount()
        } catch {
            return
        }
    }
}
