//
//  LoginViewModel.swift
//  LifeIsRpg
//
//  Created by けいけい on 2024/11/24.
//

import SwiftUI
import AuthenticationServices
import Combine

class LoginViewModel: ObservableObject {
    private var authManager: AuthManager?
    
    /// AuthMangerをセット
    func setAuthManager(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    /// ログイン状態を保存する。
    @MainActor
    func handleSignInButtonTapTest() {
        authManager?.SignIn()
    }
}
