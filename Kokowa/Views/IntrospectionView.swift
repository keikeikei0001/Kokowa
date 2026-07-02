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
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel = IntrospectionViewModel()

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
                    decompositionCardView()
                    emotionReleaseView()
                    schemaAwarenessCardView()
                    insightView()
                    emotionFeelingSessionView()
                    emotionLoopRecommendationView()
                    InnerVoiceView()
                    saveActionButtonsView()
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
            viewModel.configure(modelContext: modelContext, userId: authManager.userId, memoryEntry: memoryEntry)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            viewModel.isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            viewModel.isKeyboardVisible = false
        }
        .sheet(isPresented: $viewModel.isInputPeriodPickerPresented) {
            inputPeriodPickerSheetView()
        }
        .sheet(isPresented: $viewModel.isEmotionSelectionPresented) {
            emotionSelectionSheetView()
        }
        .sheet(isPresented: $viewModel.isSchemaSelectionPresented) {
            schemaSelectionSheetView()
        }
        .fullScreenCover(isPresented: $viewModel.isEmotionFeelingSessionPresented) {
            EmotionFeelingSessionView()
        }
        .alert($viewModel.alert)
    }

    /// 日付・画面タイトル・補足文を表示するヘッダー。
    @ViewBuilder
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(viewModel.todayText)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
                    .padding(.top, 2)

                Spacer()

                deleteButtonView()
            }
            .padding(.bottom, -14)

            Text("内観")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(.primaryTextBlack)
                .kokowaSingleLine()

            Text("出来事を分解し、気づきを見つける")
                .font(.title3.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
        }
    }

    /// この出来事を削除するボタンを表示する。
    @ViewBuilder
    private func deleteButtonView() -> some View {
        Button {
            viewModel.showDeleteConfirmation {
                dismiss()
            }
        } label: {
            Image(systemName: "trash.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(.kokowaRose)
                .frame(width: 42, height: 42)
                .background(Color.white.opacity(0.72), in: Circle())
                .shadow(color: .kokowaRose.opacity(0.12), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
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

            resetCardButtonView(title: "出来事カード") {
                viewModel.resetEventCard()
            }
        }
        .padding(18)
        .kokowaCard(cornerRadius: 22)
    }

    /// 出来事を分解して理解するための入力カードを表示する。
    @ViewBuilder
    private func decompositionCardView() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            cardTitleView(
                icon: "square.stack.3d.up.fill",
                title: "出来事を分解する",
                color: .kokowaTeal
            )

            introspectionTextAreaView(
                icon: "doc.text.fill",
                title: "事実",
                note: "解釈を省き、事実だけを書く。\n真実は解釈を含むが、事実は解釈を含みません。",
                placeholder: "実際に起きたことだけを書く",
                color: .kokowaTerracotta,
                text: $viewModel.factText,
                shouldShowPlaceholder: viewModel.shouldShowFactPlaceholder,
                textMinHeight: 92
            )

            introspectionTextAreaView(
                icon: "figure.walk.motion",
                title: "行動",
                placeholder: "起きた事実に対して、自分が行ったことだけを書く",
                color: .kokowaTeal,
                text: $viewModel.actionText,
                shouldShowPlaceholder: viewModel.shouldShowActionPlaceholder,
                textMinHeight: 72
            )

            introspectionTextAreaView(
                icon: "figure.mind.and.body",
                title: "身体反応",
                placeholder: "胸が苦しい、涙が出る、力が抜けるなど",
                color: .kokowaPeriwinkle,
                text: $viewModel.bodyReactionText,
                shouldShowPlaceholder: viewModel.shouldShowBodyReactionPlaceholder,
                textMinHeight: 62
            )

            emotionSelectionFieldView()

            introspectionTextAreaView(
                icon: "brain.head.profile",
                title: "思考",
                placeholder: "その時に頭に浮かんだ言葉を書く",
                color: .kokowaTeal,
                text: $viewModel.thoughtText,
                shouldShowPlaceholder: viewModel.shouldShowThoughtPlaceholder,
                textMinHeight: 92
            )

            resetCardButtonView(title: "出来事の分解カード") {
                viewModel.resetDecompositionCard()
            }
        }
        .padding(18)
        .kokowaCard(cornerRadius: 22)
    }

    /// 感情を吐き出すための入力カードを表示する。
    @ViewBuilder
    private func emotionReleaseView() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            cardTitleView(
                icon: "flame.fill",
                title: "感情を吐き出す",
                color: .kokowaRose
            )

            TextEditor(text: $viewModel.emotionReleaseText)
                .font(.headline)
                .foregroundStyle(.primaryTextBlack)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 150)
                .padding(14)
                .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if viewModel.shouldShowEmotionReleasePlaceholder {
                        Text("感情を言葉にして、吐き出しましょう！汚い言葉を使っても構いません。紙に書いたり、誰にも聞かれないところで叫ぶのもおすすめです")
                            .font(.headline)
                            .foregroundStyle(.secondaryTextGray.opacity(0.42))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 22)
                            .allowsHitTesting(false)
                    }
                }

            resetCardButtonView(title: "感情を吐き出すカード") {
                viewModel.resetEmotionReleaseCard()
            }
        }
        .padding(18)
        .kokowaCard(cornerRadius: 22)
    }

    /// 反応している可能性がある早期不適応スキーマを選ぶカードを表示する。
    @ViewBuilder
    private func schemaAwarenessCardView() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            cardTitleView(
                icon: "heart.text.square.fill",
                title: "思考の奥にあるスキーマに気づく",
                color: .kokowaPeriwinkle
            )

            HStack(alignment: .top, spacing: 10) {
                Text("幼少期の経験から作られた「心のパターン」や「心の傷」が今回の出来事に反応している可能性があります。\n当てはまりそうなものを選びましょう。")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    viewModel.showSchemaInfoAlert()
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.kokowaPeriwinkle)
                }
                .buttonStyle(.plain)
            }

            Button {
                viewModel.isSchemaSelectionPresented = true
            } label: {
                HStack(spacing: 10) {
                    if viewModel.selectedSchemaItems.isEmpty {
                        Text("スキーマを選ぶ")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.secondaryTextGray.opacity(0.42))
                    } else {
                        FlowLayout(spacing: 6) {
                            ForEach(viewModel.selectedSchemaItems) { schema in
                                schemaChipView(schema.title)
                            }
                        }
                    }

                    Spacer(minLength: 5)

                    Image(systemName: "chevron.down")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.secondaryTextGray)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)

            resetCardButtonView(title: "スキーマを選ぶカード") {
                viewModel.resetSchemaCard()
            }
        }
        .padding(18)
        .kokowaCard(cornerRadius: 22)
    }

    /// 出来事から得られた気づきの入力カードを表示する。
    @ViewBuilder
    private func insightView() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            cardTitleView(
                icon: "lightbulb.fill",
                title: "この出来事から何に気づけたか？",
                color: .kokowaTerracotta
            )

            TextEditor(text: $viewModel.insightText)
                .font(.headline)
                .foregroundStyle(.primaryTextBlack)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 150)
                .padding(14)
                .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if viewModel.shouldShowInsightPlaceholder {
                        Text("この出来事から気づいたことを自分が本音で思える範囲で書く")
                            .font(.headline)
                            .foregroundStyle(.secondaryTextGray.opacity(0.42))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 22)
                            .allowsHitTesting(false)
                    }
                }

            resetCardButtonView(title: "気づきカード") {
                viewModel.resetInsightCard()
            }
        }
        .padding(18)
        .kokowaCard(cornerRadius: 22)
    }

    /// 感情を感じ切るセッションをするカードを表示する。
    @ViewBuilder
    private func emotionFeelingSessionView() -> some View {
        Button {
            viewModel.isEmotionFeelingSessionPresented = true
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                cardTitleView(
                    icon: "waveform.path",
                    title: "感情を感じ切る",
                    color: .kokowaRose
                )

                Text("画面に指を置き続けて、心に湧き起こる感情を静かに感じます。何度行っても構いません")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Image(systemName: "hand.tap.fill")
                        .font(.subheadline.weight(.bold))

                    Text("感情を感じる画面へ")
                        .font(.headline.weight(.bold))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.kokowaRose, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .kokowaCard(cornerRadius: 22)
        }
        .buttonStyle(.plain)
    }

    /// 感情を吐き出す工程へ戻ることを促す補足文を表示する。
    @ViewBuilder
    private func emotionLoopRecommendationView() -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "arrow.counterclockwise.circle.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(.kokowaTerracotta)
                .padding(.top, 1)

            Text("ここまで終わったら、感情を吐き出すに戻って何回かここまで繰り返すことをおすすめします。")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// 自分の心の声に耳を傾けるための入力カードを表示する。
    @ViewBuilder
    private func InnerVoiceView() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            cardTitleView(
                icon: "heart.fill",
                title: "心の声に耳を傾ける",
                color: .kokowaRose
            )

            introspectionTextAreaView(
                icon: "sparkles",
                title: "これからどうしたいのか？",
                placeholder: "この出来事をふまえて、これから自分がどうしたいのかを書く",
                color: .kokowaTerracotta,
                text: $viewModel.futureActionText,
                shouldShowPlaceholder: viewModel.shouldShowFutureActionPlaceholder,
                textMinHeight: 92
            )

            resetCardButtonView(title: "心の声カード") {
                viewModel.resetInnerVoiceCard()
            }
        }
        .padding(18)
        .kokowaCard(cornerRadius: 22)
    }

    /// 内観内容を保存するボタンを表示する。
    @ViewBuilder
    private func saveActionButtonsView() -> some View {
        VStack(spacing: 12) {
            Button {
                viewModel.saveInProgressIntrospection()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "tray.and.arrow.down.fill")
                        .font(.headline.weight(.bold))

                    Text("途中保存")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.kokowaTeal, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .kokowaTeal.opacity(0.22), radius: 18, x: 0, y: 10)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isIntrospectionSaveDisabled)
            .opacity(viewModel.isIntrospectionSaveDisabled ? 0.45 : 1)

            Button {
                viewModel.showCompleteConfirmation()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.headline.weight(.bold))

                    Text("内観完了")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.kokowaTeal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.kokowaTeal.opacity(0.45), lineWidth: 1.4)
                }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isIntrospectionSaveDisabled)
            .opacity(viewModel.isIntrospectionSaveDisabled ? 0.45 : 1)

            if viewModel.saveResultText.isEmpty == false {
                Text(viewModel.saveResultText)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
            }
        }
    }

    /// カード内の入力内容を画面上だけ消すリセットボタンを表示する。
    @ViewBuilder
    private func resetCardButtonView(title: String, action: @escaping () -> Void) -> some View {
        Button {
            viewModel.showResetConfirmation(title: title, onReset: action)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.caption.weight(.bold))

                Text(title)
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(.secondaryTextGray)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.5), in: Capsule())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    /// 感情を選ぶ入力欄を表示する。
    @ViewBuilder
    private func emotionSelectionFieldView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            compactSectionTitleView(icon: "heart.fill", title: "感情", color: .kokowaRose)

            Button {
                viewModel.isEmotionSelectionPresented = true
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        if viewModel.selectedEmotions.isEmpty == false {
                            FlowLayout(spacing: 6) {
                                ForEach(viewModel.selectedEmotions, id: \.self) { emotion in
                                    emotionChipView(emotion)
                                }
                            }
                        } else {
                            Text("感情に名前をつける")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.secondaryTextGray.opacity(0.42))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 5)

                        Image(systemName: "chevron.down")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.secondaryTextGray)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// 選択済みの感情タグを表示する。
    @ViewBuilder
    private func emotionChipView(_ emotion: String) -> some View {
        Text(emotion)
            .font(.caption.weight(.bold))
            .foregroundStyle(.kokowaRose)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.kokowaRose.opacity(0.12), in: Capsule())
    }

    /// 選択済みのスキーマタグを表示する。
    @ViewBuilder
    private func schemaChipView(_ schemaTitle: String) -> some View {
        Text(schemaTitle)
            .font(.caption.weight(.bold))
            .foregroundStyle(.kokowaPeriwinkle)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.kokowaPeriwinkle.opacity(0.12), in: Capsule())
    }

    /// 内観の項目を入力する複数行欄を表示する。
    @ViewBuilder
    private func introspectionTextAreaView(
        icon: String,
        title: String,
        note: String? = nil,
        placeholder: String,
        color: Color,
        text: Binding<String>,
        shouldShowPlaceholder: Bool,
        textMinHeight: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            compactSectionTitleView(icon: icon, title: title, color: color)

            if let note {
                Text(note)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.kokowaRose)
                    .fixedSize(horizontal: false, vertical: true)
            }

            TextEditor(text: text)
                .font(.headline)
                .foregroundStyle(.primaryTextBlack)
                .scrollContentBackground(.hidden)
                .frame(minHeight: textMinHeight)
                .padding(12)
                .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if shouldShowPlaceholder {
                        Text(placeholder)
                            .font(.headline)
                            .foregroundStyle(.secondaryTextGray.opacity(0.42))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }
        }
        .padding(14)
        .background(Color.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
                .kokowaSurface()
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
                viewModel.isInputPeriodPickerPresented = true
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
                .kokowaSurface()
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

            if viewModel.people.isEmpty == false {
                peopleFieldListView()
            }

            personDraftFieldView()

            addPersonButtonView()
        }
        .padding(14)
        .background(Color.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// 相手の新規入力欄を表示する。
    @ViewBuilder
    private func personDraftFieldView() -> some View {
        personFieldShell(numberText: viewModel.personDraftNumberText) {
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
            HStack(spacing: 6) {
                Image(systemName: "plus.circle.fill")
                    .font(.subheadline.weight(.bold))
                Text("相手を追加")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(.kokowaPeriwinkle)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
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
                personFieldShell(numberText: "\(index + 1)") {
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
                    viewModel.isInputPeriodPickerPresented = false
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

    /// 感情の選択シートを表示する。
    @ViewBuilder
    private func emotionSelectionSheetView() -> some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.negativeEmotionCategories) { category in
                        emotionCategoryView(category)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .background(Color(.kokowaCloud).opacity(0.35))
            .navigationTitle("感情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("クリア") {
                        viewModel.clearEmotions()
                    }
                    .foregroundStyle(.kokowaRose)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        viewModel.isEmotionSelectionPresented = false
                    }
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.kokowaTeal)
                }
            }
        }
        .presentationDetents([.large])
    }

    /// 感情カテゴリ内の選択肢を表示する。
    @ViewBuilder
    private func emotionCategoryView(_ category: NegativeEmotionCategory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category.title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primaryTextBlack)

            FlowLayout(spacing: 8) {
                ForEach(category.emotions, id: \.self) { emotion in
                    emotionOptionButtonView(emotion)
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// 感情を選択または解除するボタンを表示する。
    @ViewBuilder
    private func emotionOptionButtonView(_ emotion: String) -> some View {
        let isSelected = viewModel.isEmotionSelected(emotion)

        Button {
            viewModel.toggleEmotion(emotion)
        } label: {
            HStack(spacing: 6) {
                Text(emotion)
                    .font(.subheadline.weight(.bold))

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                }
            }
            .foregroundStyle(isSelected ? .white : .primaryTextBlack)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.kokowaRose : Color.white.opacity(0.74), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    /// 早期不適応スキーマの選択シートを表示する。
    @ViewBuilder
    private func schemaSelectionSheetView() -> some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.earlyMaladaptiveSchemaCategories) { category in
                        schemaCategoryView(category)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .background(Color(.kokowaCloud).opacity(0.35))
            .navigationTitle("早期不適応スキーマ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("クリア") {
                        viewModel.clearSchemas()
                    }
                    .foregroundStyle(.kokowaPeriwinkle)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        viewModel.isSchemaSelectionPresented = false
                        viewModel.showSchemaSelectionCompletedAlert()
                    }
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.kokowaTeal)
                }
            }
        }
        .presentationDetents([.large])
    }

    /// スキーマカテゴリ内の選択肢を表示する。
    @ViewBuilder
    private func schemaCategoryView(_ category: EarlyMaladaptiveSchemaCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(category.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)

                Text(category.description)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 8) {
                ForEach(category.schemas) { schema in
                    schemaOptionButtonView(schema)
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// スキーマを選択または解除するボタンを表示する。
    @ViewBuilder
    private func schemaOptionButtonView(_ schema: EarlyMaladaptiveSchemaItem) -> some View {
        let isSelected = viewModel.isSchemaSelected(schema)

        Button {
            viewModel.toggleSchema(schema)
        } label: {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(schema.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(isSelected ? .white : .primaryTextBlack)

                    Text(schema.description)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(isSelected ? .white.opacity(0.86) : .secondaryTextGray)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(isSelected ? .white : .secondaryTextGray.opacity(0.45))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.kokowaPeriwinkle : Color.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
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
        EmptyView().kokowaBottomReturnButton(
            title: viewModel.returnButtonTitle,
            iconName: viewModel.returnButtonIconName
        ) {
            dismiss()
        }
    }
}
