//
//  EmotionFeelingSessionView.swift
//  Kokowa
//
//  Created by Codex on 2026/07/01.
//

import SwiftUI

struct EmotionFeelingSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EmotionFeelingSessionViewModel()
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                KokowaBackground()
                
                rippleLayerView()
                
                VStack(spacing: 22) {
                    topBarView()
                    
                    Spacer(minLength: 22)
                    
                    touchAreaView(size: proxy.size)
                    
                    Spacer(minLength: 18)
                    
                    progressPanelView()
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        viewModel.updateTouch(location: value.location)
                    }
                    .onEnded { _ in
                        viewModel.endTouch()
                    }
            )
            .onReceive(viewModel.sessionTimer) { _ in
                viewModel.tick()
            }
        }
    }
    
    /// 画面上部の閉じる操作とタイトルを表示する。
    @ViewBuilder
    private func topBarView() -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("感情を感じ切る")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)
                
                Text("5分間、心に起きる反応を見守る")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.68), in: Circle())
            }
            .buttonStyle(.plain)
        }
    }
    
    /// 長押しする中央エリアを表示する。
    @ViewBuilder
    private func touchAreaView(size: CGSize) -> some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(viewModel.isPressing ? Color.kokowaRose.opacity(0.18) : Color.white.opacity(0.72))
                    .frame(width: min(size.width * 0.58, 230), height: min(size.width * 0.58, 230))
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.9), lineWidth: 2)
                    }
                    .shadow(color: .kokowaRose.opacity(viewModel.isPressing ? 0.18 : 0.08), radius: 28, x: 0, y: 16)
                
                Image(systemName: viewModel.isCompleted ? "checkmark.circle.fill" : "hand.point.up.left.fill")
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(viewModel.isCompleted ? .kokowaTeal : .kokowaRose)
            }
            
            Text(viewModel.guidanceText)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primaryTextBlack)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("途中で指を離すと一時停止します")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
                .opacity(viewModel.isCompleted ? 0 : 1)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .kokowaCard(cornerRadius: 28)
    }
    
    /// 経過時間と残り時間を表示するパネル。
    @ViewBuilder
    private func progressPanelView() -> some View {
        VStack(spacing: 14) {
            ProgressView(value: viewModel.progress)
                .tint(.kokowaRose)
            
            HStack {
                timeTextView(title: "経過", value: viewModel.elapsedTimeText)
                
                Spacer()
                
                timeTextView(title: "残り", value: viewModel.remainingTimeText)
            }
            
            if viewModel.isCompleted {
                Button {
                    dismiss()
                } label: {
                    Text("内観に戻る")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.kokowaTeal, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .kokowaCard(cornerRadius: 22)
    }
    
    /// 時間表示用の小さなラベルを表示する。
    @ViewBuilder
    private func timeTextView(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
            
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primaryTextBlack)
        }
    }
    
    /// タッチ位置から広がる波紋を表示する。
    @ViewBuilder
    private func rippleLayerView() -> some View {
        ForEach(viewModel.ripples) { ripple in
            EmotionRippleView(ripple: ripple)
        }
    }
}

private struct EmotionRippleView: View {
    let ripple: EmotionRipple
    
    @State private var scale = 0.25
    @State private var opacity = 0.55
    
    var body: some View {
        Circle()
            .stroke(Color.kokowaRose.opacity(opacity), lineWidth: 3)
            .frame(width: 86, height: 86)
            .scaleEffect(scale)
            .position(ripple.location)
            .allowsHitTesting(false)
            .onAppear {
                animateRipple()
            }
    }
    
    /// 波紋が広がって消えるアニメーションを開始する。
    private func animateRipple() {
        withAnimation(.easeOut(duration: 1.25)) {
            scale = 3.4
            opacity = 0
        }
    }
}
