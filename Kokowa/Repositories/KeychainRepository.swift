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
            print("Keychainに保存しました: \(userIdentifier)")
        } catch let error {
            print("Keychainへの保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    /// ユーザーIDをキーチェインから取得する
    func loadFromKeychain() -> String? {
        do {
            let userIdentifier = try keychain.get("appleUserIdentifier")
            print("Keychainから読み込みました: \(userIdentifier ?? "nil")")
            return userIdentifier
        } catch let error {
            print("Keychainからの読み込みに失敗しました: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// ユーザーIDをキーチェインから削除する
    func deleteFromKeychain() {
        do {
            try keychain.remove("appleUserIdentifier")
            print("Keychainから削除しました")
        } catch let error {
            print("Keychainからの削除に失敗しました: \(error.localizedDescription)")
        }
    }
}
