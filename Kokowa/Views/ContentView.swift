//
//  ContentView.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        if authManager.isSignedIn {
            MainView()
        } else {
            if authManager.isNewUser {
                CharacterSelectedView()
            } else {
                LoginView()
            }
        }
    }
}




