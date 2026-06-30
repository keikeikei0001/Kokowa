//
//  AlertDataPicker.swift
//  LifeIsRpg
//
//  Created by けいけい on 2024/12/07.
//

import SwiftUI

struct AlertDataPickerWrapper: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date?

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard isPresented, uiViewController.presentedViewController == nil else { return }

        let alertController = UIAlertController(title: "時間を選択", message: "\n\n\n\n\n\n\n", preferredStyle: .alert)

        // UIDatePicker を作成
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.frame = CGRect(x: 10, y: 50, width: 250, height: 138)
        alertController.view.addSubview(datePicker)

        // OK ボタン
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            selectedDate = datePicker.date
            isPresented = false
        }
        alertController.addAction(okAction)

        // キャンセルボタン
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            isPresented = false
        }
        alertController.addAction(cancelAction)

        DispatchQueue.main.async {
            uiViewController.present(alertController, animated: true, completion: nil)
        }
    }
}
