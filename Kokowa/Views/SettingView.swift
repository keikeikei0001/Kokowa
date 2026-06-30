//
//  SettingView.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI

struct SettingView: View {
    let s = KeychainRepository()
    let i = AuthManager()
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button("Logout") {
            s.deleteFromKeychain()
            i.SignOut()
            UserDefaults.standard.removeObject(forKey: "testUserId")
            UserDefaults.standard.removeObject(forKey: "newUser")
        }
    }
}


