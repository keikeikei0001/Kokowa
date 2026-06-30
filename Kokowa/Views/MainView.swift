//
//  MaiView.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                characterWorldView()
                bottomButtonView()
            }
            .ignoresSafeArea(edges: .top)
            .alert($viewModel.alert)
            .onAppear(perform: viewModel.handleOnAppear)
        }
    }

    @ViewBuilder
    private func characterWorldView() -> some View {
        GeometryReader { proxy in
            ZStack {
                mainBackgroundView(size: proxy.size)

                VStack(spacing: 0) {
                    characterStatusCardView()
                        .padding(.horizontal, 22)
                        .padding(.top, proxy.safeAreaInsets.top + 76)

                    Spacer()
                }

                VStack(spacing: 0) {
                    Spacer()
                    messageView()
                    characterImageView(sceneHeight: proxy.size.height)
                        .padding(.bottom, 20)
                }
            }
        }
    }

    @ViewBuilder
    private func mainBackgroundView(size: CGSize) -> some View {
        Image("mainBackgroundImage")
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipped()
    }

    @ViewBuilder
    private func characterStatusCardView() -> some View {
        VStack(spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("キャラクターネーム")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondaryTextGray)

                    Text(viewModel.character.name)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.primaryTextBlack)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                Spacer(minLength: 16)

                VStack(spacing: 2) {
                    Text("Lv")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.secondaryTextGray)

                    Text("\(viewModel.character.level)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.kokowaTeal)
                }
                .frame(width: 84, height: 84)
                .background(Color.white.opacity(0.78), in: Circle())
            }

            HStack(spacing: 12) {
                statusPill(
                    icon: "bolt.heart.fill",
                    title: viewModel.characterHpText,
                    subtitle: "HP",
                    color: .kokowaTeal
                )

                statusPill(
                    icon: "sparkles",
                    title: viewModel.characterExpText,
                    subtitle: "EXP",
                    color: .kokowaRose
                )
            }

            progressBar(value: viewModel.expRatio, color: .kokowaTeal)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.85), lineWidth: 1.2)
                )
                .shadow(color: .kokowaTeal.opacity(0.16), radius: 28, x: 0, y: 16)
        )
    }

    @ViewBuilder
    private func statusPill(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text(subtitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    private func progressBar(value: Double, color: Color) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.kokowaMint.opacity(0.64))

                Capsule()
                    .fill(color)
                    .frame(width: proxy.size.width * min(max(value, 0), 1))
            }
        }
        .frame(height: 12)
    }

    @ViewBuilder
    private func messageView() -> some View {
        Text("君は天才だニャン！")
            .font(.title3.weight(.bold))
            .foregroundStyle(.primaryTextBlack)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.78), in: Capsule())
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
            .opacity(viewModel.characterMessageOpacity)
            .padding(.bottom, 10)
    }

    @ViewBuilder
    private func characterImageView(sceneHeight: CGFloat) -> some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.20))
                .frame(width: 180 * viewModel.motion.shadowScale, height: 34 * viewModel.motion.shadowScale)
                .offset(y: min(sceneHeight * 0.19, 96))

            Image(viewModel.character.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: viewModel.characterImageSize)
                .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 10)
                .offset(y: viewModel.motion.jumpOffset)
                .rotationEffect(.degrees(viewModel.motion.rotationAngle))
                .onTapGesture(perform: viewModel.handleCharacterImageTap)
        }
        .frame(maxWidth: .infinity)
    }

    /// 下部ボタンView
    private func bottomButtonView() -> some View {
        HStack {
            Spacer()
            naviLinkButtonView("square.and.pencil", title: "記入", AnyView(EntryView()))
            Spacer()
            naviLinkButtonView("calendar", title: "予定", AnyView(CalendarView()))
            Spacer()
            naviLinkButtonView("gear", title: "設定", AnyView(SettingView()))
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Color(.kokowaCloud))
    }

    /// ナビゲーションボタンView
    @ViewBuilder
    private func naviLinkButtonView(
        _ imageName: String,
        title: String,
        _ destination: AnyView
    ) -> some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 6) {
                Image(systemName: imageName)
                    .font(.system(size: 28, weight: .semibold))

                Text(title)
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(.secondaryTextGray)
            .frame(width: 78, height: 64)
        }
    }
}
