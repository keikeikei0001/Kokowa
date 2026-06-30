//
//  EntryView.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI
import SwiftData

struct EntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = EntryViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            KokowaBackground()

            // 入力項目が縦に長くなるため、画面全体をスクロール可能にする。
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    headerView()
                    summaryCardView()
                    scoreSliderCard(
                        icon: "heart.fill",
                        title: "メンタル",
                        valueText: viewModel.mentalScoreText,
                        value: $viewModel.mentalScore,
                        range: 0.0...10.0,
                        step: 0.5,
                        color: .kokowaRose
                    )
                    scoreSliderCard(
                        icon: "moon.stars.fill",
                        title: "睡眠時間",
                        valueText: viewModel.sleepHoursText,
                        value: $viewModel.sleepHours,
                        range: 0.0...12.0,
                        step: 0.5,
                        color: .kokowaPeriwinkle
                    )
                    conditionCardView()
                    stressLevelCardView()
                    gratitudeCardView()
                    memoCardView()
                    saveButtonView()
                }
                .padding(.horizontal, 22)
                .padding(.top, 72)
                .padding(.bottom, 132)
            }

            // このアプリでは通常のタブ欄を使わず、ここではホーム画面へ戻る導線だけを置く。
            if viewModel.isKeyboardVisible == false {
                returnButtonView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .hideKeyboardOnTap()
        .onAppear {
            viewModel.configure(modelContext: modelContext, userId: authManager.userId)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            viewModel.isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            viewModel.isKeyboardVisible = false
        }
    }

    /// 日付・画面タイトル・補足文を表示するヘッダー。
    @ViewBuilder
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.todayText)
                .font(.headline.weight(.bold))
                .foregroundStyle(.secondaryTextGray)

            Text("心の状態を記入")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.primaryTextBlack)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text("今日の自分を、やさしく残す")
                .font(.title3.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
        }
    }

    /// 現在選択中のメンタル・睡眠・体調を大きく見せる概要カード。
    @ViewBuilder
    private func summaryCardView() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("今のメンタル")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.secondaryTextGray)

                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Text(viewModel.mentalScoreNumberText)
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundStyle(.primaryTextBlack)

                        Text("点")
                            .font(.title.weight(.bold))
                            .foregroundStyle(.secondaryTextGray)
                    }
                }

                Spacer()

                Image(systemName: "heart.fill")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.kokowaRose)
                    .frame(width: 88, height: 88)
                    .background(.kokowaRose.opacity(0.14), in: Circle())
            }

            HStack(spacing: 14) {
                miniSummaryView(
                    icon: "moon.fill",
                    title: "睡眠",
                    value: viewModel.sleepHoursShortText,
                    color: .kokowaPeriwinkle
                )
                miniSummaryView(
                    icon: viewModel.selectedCondition.iconName,
                    title: "体調",
                    value: viewModel.selectedCondition.title,
                    color: .kokowaTeal
                )
            }
        }
        .padding(24)
        .kokowaCard(cornerRadius: 28)
    }

    /// 概要カード内で、睡眠や体調などの小さな情報を表示する部品。
    @ViewBuilder
    private func miniSummaryView(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 42, height: 42)
                .background(color.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)

                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// メンタル点数・睡眠時間のように、バーで数値を選ぶカード。
    @ViewBuilder
    private func scoreSliderCard(
        icon: String,
        title: String,
        valueText: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        color: Color
    ) -> some View {
        VStack(spacing: 18) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(color)
                    .frame(width: 54, height: 54)
                    .background(color.opacity(0.14), in: Circle())

                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)

                Spacer()

                Text(valueText)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)
            }

            tappableScoreSlider(value: value, range: range, step: step, color: color)
        }
        .padding(22)
        .kokowaCard(cornerRadius: 24)
    }

    /// バー上のどこを触っても値を変更できるスライダーを表示する。
    @ViewBuilder
    private func tappableScoreSlider(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        color: Color
    ) -> some View {
        GeometryReader { proxy in
            let progress = viewModel.scoreProgress(value: value.wrappedValue, range: range)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.kokowaMint.opacity(0.64))
                    .frame(height: 16)

                Capsule()
                    .fill(color)
                    .frame(width: proxy.size.width * progress, height: 16)

                Circle()
                    .fill(.white)
                    .frame(width: 30, height: 30)
                    .shadow(color: color.opacity(0.28), radius: 8, x: 0, y: 4)
                    .overlay(
                        Circle()
                            .stroke(color, lineWidth: 4)
                    )
                    .offset(x: max(0, (proxy.size.width - 30) * progress))
            }
            .frame(height: 34)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        value.wrappedValue = viewModel.scoreValue(
                            locationX: gesture.location.x,
                            trackWidth: proxy.size.width,
                            range: range,
                            step: step
                        )
                    }
            )
        }
        .frame(height: 34)
    }

    /// 体調を4択で選ぶカード。選択中の項目だけミント色で強調する。
    @ViewBuilder
    private func conditionCardView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                Image(systemName: "sun.max.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.kokowaTeal)
                    .frame(width: 54, height: 54)
                    .background(.kokowaTeal.opacity(0.14), in: Circle())

                Text("体調")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(EntryCondition.allCases) { condition in
                    conditionButton(condition)
                }
            }
        }
        .padding(22)
        .kokowaCard(cornerRadius: 24)
    }

    /// 体調カード内の1つぶんの選択ボタン。
    @ViewBuilder
    private func conditionButton(_ condition: EntryCondition) -> some View {
        Button {
            viewModel.selectCondition(condition)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: condition.iconName)
                    .font(.headline.weight(.bold))
                Text(condition.title)
                    .font(.headline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(viewModel.conditionButtonForegroundColor(for: condition))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                viewModel.conditionButtonBackgroundColor(for: condition),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }

    /// ストレスレベルを4択で選ぶカード。
    @ViewBuilder
    private func stressLevelCardView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                Image(systemName: "waveform.path.ecg")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.kokowaRose)
                    .frame(width: 54, height: 54)
                    .background(.kokowaRose.opacity(0.14), in: Circle())

                Text("ストレス")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(StressLevel.allCases) { stressLevel in
                    stressLevelButton(stressLevel)
                }
            }
        }
        .padding(22)
        .kokowaCard(cornerRadius: 24)
    }

    /// ストレスレベルカード内の1つぶんの選択ボタン。
    @ViewBuilder
    private func stressLevelButton(_ stressLevel: StressLevel) -> some View {
        Button {
            viewModel.selectStressLevel(stressLevel)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: stressLevel.iconName)
                    .font(.headline.weight(.bold))
                Text(stressLevel.title)
                    .font(.headline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(viewModel.stressLevelButtonForegroundColor(for: stressLevel))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                viewModel.stressLevelButtonBackgroundColor(for: stressLevel),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }

    /// 感謝を書き出すカード。
    @ViewBuilder
    private func gratitudeCardView() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.kokowaTerracotta)
                    .frame(width: 54, height: 54)
                    .background(.kokowaTerracotta.opacity(0.13), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("感謝")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primaryTextBlack)
                    Text("今日ありがたかったこと \(viewModel.gratitudeCountText)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.secondaryTextGray)
                }
            }

            ForEach(viewModel.gratitudeFieldIndices, id: \.self) { index in
                gratitudeFieldView(index: index)
            }
        }
        .padding(22)
        .kokowaCard(cornerRadius: 24)
    }

    /// 感謝カードの入力欄を表示する。
    @ViewBuilder
    private func gratitudeFieldView(index: Int) -> some View {
        HStack(spacing: 12) {
            Text("\(index + 1)")
                .font(.headline.weight(.bold))
                .foregroundStyle(.kokowaTerracotta)
                .frame(width: 46, height: 46)
                .background(.kokowaTerracotta.opacity(0.12), in: Circle())

            TextField(
                "ありがとうと思えたこと",
                text: Binding(
                    get: { viewModel.gratitudeTexts[index] },
                    set: { viewModel.updateGratitudeText(at: index, text: $0) }
                ),
                axis: .vertical
            )
            .font(.headline)
            .foregroundStyle(.primaryTextBlack)
            .lineLimit(2, reservesSpace: true)
            .frame(minHeight: viewModel.gratitudeFieldHeight)
            .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// 今日感じたことを自由に残すメモ欄。
    @ViewBuilder
    private func memoCardView() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                Image(systemName: "text.bubble.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.kokowaTeal)
                    .frame(width: 54, height: 54)
                    .background(.kokowaTeal.opacity(0.14), in: Circle())

                Text("メモ")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)
            }

            TextEditor(text: $viewModel.memoText)
                .font(.headline)
                .foregroundStyle(.primaryTextBlack)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 150)
                .padding(14)
                .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if viewModel.shouldShowMemoPlaceholder {
                        Text("感じたことを短く残す")
                            .font(.headline)
                            .foregroundStyle(.secondaryTextGray.opacity(0.42))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 22)
                            .allowsHitTesting(false)
                    }
                }
        }
        .padding(22)
        .kokowaCard(cornerRadius: 24)
    }

    /// 記録の保存または変更を実行するボタン。
    @ViewBuilder
    private func saveButtonView() -> some View {
        Button {
            viewModel.handleSaveTap()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2.weight(.bold))
                Text(viewModel.saveButtonTitle)
                    .font(.title2.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(viewModel.saveButtonColor, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: viewModel.saveButtonShadowColor, radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }

    /// 画面下部に固定する、ホーム画面へ戻るためのボタン。
    @ViewBuilder
    private func returnButtonView() -> some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "house.fill")
                    .font(.title3).bold()
                Text("ホームに戻る")
                    .font(.title3).bold()
            }
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 22)
            .padding(.bottom, 18)
            .background(Color(.kokowaCloud))
        }
        .buttonStyle(.plain)
    }
}
