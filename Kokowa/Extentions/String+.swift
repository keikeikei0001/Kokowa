//
//  Locale+.swift
//  habitApp
//
//  Created by RikutoSato on 2024/10/30.
//

import Foundation

extension String {
    /// 入力テキストの文字数制限処理
    func limitCharactersInputText(_ inputText: String, maxLength: Int) -> String {
        return inputText.count > maxLength ? String(inputText.prefix(maxLength)) : inputText
    }
}
