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
            ZStack {
                KokowaBackground()

                VStack(spacing: 18) {
                    titleView()
                    characterSelectedTabView()
                    nextPageButtonView()
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 18)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    /// タイトル表示View
    @ViewBuilder
    private func titleView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("相棒を選ぶ")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.primaryTextBlack)

            Text("一緒に心の記録を続けるキャラクターを選んでください")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primaryTextBlack)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
    
    /// キャラクター選択タブView
    @ViewBuilder
    private func characterSelectedTabView() -> some View {
        VStack(spacing: 14) {
            Text("横にスワイプして選択")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
                .frame(maxWidth: .infinity, alignment: .leading)

            TabView(selection: $viewModel.selectedCharacterIndex) {
                ForEach(viewModel.characters.indices, id: \.self) { index in
                    Image(viewModel.characters[index].imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: viewModel.characterImageSize, height: DeviceModel.height * 0.28)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: DeviceModel.height * 0.34)
            
            VStack(spacing: 8) {
                Text(viewModel.selectedCharacterName)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)

                Text(viewModel.selectedCharacterExplanation)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondaryTextGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 8)
        }
        .padding(22)
        .kokowaCard()
    }
    
    /// 押下時次のページに遷移するボタンView
    @ViewBuilder
    private func nextPageButtonView() -> some View {
        NavigationLink(destination: CharacterNamingView(
            viewModel: CharacterNamingViewModel(
                characterId: viewModel.selectedCharacterImageName
            )
        )) {
            Text("次へ")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(.kokowaTeal, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .kokowaTeal.opacity(0.26), radius: 18, x: 0, y: 10)
        }
    }
}
