//
//  RecordView.swift
//  Kokowa
//
//  Created by けいけい on 2026/06/30.
//

import SwiftUI
import SwiftData

struct RecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = RecordViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            KokowaBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    headerView()
                    weeklySummaryCardView()
                    calendarCardView()
                }
                .padding(.horizontal, 22)
                .padding(.top, 72)
                .padding(.bottom, 104)
            }
            
            returnButtonView()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.configure(modelContext: modelContext, userId: authManager.userId)
        }
    }
    
    /// 日付・画面タイトル・補足文を表示するヘッダー。
    @ViewBuilder
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.todayText)
                .font(.headline.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
            
            Text("記録")
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .foregroundStyle(.primaryTextBlack)
            
            Text("残してきた日々を、静かに見返す")
                .font(.title3.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
        }
    }
    
    /// 直近1週間のメンタル・睡眠・体調・ストレスを表示するカード。
    @ViewBuilder
    private func weeklySummaryCardView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("7日間の平均")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.secondaryTextGray)
                    HStack(spacing: 30) {
                        Text("メンタル")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.secondaryTextGray)
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text(viewModel.weeklyMentalText)
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundStyle(.primaryTextBlack)
                            
                            Text("点")
                                .font(.title.weight(.bold))
                                .foregroundStyle(.secondaryTextGray)
                        }
                    }
                }
            }
            
            HStack(spacing: 10) {
                summaryMiniCard(
                    icon: "moon.fill",
                    value: viewModel.weeklySleepText,
                    label: "睡眠時間",
                    color: .kokowaPeriwinkle
                )
                
                summaryMiniCard(
                    icon: "sun.max.fill",
                    value: viewModel.weeklyConditionText,
                    label: "体調",
                    color: .kokowaTeal
                )
                
                summaryMiniCard(
                    icon: "waveform.path.ecg",
                    value: viewModel.weeklyStressText,
                    label: "ストレス",
                    color: .kokowaRose
                )
            }
        }
        .padding(20)
        .kokowaCard(cornerRadius: 24)
    }
    
    /// サマリーカード内の小さな情報カードを表示する。
    @ViewBuilder
    private func summaryMiniCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.14), in: Circle())
            
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primaryTextBlack)
                .lineLimit(1)
                .minimumScaleFactor(0.64)
            
            Text(label)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    /// 月間カレンダーと選択日の詳細を表示するカード。
    @ViewBuilder
    private func calendarCardView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text("カレンダー")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                
                HStack {
                    Spacer()
                    monthSelectorView()
                    Spacer()
                }
            }
            
            weekdayHeaderView()
            calendarGridView()
            selectedDateDetailCardView()
        }
        .padding(16)
        .kokowaCard(cornerRadius: 22)
    }
    
    /// 表示月を切り替える操作部を表示する。
    @ViewBuilder
    private func monthSelectorView() -> some View {
        HStack(spacing: 14) {
            Button(action: viewModel.showPreviousMonth) {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
            }
            
            Text(viewModel.displayedMonthText)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primaryTextBlack)
                .frame(minWidth: 112)
            
            Button(action: viewModel.showNextMonth) {
                Image(systemName: "chevron.right")
                    .font(.headline.weight(.bold))
            }
        }
        .foregroundStyle(.kokowaTerracotta)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.58), in: Capsule())
    }
    
    /// 曜日の見出しを表示する。
    @ViewBuilder
    private func weekdayHeaderView() -> some View {
        LazyVGrid(columns: viewModel.calendarColumns, spacing: 0) {
            ForEach(viewModel.weekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    /// 月間カレンダーのグリッドを表示する。
    @ViewBuilder
    private func calendarGridView() -> some View {
        LazyVGrid(columns: viewModel.calendarColumns, spacing: 6) {
            ForEach(viewModel.calendarDays()) { day in
                calendarDayCell(day)
            }
        }
    }
    
    /// カレンダー内の1日分のセルを表示する。
    @ViewBuilder
    private func calendarDayCell(_ day: RecordCalendarDay) -> some View {
        if let date = day.date {
            Button {
                viewModel.selectDate(date)
            } label: {
                VStack(spacing: 2) {
                    Text(viewModel.dayNumberText(date))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(viewModel.isSelectedDate(date) ? .white.opacity(0.78) : .secondaryTextGray)
                    
                    Text(viewModel.mentalText(for: day.entry))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(viewModel.isSelectedDate(date) ? .white : .primaryTextBlack)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(
                    viewModel.isSelectedDate(date)
                    ? Color.kokowaTerracotta
                    : calendarDayBackgroundColor(hasEntry: day.entry != nil),
                    in: RoundedRectangle(cornerRadius: 13, style: .continuous)
                )
            }
            .buttonStyle(.plain)
        } else {
            Color.clear
                .frame(height: 46)
        }
    }
    
    /// 選択日の詳細カードを表示する。
    @ViewBuilder
    private func selectedDateDetailCardView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.selectedDateText)
                .font(.headline.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
            
            if viewModel.hasSelectedEntry {
                LazyVGrid(columns: viewModel.detailColumns, spacing: 8) {
                    detailMetricView(icon: "heart.fill", value: viewModel.selectedMentalText, label: "メンタル", color: .kokowaRose)
                    detailMetricView(icon: "moon.fill", value: viewModel.selectedSleepText, label: "睡眠", color: .kokowaPeriwinkle)
                    detailMetricView(icon: "sun.max.fill", value: viewModel.selectedConditionText, label: "体調", color: .kokowaTeal)
                    detailMetricView(icon: "waveform.path.ecg", value: viewModel.selectedStressText, label: "ストレス", color: .kokowaRose)
                }

                selectedGratitudeView()
                selectedMemoView()
            } else {
                Text("この日の記録はまだありません")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.secondaryTextGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white.opacity(0.56), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.54), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// 選択日の感謝リストを表示する。
    @ViewBuilder
    private func selectedGratitudeView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            detailSectionTitleView(icon: "hands.sparkles.fill", title: "感謝", color: .kokowaTerracotta)

            if viewModel.hasSelectedGratitude {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(viewModel.selectedGratitudeTexts.enumerated()), id: \.offset) { index, gratitude in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.kokowaTerracotta)
                                .frame(width: 24, height: 24)
                                .background(.kokowaTerracotta.opacity(0.12), in: Circle())

                            Text(gratitude)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.primaryTextBlack)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            } else {
                emptyDetailTextView("感謝はまだありません")
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// 選択日のメモを表示する。
    @ViewBuilder
    private func selectedMemoView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            detailSectionTitleView(icon: "text.bubble.fill", title: "メモ", color: .kokowaTeal)

            if viewModel.hasSelectedMemo {
                Text(viewModel.selectedMemoText)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primaryTextBlack)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                emptyDetailTextView("メモはまだありません")
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// 詳細欄の見出しを表示する。
    @ViewBuilder
    private func detailSectionTitleView(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.footnote.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 26, height: 26)
                .background(color.opacity(0.14), in: Circle())

            Text(title)
                .font(.footnote.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
        }
    }

    /// 詳細欄に表示する空状態テキストを返す。
    @ViewBuilder
    private func emptyDetailTextView(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.secondaryTextGray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// 選択日詳細の1項目を表示する。
    @ViewBuilder
    private func detailMetricView(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.14), in: Circle())
            
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primaryTextBlack)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            
            Text(label)
                .font(.footnote.weight(.bold))
                .foregroundStyle(.secondaryTextGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    /// 日付セルの背景色を返す。
    private func calendarDayBackgroundColor(hasEntry: Bool) -> Color {
        hasEntry ? .kokowaTerracotta.opacity(0.22) : Color.white.opacity(0.46)
    }
    
    /// ホーム画面へ戻るためのボタンを表示する。
    @ViewBuilder
    private func returnButtonView() -> some View {
        EmptyView().kokowaBottomReturnButton {
            dismiss()
        }
    }
}
