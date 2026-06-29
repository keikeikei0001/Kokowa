//
//  MaiView.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack {
            KokowaBackground()

            VStack(spacing: 18) {
                headerView()
                characterStatusView()
                actionCardView()
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
        }
    }

    @ViewBuilder
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Kokowa")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(KokowaStyle.primaryText)

            Text("今日の気持ちに、少しだけ寄り添う")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KokowaStyle.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func characterStatusView() -> some View {
        VStack(spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("キャラクターネーム")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KokowaStyle.secondaryText)

                    Text("ウルフねこ")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(KokowaStyle.primaryText)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("Lv")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(KokowaStyle.secondaryText)
                    Text("1")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(KokowaStyle.teal)
                }
                .frame(width: 86, height: 86)
                .background(Color.white.opacity(0.72), in: Circle())
            }

            Image("uruhuneko0001")
                .resizable()
                .scaledToFit()
                .frame(height: DeviceModel.height * 0.34)
                .shadow(color: KokowaStyle.teal.opacity(0.18), radius: 18, x: 0, y: 12)
        }
        .padding(24)
        .kokowaCard(cornerRadius: 28)
    }

    @ViewBuilder
    private func actionCardView() -> some View {
        HStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.title2.weight(.bold))
                .foregroundStyle(KokowaStyle.rose)
                .frame(width: 48, height: 48)
                .background(KokowaStyle.rose.opacity(0.13), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("次の成長まで")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KokowaStyle.secondaryText)
                Text("あと 3 日")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KokowaStyle.primaryText)
            }

            Spacer()
        }
        .padding(18)
        .kokowaCard(cornerRadius: 20)
    }
}
