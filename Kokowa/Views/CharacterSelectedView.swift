//
//  CharacterSetUpView.swift
//  LifeIsRpg
//
//  Created by けいけい on 2024/11/25.
//

import SwiftUI

struct CharacterSelectedView: View {
    @StateObject var viewModel = CharacterSelectedViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                titleView()
                characterSelectedTabView()
                nextPageButtonView()
            }
            .padding()
        }
    }
    
    /// タイトル表示View
    @ViewBuilder
    private func titleView() -> some View {
        Text("キャラクター選択")
            .font(.title.bold())
            .padding(.top, 20)
    }
    
    /// キャラクター選択タブView
    @ViewBuilder
    private func characterSelectedTabView() -> some View {
        VStack {
            Text("→横にスワイプしてキャラ選択")
            TabView(selection: $viewModel.selectedCharacterIndex) {
                ForEach(viewModel.characters.indices, id: \.self) { index in
                    Image(viewModel.characters[index].imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: viewModel.characterImageSize)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: DeviceModel.height * 0.3)
            
            Text(viewModel.characters[viewModel.selectedCharacterIndex].name)
                .font(.headline)
            
            Text(viewModel.characters[viewModel.selectedCharacterIndex].explanation)
                .frame(width: DeviceModel.width * 0.8)
                .padding()
            Spacer()
        }
    }
    
    /// 押下時次のページに遷移するボタンView
    @ViewBuilder
    private func nextPageButtonView() -> some View {
        NavigationLink(destination: CharacterNamingView(
            viewModel: CharacterNamingViewModel(
                characterId: viewModel.characters[viewModel.selectedCharacterIndex].imageName
            )
        )) {
            Text("次へ")
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal, 20)
    }
}


