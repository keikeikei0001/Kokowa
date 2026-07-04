//
//  SoundPlayer.swift
//  LifeIsRpg
//
//  Created by けいけい on 2024/12/22.
//

import SwiftUI
import AVFoundation

class SoundPlayer {
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    /// レベルアップ時の効果音処理
    func playLevelUpSound() {
        if let asset = NSDataAsset(name: "レベルアップ") {
            do {
                audioPlayer = try AVAudioPlayer(data: asset.data)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("音声の再生に失敗しました: \(error.localizedDescription)")
            }
        } else {
            print("音声ファイルが見つかりません")
        }
    }
}
