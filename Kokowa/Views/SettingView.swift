//
//  SettingView.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI
import SwiftData

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SettingViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            KokowaBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    headerView()
                    accountCardView()
                    dataCardView()
                    actionCardView()
                }
                .padding(.horizontal, 22)
                .padding(.top, 72)
                .padding(.bottom, 104)
            }

            returnButtonView()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.setAuthManager(authManager: authManager)
            viewModel.setModelContext(modelContext)
        }
    }

    /// 画面タイトルと補足文を表示するヘッダー。
    @ViewBuilder
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kokowa")
                .font(.headline.weight(.bold))
                .foregroundStyle(.secondaryTextGray)

            Text("設定")
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .foregroundStyle(.primaryTextBlack)

            Text("アカウントと保存データを管理する")
                .font(.title3.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
        }
    }

    /// アカウント状態を表示するカード。
    @ViewBuilder
    private func accountCardView() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitleView(icon: "person.crop.circle.fill", title: "アカウント", color: .kokowaTeal)

            settingInfoRowView(title: "状態", value: viewModel.signInStatusText)
            settingInfoRowView(title: "ユーザーID", value: viewModel.userIdText)
        }
        .padding(22)
        .kokowaCard(cornerRadius: 24)
    }

    /// 保存データの扱いを表示するカード。
    @ViewBuilder
    private func dataCardView() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitleView(icon: "internaldrive.fill", title: "保存", color: .kokowaPeriwinkle)

            settingInfoRowView(title: "保存先", value: "この端末")
            settingInfoRowView(title: "同期", value: "未使用")
        }
        .padding(22)
        .kokowaCard(cornerRadius: 24)
    }

    /// ログアウトとアカウント削除の操作を表示するカード。
    @ViewBuilder
    private func actionCardView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitleView(icon: "slider.horizontal.3", title: "操作", color: .kokowaRose)
            logoutButtonView()
            deleteAccountButtonView()
        }
        .padding(22)
        .kokowaCard(cornerRadius: 24)
    }

    /// セクション見出しを表示する。
    @ViewBuilder
    private func sectionTitleView(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 54, height: 54)
                .background(color.opacity(0.14), in: Circle())

            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primaryTextBlack)
        }
    }

    /// 設定情報の1行を表示する。
    @ViewBuilder
    private func settingInfoRowView(title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.secondaryTextGray)

            Spacer()

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primaryTextBlack)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// ログイン状態だけを解除するボタンを表示する。
    @ViewBuilder
    private func logoutButtonView() -> some View {
        Button {
            viewModel.handleLogoutTap()
        } label: {
            settingActionLabelView(
                icon: "rectangle.portrait.and.arrow.right",
                title: "ログアウト",
                subtitle: "保存データは残したまま最初の画面へ戻る",
                color: .kokowaTeal
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLogoutButtonDisabled)
        .opacity(viewModel.isLogoutButtonDisabled ? 0.45 : 1)
    }

    /// アカウント削除を実行するボタンを表示する。
    @ViewBuilder
    private func deleteAccountButtonView() -> some View {
        Button(role: .destructive) {
            viewModel.handleDeleteAccountTap()
        } label: {
            settingActionLabelView(
                icon: "trash.fill",
                title: "アカウント削除",
                subtitle: "ユーザーIDとこの端末の記録を削除する",
                color: .kokowaRose
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isDeleteAccountButtonDisabled)
        .opacity(viewModel.isDeleteAccountButtonDisabled ? 0.45 : 1)
    }

    /// 設定操作ボタンの中身を表示する。
    @ViewBuilder
    private func settingActionLabelView(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)

                Text(subtitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// ホーム画面へ戻るためのボタンを表示する。
    @ViewBuilder
    private func returnButtonView() -> some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "house.fill")
                    .font(.title3).bold()
                Text("ホームに戻る")
                    .font(.title3).bold()
            }
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 22)
            .padding(.bottom, 18)
            .background(Color(.kokowaCloud))
        }
        .buttonStyle(.plain)
    }
}
