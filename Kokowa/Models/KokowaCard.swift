//
//  KokowaCard.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI

struct KokowaCard: ViewModifier {
    var cornerRadius: CGFloat = 24

    /// 共通カードの背景・枠線・影を適用する。
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.cordTransparentWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.78), lineWidth: 1)
                    )
                    .shadow(color: .kokowaTeal.opacity(0.13), radius: 24, x: 0, y: 12)
            )
    }
}
