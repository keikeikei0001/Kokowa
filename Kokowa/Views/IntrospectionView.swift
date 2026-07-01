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
    @State private var isEmotionSelectionPresented = false
    
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
        .sheet(isPresented: $isEmotionSelectionPresented) {
            emotionSelectionSheetView()
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
                text: $viewModel.eventDetailText,
                shouldShowPlaceholder: viewModel.shouldShowEventDetailPlaceholder
            )
            
            emotionSelectionFieldView()
            
            introspectionTextAreaView(
                icon: "figure.mind.and.body",
                title: "身体反応",
                placeholder: "胸が苦しい、涙が出る、力が抜けるなど",
                color: .kokowaPeriwinkle,
                text: $viewModel.bodyReactionText,
                shouldShowPlaceholder: viewModel.shouldShowBodyReactionPlaceholder
            )
            
            introspectionTextAreaView(
                icon: "brain.head.profile",
                title: "思考",
                placeholder: "その時に頭に浮かんだ言葉を書く",
                color: .kokowaTeal,
                text: $viewModel.thoughtText,
                shouldShowPlaceholder: viewModel.shouldShowThoughtPlaceholder
            )
            
            introspectionTextAreaView(
                icon: "hand.raised.fill",
                title: "どうして欲しかったのか？",
                placeholder: "相手や周りにして欲しかったことを書く",
                color: .kokowaTerracotta,
                text: $viewModel.desiredResponseText,
                shouldShowPlaceholder: viewModel.shouldShowDesiredResponsePlaceholder
            )
            
            introspectionTextAreaView(
                icon: "figure.walk.motion",
                title: "どうしたかったのか？",
                placeholder: "本当は自分がどう動きたかったのかを書く",
                color: .kokowaTeal,
                text: $viewModel.desiredActionText,
                shouldShowPlaceholder: viewModel.shouldShowDesiredActionPlaceholder
            )
        }
        .padding(18)
        .kokowaCard(cornerRadius: 22)
    }
    
    /// 感情・気持ちを選ぶ入力欄を表示する。
    @ViewBuilder
    private func emotionSelectionFieldView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            compactSectionTitleView(icon: "heart.fill", title: "感情・気持ち", color: .kokowaRose)
            
            Button {
                isEmotionSelectionPresented = true
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
    
    /// 内観の分解項目を入力する複数行欄を表示する。
    @ViewBuilder
    private func introspectionTextAreaView(
        icon: String,
        title: String,
        note: String? = nil,
        placeholder: String,
        color: Color,
        text: Binding<String>,
        shouldShowPlaceholder: Bool
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
                .frame(minHeight: 92)
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
    
    /// 感情・気持ちの選択シートを表示する。
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
            .navigationTitle("感情・気持ち")
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
                        isEmotionSelectionPresented = false
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
                Image(systemName: viewModel.returnButtonIconName)
                    .font(.title3).bold()
                Text(viewModel.returnButtonTitle)
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
