//
//  CharacterNamingViewModel.swift
//  LifeIsRpg
//
//  Created by けいけい on 2024/11/25.
//

import SwiftUI
import Combine

class CharacterNamingViewModel: ObservableObject {
    @Published var inputCharacterName = ""
    
    var characterId: String
    // キャラクターの情報（個体名と画像）
    let characters: [(name: String, imageName: String)] = [
        ("クマねこ", "kumaneko0001"),
        ("ウルフねこ", "uruhuneko0001"),
        ("ウサねこ", "usaneko0001")
    ]
    
    private var authManager: AuthManager?

    
    var isEnabledcompleteButton: Bool {
        return inputCharacterName.isEmpty
    }
    
    var completeButtonColor: Color {
        return inputCharacterName.isEmpty ? .secondaryTextGray.opacity(0.38) : .kokowaTeal
    }
    
    init(characterId: String) {
        self.characterId = characterId
    }
    
    /// 初期データ作成処理
    @MainActor
    func createInitialData() {
        Task {
//            await createUser()
//            await createCharacterData()
            authManager?.SignIn(userId: authManager?.userId ?? "")
            authManager?.isNewUser = false
        }
    }
    
    /// 文字数を最大６文字に制限する処理
    func checkLimitSixCharacters(newValue: String) {
        inputCharacterName =  String().limitCharactersInputText(newValue, maxLength: 6)
    }
    
    /// AuthMangerをセット
    func setAuthManager(authManager: AuthManager) {
        self.authManager = authManager
    }
}
