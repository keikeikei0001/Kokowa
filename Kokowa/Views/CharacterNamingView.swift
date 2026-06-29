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
        ZStack {
            KokowaBackground()

            VStack(spacing: 18) {
                titleView()
                characterCardView()
                completeButtonView()
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
        }
        .hideKeyboardOnTap()
        .onAppear {
            viewModel.setAuthManager(authManager: authManager)
        }
    }
    
    /// タイトル表示View
    @ViewBuilder
    private func titleView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("名前をつける")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(KokowaStyle.primaryText)

            Text("これから一緒に過ごす相棒の名前を決めましょう")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KokowaStyle.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
    
    /// キャラクター名入力用テキストフィールド
    @ViewBuilder
    private func characterTextFieldView() -> some View {
        TextField("キャラに名前をつけてください", text: $viewModel.inputCharacterName)
            .font(.headline)
            .foregroundStyle(KokowaStyle.primaryText)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isFocused ? KokowaStyle.teal.opacity(0.65) : Color.white.opacity(0.9), lineWidth: 1)
            )
            .focused($isFocused)
            .onChange(of: viewModel.inputCharacterName) { newValue in
                viewModel.checkLimitSixCharacters(newValue: newValue)
            }
    }

    @ViewBuilder
    private func characterCardView() -> some View {
        VStack(spacing: 18) {
            characterTextFieldView()
            characterView()
        }
        .padding(22)
        .kokowaCard()
    }
    
    /// キャラクターView
    @ViewBuilder
    private func characterView() -> some View {
        VStack {
            Image(viewModel.characterId)
                .resizable()
                .scaledToFit()
                .frame(width: DeviceModel.width * 0.58, height: DeviceModel.height * 0.34)
                .shadow(color: KokowaStyle.teal.opacity(0.22), radius: 18, x: 0, y: 12)
        }
    }
    
    /// 完了ボタンView
    @ViewBuilder
    private func completeButtonView() -> some View {
        Button(action: viewModel.createInitialData) {
            Text("完了")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(viewModel.completeButtonColor, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: KokowaStyle.teal.opacity(viewModel.isEnabledcompleteButton ? 0 : 0.26), radius: 18, x: 0, y: 10)
        }
        .disabled(viewModel.isEnabledcompleteButton)
    }
}
