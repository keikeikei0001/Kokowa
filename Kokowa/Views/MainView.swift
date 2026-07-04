//
//  MaiView.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                characterWorldView()
                bottomButtonView()
            }
            .ignoresSafeArea(edges: .top)
            .alert($viewModel.alert)
            .onAppear {
                viewModel.configure(modelContext: modelContext, userId: authManager.userId)
                viewModel.startPendingLevelUpEffectIfNeeded()
            }
        }
    }

    /// 背景・ステータス・メッセージ・キャラクターを重ねて表示する。
    @ViewBuilder
    private func characterWorldView() -> some View {
        GeometryReader { proxy in
            ZStack {
                mainBackgroundView(size: proxy.size)

                if viewModel.isLevelUpEffectActive {
                    Color.black.opacity(viewModel.levelUpBackdropOpacity)
                        .ignoresSafeArea()
                }

                VStack(spacing: 0) {
                    characterStatusCardView()
                        .padding(.horizontal, 22)
                        .padding(.top, proxy.safeAreaInsets.top + 76)

                    Spacer()
                }

                VStack(spacing: 0) {
                    Spacer()
                    characterImageView(screenSize: proxy.size)
                        .padding(.bottom, 35)
                }

                if viewModel.isInteractionLocked {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                }
            }
        }
    }

    /// メイン画面の背景画像を表示する。
    @ViewBuilder
    private func mainBackgroundView(size: CGSize) -> some View {
        Image("mainBackgroundImage")
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipped()
    }

    /// キャラクター名・レベル・ステータスを表示するカード。
    @ViewBuilder
    private func characterStatusCardView() -> some View {
        VStack(spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("キャラクターネーム")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondaryTextGray)

                    Text(viewModel.characterNameText)
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

                    Text(viewModel.characterLevelText)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.kokowaTeal)
                }
                .frame(width: 84, height: 84)
                .background(Color.white.opacity(0.78), in: Circle())
            }

            HStack(spacing: 12) {
                statusPill(
                    icon: "bolt.heart.fill",
                    title: viewModel.characterMentalText,
                    subtitle: "メンタル",
                    color: .kokowaRose
                )

                statusPill(
                    icon: "sparkles",
                    title: viewModel.characterExpText,
                    subtitle: "EXP",
                    color: .kokowaTeal
                )
            }
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

    /// ステータスカード内の小さな情報表示を作る。
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

    /// キャラクターからの短いメッセージを表示する。
    @ViewBuilder
    private func messageView(screenSize: CGSize) -> some View {
        Text(viewModel.characterMessageText)
            .font(.title3.weight(.bold))
            .foregroundStyle(.primaryTextBlack)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.78), in: Capsule())
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
            .opacity(viewModel.characterMessageOpacity)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.82)
            .padding(.horizontal, 22)
            .offset(
                x: viewModel.characterMessageOffsetX(in: screenSize),
                y: viewModel.characterMessageOffsetY(in: screenSize)
            )
    }

    /// キャラクター画像と影を表示する。
    @ViewBuilder
    private func characterImageView(screenSize: CGSize) -> some View {
        ZStack(alignment: .bottom) {
            levelUpEffectView(screenSize: screenSize)
            messageView(screenSize: screenSize)

            Ellipse()
                .fill(Color.black.opacity(0.20))
                .frame(
                    width: viewModel.characterShadowWidth(in: screenSize),
                    height: viewModel.characterShadowHeight(in: screenSize)
                )
                .offset(y: viewModel.characterShadowOffsetY(in: screenSize))

            ZStack {
                Image(viewModel.characterImageName)
                    .resizable()
                    .scaledToFit()

                Image(viewModel.characterImageName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.white)
                    .shadow(color: Color.white.opacity(0.75), radius: 16)
                    .opacity(viewModel.levelUpCharacterSilhouetteOpacity)
            }
            .frame(width: viewModel.characterImageWidth(in: screenSize))
            .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 10)
            .offset(
                x: viewModel.characterFootOffsetX(in: screenSize),
                y: viewModel.characterFootOffsetY(in: screenSize)
            )
            .scaleEffect(viewModel.levelUpCharacterScale, anchor: .bottom)
            .rotationEffect(.degrees(viewModel.motion.rotationAngle))
            .onTapGesture(perform: viewModel.handleCharacterImageTap)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: viewModel.characterStageHeight(in: screenSize),
            maxHeight: viewModel.characterStageHeight(in: screenSize),
            alignment: .bottom
        )
    }

    /// レベルアップ時の光・衝撃波・テキスト・粒子を表示する。
    @ViewBuilder
    private func levelUpEffectView(screenSize: CGSize) -> some View {
        if viewModel.isLevelUpEffectActive {
            let characterWidth = viewModel.characterImageWidth(in: screenSize)
            let baseEffectSize = characterWidth * 0.98

            ZStack {
                Circle()
                    .fill(Color.white.opacity(viewModel.levelUpFlashOpacity))
                    .frame(width: baseEffectSize, height: baseEffectSize)
                    .blur(radius: 22)
                    .scaleEffect(viewModel.levelUpFlashScale)

                Circle()
                    .stroke(Color.white.opacity(viewModel.levelUpRingOpacity), lineWidth: max(3, baseEffectSize * 0.02))
                    .frame(width: baseEffectSize * 0.76, height: baseEffectSize * 0.76)
                    .scaleEffect(viewModel.levelUpRingScale)

                ForEach(viewModel.levelUpParticles) { particle in
                    Circle()
                        .fill(Color.white)
                        .frame(width: particle.size, height: particle.size)
                        .shadow(color: Color.white.opacity(0.55), radius: 8)
                        .offset(
                            x: viewModel.levelUpParticleProgress ? particle.x : 0,
                            y: viewModel.levelUpParticleProgress ? particle.y : 0
                        )
                        .opacity(viewModel.levelUpParticleOpacity)
                        .animation(
                            .easeOut(duration: 0.95).delay(particle.delay),
                            value: viewModel.levelUpParticleProgress
                        )
                }

                VStack(spacing: 4) {
                    Text("LEVEL UP")
                        .font(.system(size: max(24, characterWidth * 0.13), weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.96))
                        .shadow(color: .kokowaTeal.opacity(0.22), radius: 10)
                        .shadow(color: Color.white.opacity(0.48), radius: 4)

                    Text(viewModel.levelUpText)
                        .font(.system(size: max(16, characterWidth * 0.075), weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
                .opacity(viewModel.levelUpTextOpacity)
                .scaleEffect(viewModel.levelUpTextScale)
                .offset(y: -characterWidth * 0.62)
            }
            .offset(
                x: viewModel.characterFootOffsetX(in: screenSize),
                y: viewModel.characterFootOffsetY(in: screenSize) - (characterWidth * 0.34)
            )
        }
    }

    /// 下部ボタンView
    private func bottomButtonView() -> some View {
        HStack(spacing: 1) {
            naviLinkButtonView("square.and.pencil", title: "記入", AnyView(EntryView()))
            naviLinkButtonView("book.closed.fill", title: "記録", AnyView(RecordView()))
            naviLinkButtonView("heart.text.square.fill", title: "記憶", AnyView(MemoryView()))
            naviLinkButtonView("sparkles", title: "内観", AnyView(IntrospectionView()))
            naviLinkButtonView("gear", title: "設定", AnyView(SettingView()))
        }
        .disabled(viewModel.isInteractionLocked)
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
