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
