//
//  CharacterNamingViewModel.swift
//  LifeIsRpg
//
//  Created by けいけい on 2024/11/25.
//

import SwiftUI

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
    private let userDataManager = UserDataRepository()
    private let characterDataManager = CharacterDataRepository()
    
    var isEnabledcompleteButton: Bool {
        return inputCharacterName.isEmpty
    }
    
    var completeButtonColor: Color {
        return inputCharacterName.isEmpty ? Color.gray : Color.blue
    }
    
    init(characterId: String) {
        self.characterId = characterId
    }
    
    /// 初期データ作成処理
    @MainActor
    func createInitialData() {
        Task {
            await createUser()
            await createCharacterData()
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
    
    /// ユーザー情報作成
    private func createUser() async {
        _ = await userDataManager.saveUser(
            //            userName: authManager?.userName ?? "",
            usedCharacterId: characterId,
            userId: authManager?.userId ?? ""
        )
    }
    
    /// キャラクター情報新規作成
    private func createCharacterData() async {
        await characterDataManager.saveCharacter(
            id: characterId,
            name: inputCharacterName,
            userId: authManager?.userId ?? ""
        )
    }
}
