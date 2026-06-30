//
//  EntryView.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/29.
//

import SwiftUI

struct EntryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EntryViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            KokowaBackground()

            /// 入力項目が縦に長くなるため、画面全体をスクロール可能にする。
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
                    gratitudeCardView()
                    memoCardView()
                    saveButtonView()
                }
                .padding(.horizontal, 22)
                .padding(.top, 72)
                .padding(.bottom, 132)
            }

            /// このアプリでは通常のタブ欄を使わず、ここではメイン画面へ戻る導線だけを置く。
            returnButtonView()
        }
        .navigationBarBackButtonHidden(true)
        .hideKeyboardOnTap()
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

            Slider(value: value, in: range, step: step)
                .tint(color)
        }
        .padding(22)
        .kokowaCard(cornerRadius: 24)
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
            .foregroundStyle(viewModel.selectedCondition == condition ? .white : .primaryTextBlack)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                viewModel.selectedCondition == condition ? .kokowaTeal : Color.white.opacity(0.56),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }

    /// 感謝を書き出すカード。現時点では1行だけの仮UI。
    @ViewBuilder
    private func gratitudeCardView() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.kokowaTerracotta)
                    .frame(width: 54, height: 54)
                    .background(Color(red: 0.82, green: 0.48, blue: 0.26).opacity(0.13), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("感謝")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primaryTextBlack)
                    Text("今日ありがたかったことを10個")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.secondaryTextGray)
                }
            }

            HStack(spacing: 12) {
                Text("1")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color(red: 0.82, green: 0.48, blue: 0.26))
                    .frame(width: 46, height: 46)
                    .background(.kokowaTerracotta.opacity(0.12), in: Circle())

                TextField("ありがとうと思えたこと", text: $viewModel.gratitudeText)
                    .font(.headline)
                    .foregroundStyle(.primaryTextBlack)
                    .textInputAutocapitalization(.never)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(22)
        .kokowaCard(cornerRadius: 24)
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
                    if viewModel.memoText.isEmpty {
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

    /// 保存ボタン。データ保存方法は後で決めるため、今は見た目だけ作っている。
    @ViewBuilder
    private func saveButtonView() -> some View {
        Button {
            viewModel.handleSaveTap()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2.weight(.bold))
                Text("保存")
                    .font(.title2.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(.kokowaTeal, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .kokowaTeal.opacity(0.24), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }

    /// 画面下部に固定する、メイン画面へ戻るためのボタン。
    @ViewBuilder
    private func returnButtonView() -> some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "house.fill")
                    .font(.title3).bold()
                Text("メインに戻る")
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
