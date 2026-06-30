//
//  KokowaApp.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI
import SwiftData

@main
struct KokowaApp: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .preferredColorScheme(.light)
        }
        .modelContainer(for: [
            UserProfile.self,
            OwnedCharacter.self,
            MentalEntry.self
        ])
    }
}
