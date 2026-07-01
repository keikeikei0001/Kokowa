//
//  IntrospectionView.swift
//  Kokowa
//
//  Created by Codex on 2026/07/01.
//

import SwiftUI
import SwiftData

struct IntrospectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = IntrospectionViewModel()
    @State private var isInputPeriodPickerPresented = false

    let memoryEntry: MemoryEntry?

    /// 記憶記録を受け取って内観画面を初期化する。
    init(memoryEntry: MemoryEntry? = nil) {
        self.memoryEntry = memoryEntry
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            KokowaBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    headerView()
                    eventCardView()
                }
                .padding(.horizontal, 22)
                .padding(.top, 72)
                .padding(.bottom, 150)
            }

            if viewModel.isKeyboardVisible == false {
                returnButtonView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .hideKeyboardOnTap()
        .onAppear {
            viewModel.configure(memoryEntry: memoryEntry)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            viewModel.isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            viewModel.isKeyboardVisible = false
        }
        .sheet(isPresented: $isInputPeriodPickerPresented) {
            inputPeriodPickerSheetView()
        }
    }

    /// 日付・画面タイトル・補足文を表示するヘッダー。
    @ViewBuilder
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.todayText)
                .font(.headline.weight(.bold))
                .foregroundStyle(.secondaryTextGray)

            Text("内観")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(.primaryTextBlack)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text("出来事を分解し、気づきを見つける")
                .font(.title3.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
        }
    }

    /// 内観するネガティブな出来事の入力カードを表示する。
    @ViewBuilder
    private func eventCardView() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            cardTitleView(
                icon: "heart.text.square.fill",
                title: "ネガティブな感情を感じた出来事",
                color: .kokowaRose
            )

            titleFieldView()
            periodPickerView()
            peopleInputView()
        }
        .padding(18)
        .kokowaCard(cornerRadius: 22)
    }

    /// 出来事タイトルの入力欄を表示する。
    @ViewBuilder
    private func titleFieldView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            compactSectionTitleView(icon: "quote.bubble.fill", title: "出来事のタイトル", color: .kokowaRose)

            TextField("例: 先生に怒られた", text: $viewModel.titleText)
                .font(.headline)
                .foregroundStyle(.primaryTextBlack)
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(14)
        .background(Color.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// 時期を選ぶ入力欄を表示する。
    @ViewBuilder
    private func periodPickerView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            compactSectionTitleView(icon: "clock.arrow.circlepath", title: "時期", color: .kokowaTeal)

            Button {
                isInputPeriodPickerPresented = true
            } label: {
                HStack {
                    Text(viewModel.selectedPeriod.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primaryTextBlack)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.secondaryTextGray)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// 相手の入力欄と追加済みの相手を表示する。
    @ViewBuilder
    private func peopleInputView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            compactSectionTitleView(icon: "person.fill", title: "相手", color: .kokowaPeriwinkle)

            personDraftFieldView()

            if viewModel.people.isEmpty == false {
                peopleFieldListView()
            }

            addPersonButtonView()
        }
        .padding(14)
        .background(Color.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// 相手の新規入力欄を表示する。
    @ViewBuilder
    private func personDraftFieldView() -> some View {
        personFieldShell(numberText: "1") {
            TextField("相手の名前や関係を書く", text: $viewModel.personDraftText)
                .font(.headline)
                .foregroundStyle(.primaryTextBlack)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
        }
    }

    /// 相手を追加するボタンを表示する。
    @ViewBuilder
    private func addPersonButtonView() -> some View {
        Button {
            viewModel.addPerson()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.headline.weight(.bold))
                Text("相手を追加")
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(.kokowaPeriwinkle)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.kokowaPeriwinkle.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isAddPersonButtonDisabled)
        .opacity(viewModel.isAddPersonButtonDisabled ? 0.45 : 1)
    }

    /// 追加済みの相手入力欄を表示する。
    @ViewBuilder
    private func peopleFieldListView() -> some View {
        VStack(spacing: 8) {
            ForEach(Array(viewModel.people.enumerated()), id: \.offset) { index, person in
                personFieldShell(numberText: "\(index + 2)") {
                    HStack(spacing: 10) {
                        TextField(
                            "相手の名前や関係を書く",
                            text: Binding(
                                get: { person },
                                set: { viewModel.updatePerson(at: index, text: $0) }
                            )
                        )
                        .font(.headline)
                        .foregroundStyle(.primaryTextBlack)
                        .textInputAutocapitalization(.never)

                        Button {
                            viewModel.removePerson(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.secondaryTextGray)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    /// 相手入力欄の共通背景を表示する。
    @ViewBuilder
    private func personFieldShell<Content: View>(numberText: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 10) {
            Text(numberText)
                .font(.caption.weight(.bold))
                .foregroundStyle(.kokowaPeriwinkle)
                .frame(width: 28, height: 28)
                .background(.kokowaPeriwinkle.opacity(0.12), in: Circle())

            content()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// 入力用の時期ホイールピッカーを表示する。
    @ViewBuilder
    private func inputPeriodPickerSheetView() -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("時期")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)

                Spacer()

                Button("完了") {
                    isInputPeriodPickerPresented = false
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(.kokowaTeal)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            Picker("時期", selection: $viewModel.selectedPeriod) {
                ForEach(viewModel.periodOptions) { period in
                    Text(period.title).tag(period)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
        }
        .presentationDetents([.height(240)])
    }

    /// セクション見出しを表示する。
    @ViewBuilder
    private func cardTitleView(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.14), in: Circle())

            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primaryTextBlack)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
    }

    /// 入力カード内の小さな見出しを表示する。
    @ViewBuilder
    private func compactSectionTitleView(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.14), in: Circle())

            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primaryTextBlack)
                .lineLimit(1)
        }
    }

    /// ホーム画面へ戻るためのボタンを表示する。
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
