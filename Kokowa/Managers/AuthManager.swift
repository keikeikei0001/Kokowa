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
    @Published var isNewUser = false
    @Published var userId: String?
    private let keychainRepository = KeychainRepository()
    
    init() {
        if let identifier = keychainRepository.loadFromKeychain() {
            DispatchQueue.main.async {
                self.userId = identifier
                self.isSignedIn = true
            }
        }
    }
    
    func SignIn(userId: String) {
        keychainRepository.saveToKeychain(userIdentifier: userId)
        DispatchQueue.main.async {
            self.userId = userId
            self.isSignedIn = true
        }
    }
    
    func SignOut() {
        self.isSignedIn = false
        self.isNewUser = false
        self.userId = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.keychainRepository.deleteFromKeychain()
        }
    }
}
