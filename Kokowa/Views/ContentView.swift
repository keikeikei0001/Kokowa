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
//        if authManager.isSignedIn {
//            MainView()
//        } else {
//            if authManager.isNewUser {
                CharacterSelectedView()
//            } else {
//                LoginView()
//            }
//        }
    }
}

enum KokowaStyle {
    static let primaryText = Color(red: 0.14, green: 0.19, blue: 0.20)
    static let secondaryText = Color(red: 0.43, green: 0.50, blue: 0.51)
    static let teal = Color(red: 0.18, green: 0.55, blue: 0.50)
    static let mint = Color(red: 0.78, green: 0.90, blue: 0.88)
    static let rose = Color(red: 0.82, green: 0.36, blue: 0.48)
    static let cream = Color(red: 0.99, green: 0.97, blue: 0.91)
    static let card = Color.white.opacity(0.76)
}

struct KokowaBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.90, green: 0.97, blue: 0.95),
                Color(red: 0.99, green: 0.97, blue: 0.91),
                Color(red: 0.94, green: 0.98, blue: 0.97)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct KokowaCard: ViewModifier {
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(KokowaStyle.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.78), lineWidth: 1)
                    )
                    .shadow(color: KokowaStyle.teal.opacity(0.13), radius: 24, x: 0, y: 12)
            )
    }
}

extension View {
    func kokowaCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(KokowaCard(cornerRadius: cornerRadius))
    }

    func hideKeyboardOnTap() -> some View {
        onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}
