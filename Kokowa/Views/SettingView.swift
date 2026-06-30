//
//  SettingView.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI
import SwiftData

struct SettingView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SettingViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Text("設定")
                .font(.title.bold())

            logoutButtonView()
            deleteAccountButtonView()
        }
        .onAppear {
            viewModel.setAuthManager(authManager: authManager)
            viewModel.setModelContext(modelContext)
        }
    }

    /// ログイン状態だけを解除するボタンを表示する。
    @ViewBuilder
    private func logoutButtonView() -> some View {
        Button("ログアウト") {
            viewModel.handleLogoutTap()
        }
    }

    /// アカウント削除を実行するボタンを表示する。
    @ViewBuilder
    private func deleteAccountButtonView() -> some View {
        Button("アカウント削除", role: .destructive) {
            viewModel.handleDeleteAccountTap()
        }
    }
}
