//
//  KeychainRepository.swift
//  LifeIsRpg
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI
import KeychainAccess
import Combine

class KeychainRepository: ObservableObject {
    let keychain = Keychain(service: "com.example.Kokowa")
    
    /// ユーザーIDをキーチェインに保存する
    func saveToKeychain(userIdentifier: String) {
        do {
            try keychain.set(userIdentifier, key: "appleUserIdentifier")
        } catch {
            return
        }
    }
    
    /// ユーザーIDをキーチェインから取得する
    func loadFromKeychain() -> String? {
        do {
            return try keychain.get("appleUserIdentifier")
        } catch {
            return nil
        }
    }
    
    /// ユーザーIDをキーチェインから削除する
    func deleteFromKeychain() {
        do {
            try keychain.remove("appleUserIdentifier")
        } catch {
            return
        }
    }
}
