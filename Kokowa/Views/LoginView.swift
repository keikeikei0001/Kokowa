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
        VStack {
            explanatoryTextView()
            SignInButtonTest()
        }
        .onAppear {
            viewModel.setAuthManager(authManager: authManager)
        }
    }
    
    /// 画面の説明文View
    @ViewBuilder
    private func explanatoryTextView() -> some View {
        Text("ログイン / アカウント作成")
            .font(.title)
            .padding()
    }
    
    /// テスト用のサインインView
    @ViewBuilder
    private func SignInButtonTest() -> some View {
        Button(action: viewModel.handleSignInButtonTapTest) {
            Text("テスト用サインインボタン")
        }
    }
}





