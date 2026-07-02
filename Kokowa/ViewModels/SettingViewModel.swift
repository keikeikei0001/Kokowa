//
//  SettingViewModel.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import Foundation
import Combine
import SwiftData
import SwiftUI

final class SettingViewModel: ObservableObject {
    @Published var userIdText = "未作成"
    @Published var isSignedIn = false
    @Published var alert: AlertContext?

    private var authManager: AuthManager?
    private var accountRepository: AccountRepository?

    /// ログイン状態の表示用テキストを返す。
    var signInStatusText: String {
        isSignedIn ? "ログイン中" : "ログアウト中"
    }

    /// ログアウトボタンを無効にするか判定する。
    var isLogoutButtonDisabled: Bool {
        isSignedIn == false
    }

    /// アカウント削除ボタンを無効にするか判定する。
    var isDeleteAccountButtonDisabled: Bool {
        authManager?.userId == nil
    }

    /// AuthManagerをViewModelにセットする。
    func setAuthManager(authManager: AuthManager) {
        self.authManager = authManager
        refreshAuthState()
    }

    /// アカウント削除に必要なリポジトリをセットする。
    func setModelContext(_ modelContext: ModelContext) {
        self.accountRepository = LocalAccountRepository(modelContext: modelContext)
    }

    /// ログイン状態だけを解除して最初の画面へ戻る。
    func handleLogoutTap() {
        alert = AlertContext(
            title: "ログアウトしますか？",
            message: "保存データは残したまま、最初の画面へ戻ります。",
            actions: [
                AlertContext.Action(title: "キャンセル", role: .cancel) { [weak self] _ in
                    self?.alert = nil
                },
                AlertContext.Action(title: "ログアウト", role: nil) { [weak self] _ in
                    self?.logout()
                    self?.alert = nil
                }
            ]
        )
    }

    /// ローカル保存データと認証情報を削除する前の確認アラートを表示する。
    func handleDeleteAccountTap() {
        alert = AlertContext(
            title: "アカウントを削除しますか？",
            message: "ユーザーID、キャラクター、記入記録、記憶記録をこの端末から削除します。この操作は取り消せません。",
            actions: [
                AlertContext.Action(title: "キャンセル", role: .cancel) { [weak self] _ in
                    self?.alert = nil
                },
                AlertContext.Action(title: "削除", role: .destructive) { [weak self] _ in
                    self?.deleteAccount()
                    self?.alert = nil
                }
            ]
        )
    }

    /// ログイン状態だけを解除して最初の画面へ戻る。
    private func logout() {
        authManager?.SignOut()
        refreshAuthState()
    }

    /// ローカル保存データと認証情報を削除する。
    private func deleteAccount() {
        guard let userId = authManager?.userId else {
            authManager?.DeleteAccount()
            refreshAuthState()
            return
        }

        do {
            try accountRepository?.deleteAccountData(userId: userId)
            authManager?.DeleteAccount()
            refreshAuthState()
        } catch {
            return
        }
    }

    /// 表示用の認証状態を更新する。
    private func refreshAuthState() {
        userIdText = authManager?.userId ?? "未作成"
        isSignedIn = authManager?.isSignedIn ?? false
    }
}
