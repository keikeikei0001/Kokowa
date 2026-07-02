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

        self.alert(context.wrappedValue?.title ?? "", isPresented: isPresented) {
            if let context = context.wrappedValue {
                ForEach(Array(context.actions.enumerated()), id: \.self.element.id) { _, action in
                    Button(action.title, role: action.role) {
                        action.action(action)
                    }
                }
            }
        } message: {
            if let context = context.wrappedValue {
                Text(context.message)
            }
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

    /// テキストなどを1行に収め、長い場合だけ縮小する。
    func kokowaSingleLine(minimumScaleFactor: CGFloat = 0.72) -> some View {
        lineLimit(1)
            .minimumScaleFactor(minimumScaleFactor)
    }

    /// 半透明の白い角丸背景を適用する。
    func kokowaSurface(opacity: Double = 0.58, cornerRadius: CGFloat = 16) -> some View {
        background(Color.white.opacity(opacity), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    /// 画面下部に固定する戻るボタンを表示する。
    func kokowaBottomReturnButton(
        title: String = "ホームに戻る",
        iconName: String = "house.fill",
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.title3).bold()

                Text(title)
                    .font(.title3).bold()
            }
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 22)
            .padding(.bottom, 18)
            .background(Color(.kokowaCloud))
        }
        .buttonStyle(.plain)
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
