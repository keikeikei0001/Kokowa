//
//  CharacterNamingViewModel.swift
//  LifeIsRpg
//
//  Created by けいけい on 2024/11/25.
//

import SwiftUI
import Combine
import SwiftData

class CharacterNamingViewModel: ObservableObject {
    @Published var inputCharacterName = ""
    
    var characterId: String

    /// キャラクターの情報を保持する。
    let characters: [(name: String, imageName: String)] = [
        ("クマねこ", "kumaneko0001"),
        ("ウルフねこ", "uruhuneko0001"),
        ("ウサねこ", "usaneko0001")
    ]
    
    private var authManager: AuthManager?
    private var modelContext: ModelContext?

    
    /// 完了ボタンを無効にするか判定する。
    var isEnabledcompleteButton: Bool {
        return inputCharacterName.isEmpty
    }
    
    /// 完了ボタンの背景色を返す。
    var completeButtonColor: Color {
        return inputCharacterName.isEmpty ? .secondaryTextGray.opacity(0.38) : .kokowaTeal
    }

    /// キャラクター画像の表示サイズを返す。
    var characterImageSize: CGSize {
        CGSize(width: DeviceModel.width * 0.58, height: DeviceModel.height * 0.34)
    }
    
    /// 選択されたキャラクターIDで初期化する。
    init(characterId: String) {
        self.characterId = characterId
    }
    
    /// 初期データ作成処理
    @MainActor
    func createInitialData() {
        guard let modelContext else { return }

        let userId = authManager?.userId ?? UUID().uuidString
        let userProfileRepository = LocalUserProfileRepository(modelContext: modelContext)
        let characterRepository = LocalCharacterRepository(
            modelContext: modelContext,
            userProfileRepository: userProfileRepository
        )

        do {
            _ = try characterRepository.createInitialCharacter(
                userId: userId,
                characterId: characterId,
                name: inputCharacterName
            )
        } catch {
            return
        }

        authManager?.SignIn(userId: userId)
    }
    
    /// 文字数を最大６文字に制限する処理
    func checkLimitSixCharacters(newValue: String) {
        inputCharacterName =  String().limitCharactersInputText(newValue, maxLength: 6)
    }
    
    /// AuthMangerをセット
    func setAuthManager(authManager: AuthManager) {
        self.authManager = authManager
    }

    /// SwiftDataのModelContextをセットする。
    func setModelContext(_ modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}
