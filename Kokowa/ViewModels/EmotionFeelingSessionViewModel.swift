//
//  EmotionFeelingSessionViewModel.swift
//  Kokowa
//
//  Created by Codex on 2026/07/01.
//

import Foundation
import SwiftUI
import Combine
import UIKit
import AudioToolbox

struct EmotionRipple: Identifiable {
    let id = UUID()
    let location: CGPoint
}

final class EmotionFeelingSessionViewModel: ObservableObject {
    @Published var isPressing = false
    @Published var elapsedSeconds = 0
    @Published var touchLocation: CGPoint?
    @Published var ripples: [EmotionRipple] = []
    @Published var isCompleted = false
    
    let sessionDurationSeconds = 300
    let sessionTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    /// 残り秒数を返す。
    var remainingSeconds: Int {
        max(sessionDurationSeconds - elapsedSeconds, 0)
    }
    
    /// 残り時間の表示用テキストを返す。
    var remainingTimeText: String {
        formatTime(remainingSeconds)
    }
    
    /// 経過時間の表示用テキストを返す。
    var elapsedTimeText: String {
        formatTime(elapsedSeconds)
    }
    
    /// セッションの進行率を返す。
    var progress: Double {
        min(Double(elapsedSeconds) / Double(sessionDurationSeconds), 1)
    }
    
    /// 画面中央に表示する案内文を返す。
    var guidanceText: String {
        if isCompleted {
            return "感じる時間が終わりました"
        }
        return isPressing ? "そのまま、湧き上がる感情を感じ続ける" : "画面に指を置くと始まります"
    }
    
    /// タッチ位置を更新し、必要ならセッションを開始する。
    func updateTouch(location: CGPoint) {
        guard isCompleted == false else { return }
        
        touchLocation = location
        if isPressing == false {
            isPressing = true
            feedbackGenerator.prepare()
            emitRipple()
            playFeedback()
        }
    }
    
    /// タッチ終了時にセッションの進行を一時停止する。
    func endTouch() {
        isPressing = false
    }
    
    /// 1秒ごとにセッションを進める。
    func tick() {
        guard isPressing, isCompleted == false else { return }
        
        elapsedSeconds += 1
        emitRipple()
        playFeedback()
        
        if elapsedSeconds >= sessionDurationSeconds {
            completeSession()
        }
    }
    
    /// セッションを最初の状態に戻す。
    func resetSession() {
        isPressing = false
        elapsedSeconds = 0
        touchLocation = nil
        ripples.removeAll()
        isCompleted = false
    }
    
    /// 波紋を追加し、一定時間後に消す。
    private func emitRipple() {
        let ripple = EmotionRipple(location: touchLocation ?? .zero)
        ripples.append(ripple)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
            self?.ripples.removeAll { $0.id == ripple.id }
        }
    }
    
    /// 振動と短いシステム音を鳴らす。
    private func playFeedback() {
        feedbackGenerator.impactOccurred(intensity: 0.55)
        AudioServicesPlaySystemSound(1104)
        feedbackGenerator.prepare()
    }
    
    /// セッションを完了状態にする。
    private func completeSession() {
        isCompleted = true
        isPressing = false
        AudioServicesPlaySystemSound(1005)
    }
    
    /// 秒数を分:秒の文字列に変換する。
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes):\(String(format: "%02d", remainingSeconds))"
    }
}
