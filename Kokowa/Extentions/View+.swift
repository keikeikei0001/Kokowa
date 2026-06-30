//
//  View+.swift
//  SampleAlert
//
//  Created by RikutoSato on 2024/11/29.
//

import SwiftUI

extension View {
    /// AlertContextを使った共通アラートを表示する。
    @ViewBuilder
    func alert(_ context: Binding<AlertContext?>) -> some View {
        let isPresented = Binding<Bool> {
            context.wrappedValue != nil
        } set: { isPresented in
            if isPresented == false {
                context.wrappedValue = nil
            }
        }
        
        if let context = context.wrappedValue {
            alert(context.title, isPresented: isPresented) {
                ForEach(Array(context.actions.enumerated()), id: \.self.element.id) { _, action in
                    Button(action.title, role: action.role) {
                        action.action(action)
                    }
                }
            } message: {
                Text(context.message)
            }
        } else {
            self
        }
    }
    
    /// アラート形式の日付ピッカーを表示する。
    @ViewBuilder
    func alertDatePicker(isPresented: Binding<Bool>, selectedDate: Binding<Date?>) -> some View {
        self.overlay(
            isPresented.wrappedValue ? AlertDataPickerWrapper(
                isPresented: isPresented,
                selectedDate: selectedDate
            ) : nil
        )
    }
    
    /// 指定した2色のグラデーション背景を設定する。
    @ViewBuilder
    func gradientBackgroundColor(
        _ colorTop: Color,
        _ colorBottom: Color
    ) -> some View {
        self.background(
            LinearGradient(
                colors: [colorTop, colorBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

extension View {
    /// Kokowa共通のカード背景を適用する。
    func kokowaCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(KokowaCard(cornerRadius: cornerRadius))
    }

    /// 画面タップ時にキーボードを閉じる。
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
    
    /// アプリ共通の背景グラデーションを表示する。
    @ViewBuilder
    func KokowaBackground() -> some View {
            LinearGradient(
                colors: [
                    .kokowaGrand1,
                    .kokowaGrand2,
                    .kokowaGrand3
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
}

