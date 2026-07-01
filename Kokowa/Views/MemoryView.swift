//
//  MemoryView.swift
//  Kokowa
//
//  Created by Codex on 2026/07/01.
//

import SwiftUI
import SwiftData

struct MemoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = MemoryViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            KokowaBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    headerView()
                    inputCardView()
                    reviewCardView()
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

            Text("ネガティブ日記")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(.primaryTextBlack)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text("心に残った出来事を、静かに見返す")
                .font(.title3.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
        }
    }

    /// ネガティブな出来事を追加する入力カードを表示する。
    @ViewBuilder
    private func inputCardView() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            cardTitleView(
                icon: "heart.text.square.fill",
                title: "ネガティブな感情を感じた出来事",
                color: .kokowaRose
            )

            titleFieldView()
            periodPickerView()
            peopleInputView()
            addEntryButtonView()
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

            Menu {
                ForEach(viewModel.periodOptions) { period in
                    Button(period.title) {
                        viewModel.selectedPeriod = period
                    }
                }
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

    /// 記憶記録を追加するボタンを表示する。
    @ViewBuilder
    private func addEntryButtonView() -> some View {
        Button {
            viewModel.addEntry()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3.weight(.bold))
                Text("追加")
                    .font(.title3.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.addButtonColor, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isAddButtonDisabled)
    }

    /// 記録済みの出来事を見返すカードを表示する。
    @ViewBuilder
    private func reviewCardView() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("見返し")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)

                Spacer()

                Text(viewModel.entryCountText)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.64), in: Capsule())
            }

            reviewFilterView()

            if viewModel.filteredEntries.isEmpty {
                emptyReviewView()
            } else {
                memoryListView()
            }
        }
        .padding(18)
        .kokowaCard(cornerRadius: 22)
    }

    /// 見返しの検索条件を表示する。
    @ViewBuilder
    private func reviewFilterView() -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                filterMenuView(
                    icon: "person.2.fill",
                    title: "相手",
                    value: viewModel.selectedPersonFilterText,
                    color: .kokowaPeriwinkle
                ) {
                    Button("すべて") {
                        viewModel.selectPersonFilter(nil)
                    }

                    ForEach(viewModel.personFilterOptions, id: \.self) { person in
                        Button(person) {
                            viewModel.selectPersonFilter(person)
                        }
                    }
                }

                filterMenuView(
                    icon: "clock.arrow.circlepath",
                    title: "時期",
                    value: viewModel.selectedPeriodFilterText,
                    color: .kokowaRose
                ) {
                    Button("すべて") {
                        viewModel.selectPeriodFilter(nil)
                    }

                    ForEach(viewModel.periodOptions) { period in
                        Button(period.title) {
                            viewModel.selectPeriodFilter(period)
                        }
                    }
                }
            }

            filterMenuView(
                icon: "checkmark.seal.fill",
                title: "内観",
                value: viewModel.selectedIntrospectionStatusFilterText,
                color: .kokowaTeal
            ) {
                Button("すべて") {
                    viewModel.selectIntrospectionStatusFilter(nil)
                }

                ForEach(viewModel.introspectionStatusOptions) { status in
                    Button(status.title) {
                        viewModel.selectIntrospectionStatusFilter(status)
                    }
                }
            }
        }
    }

    /// 見返し検索の選択メニューを表示する。
    @ViewBuilder
    private func filterMenuView<Content: View>(
        icon: String,
        title: String,
        value: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Menu {
            content()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.14), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondaryTextGray)

                    Text(value)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primaryTextBlack)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    /// 記憶記録がない時の表示を作る。
    @ViewBuilder
    private func emptyReviewView() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.kokowaRose)

            Text("まだ書き出しはありません")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primaryTextBlack)

            Text("追加すると、ここに表示されます")
                .font(.headline.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color.white.opacity(0.56), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// 記憶記録の一覧を表示する。
    @ViewBuilder
    private func memoryListView() -> some View {
        VStack(spacing: 10) {
            ForEach(viewModel.filteredEntries) { entry in
                memoryRowView(entry)
            }
        }
    }

    /// 記憶記録の1行を表示する。
    @ViewBuilder
    private func memoryRowView(_ entry: MemoryEntry) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(.kokowaRose)
                .frame(width: 10, height: 10)
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        FlowLayout(spacing: 6) {
                            memoryTagView(text: entry.period.title, color: .kokowaRose)
                            memoryTagView(text: viewModel.introspectionStatusText(entry), color: .kokowaTeal)

                            ForEach(viewModel.peopleTags(entry), id: \.self) { person in
                                memoryTagView(text: person, color: .kokowaPeriwinkle)
                            }
                        }

                        Text(entry.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primaryTextBlack)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(viewModel.entryDateText(entry))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondaryTextGray)
                    }

                    Spacer(minLength: 10)

                    Button {
                        viewModel.deleteEntry(entry)
                    } label: {
                        Image(systemName: "trash")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.secondaryTextGray)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.62), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    /// 記憶記録の補助タグを表示する。
    @ViewBuilder
    private func memoryTagView(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(color.opacity(0.12), in: Capsule())
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
