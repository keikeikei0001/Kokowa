//
//  NumberHelper.swift
//  Kokowa
//
//  Created by Codex on 2026/07/02.
//

import Foundation

enum NumberHelper {
    /// Doubleを四捨五入して、指定した最小値以上のIntに変換する。
    static func roundedInt(_ value: Double, minimum: Int = 1) -> Int {
        max(minimum, Int(value.rounded()))
    }

    /// 指定したステップに合わせてDoubleを丸める。
    static func rounded(_ value: Double, step: Double) -> Double {
        guard step > 0 else { return value }
        return (value / step).rounded() * step
    }
}
