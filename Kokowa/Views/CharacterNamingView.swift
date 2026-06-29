//
//  CharacterNamingView.swift
//  LifeIsRpg
//
//  Created by けいけい on 2024/11/25.
//

import SwiftUI

struct CharacterNamingView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject var viewModel: CharacterNamingViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            titleView()
            characterTextFieldView()
            characterView()
            completeButtonView()
        }
        .padding()
        .onAppear {
            viewModel.setAuthManager(authManager: authManager)
        }
    }
    
    /// タイトル表示View
    @ViewBuilder
    private func titleView() -> some View {
        Text("名前を付けよう")
            .font(.title)
            .fontWeight(.bold)
            .padding(.top, 20)
    }
    
    /// キャラクター名入力用テキストフィールド
    @ViewBuilder
    private func characterTextFieldView() -> some View {
        TextField("キャラに名前をつけてください", text: $viewModel.inputCharacterName)
            .textFieldStyle(.roundedBorder)
            .padding()
            .focused($isFocused)
            .onChange(of: viewModel.inputCharacterName) { newValue in
                viewModel.checkLimitSixCharacters(newValue: newValue)
            }
    }
    
    /// キャラクターView
    @ViewBuilder
    private func characterView() -> some View {
        VStack {
            Image(viewModel.characterId)
                .resizable()
                .scaledToFit()
                .frame(width: DeviceModel.width/2)
                .padding()
            Spacer()
        }
    }
    
    /// 完了ボタンView
    @ViewBuilder
    private func completeButtonView() -> some View {
        Button(action: viewModel.createInitialData) {
            Text("完了")
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.completeButtonColor)
                .foregroundStyle(.white)
                .cornerRadius(10)
        }
        .disabled(viewModel.isEnabledcompleteButton)
        .padding(.horizontal, 20)
    }
}
