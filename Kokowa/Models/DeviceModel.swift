//
//  DeviceModel.swift
//  habitApp
//
//  Created by 松田圭右 on 2024/04/08.
//

import SwiftUI

class DeviceModel {
    /// 現在接続されている画面シーンを返す。
    private static var window: UIWindowScene? {
        return UIApplication.shared.connectedScenes.first as? UIWindowScene
    }
    
    /// 端末画面のサイズ情報を返す。
    static var screenSize: CGRect {
        return window?.screen.bounds ?? CGRect.zero
    }
    
    /// 端末画面の横幅を返す。
    static var width: CGFloat {
        return screenSize.width
    }
    
    /// 端末画面の高さを返す。
    static var height: CGFloat {
        return screenSize.height
    }
}
