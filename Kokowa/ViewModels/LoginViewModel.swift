//
//  LoginViewModel.swift
//  LifeIsRpg
//
//  Created by けいけい on 2024/11/24.
//

import SwiftUI
import AuthenticationServices

class LoginViewModel: ObservableObject {
    private var authManager: AuthManager?
    private let userDataManager = UserDataRepository()
    
    /// Apple IDログインのリクエスト設定
    func requestSignInAppleId(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = []
    }
    
    /// Apple IDログインの結果処理
    @MainActor
    func handleSignInButtonTap(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                userDataManager.checkAlreadyExsitUserId(userIdentifier: userId) { isNewUser in
                    if isNewUser {
                        self.authManager?.userId = userId
                        self.authManager?.isNewUser = isNewUser
                    } else {
                        self.authManager?.SignIn(userId: userId)
                    }
                }
            }
        case .failure(let error):
            print("Sign in with Apple failed: \(error.localizedDescription)")
        }
    }
    
    /// AuthMangerをセット
    func setAuthManager(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    /// テスト用サインイン処理
    @MainActor
    func handleSignInButtonTapTest() {
        let us = UserDefaults.standard
        if let userId = us.string(forKey: "testUserId") {
            let newUser = us.bool(forKey: "newUser")
            if newUser == false {
                authManager?.SignIn(userId: userId)
            } else {
                authManager?.userId = userId
                authManager?.isNewUser = true
            }
        } else {
            let newUserId = "\(UUID())"
            us.set(newUserId, forKey: "testUserId")
            authManager?.userId = newUserId
            authManager?.isNewUser = true
        }
    }
}
