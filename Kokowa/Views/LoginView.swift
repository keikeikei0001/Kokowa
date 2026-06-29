//
//  LoginView.swift
//  LifeIsRpg
//
//  Created by けいけい on 2024/11/22.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            KokowaBackground()

            VStack(spacing: 24) {
                Spacer()
                explanatoryTextView()
                SignInButtonTest()
                Spacer()
            }
            .padding(24)
        }
        .onAppear {
            viewModel.setAuthManager(authManager: authManager)
        }
    }
    
    /// 画面の説明文View
    @ViewBuilder
    private func explanatoryTextView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kokowa")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(KokowaStyle.primaryText)

            Text("あなたの心に寄り添う相棒を育てましょう")
                .font(.headline)
                .foregroundStyle(KokowaStyle.secondaryText)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(28)
        .kokowaCard()
    }
    
    /// テスト用のサインインView
    @ViewBuilder
    private func SignInButtonTest() -> some View {
        Button(action: viewModel.handleSignInButtonTapTest) {
            Text("はじめる")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(KokowaStyle.teal, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: KokowaStyle.teal.opacity(0.28), radius: 18, x: 0, y: 10)
        }
    }
}




