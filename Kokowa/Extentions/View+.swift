//
//  View+.swift
//  SampleAlert
//
//  Created by RikutoSato on 2024/11/29.
//

import SwiftUI

extension View {
    @ViewBuilder
    func alert(_ context: Binding<AlertContext?>) -> some View {
        let isPresented = Binding<Bool> {
            context.wrappedValue != nil
        } set: { isPresented in
            if isPresented == false {
                context.wrappedValue = nil
            }
        }
        
        if let context = context.wrappedValue {
            alert(context.title, isPresented: isPresented) {
                ForEach(Array(context.actions.enumerated()), id: \.self.element.id) { _, action in
                    Button(action.title, role: action.role) {
                        action.action(action)
                    }
                }
            } message: {
                Text(context.message)
            }
        } else {
            self
        }
    }
    
    @ViewBuilder
    func alertDatePicker(isPresented: Binding<Bool>, selectedDate: Binding<Date?>) -> some View {
        self.overlay(
            isPresented.wrappedValue ? AlertDataPickerWrapper(
                isPresented: isPresented,
                selectedDate: selectedDate
            ) : nil
        )
    }
    
    @ViewBuilder
    func gradientBackgroundColor(
        _ colorTop: Color,
        _ colorBottom: Color
    ) -> some View {
        self.background(
            LinearGradient(
                colors: [colorTop, colorBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

extension View {
    func kokowaCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(KokowaCard(cornerRadius: cornerRadius))
    }

    func hideKeyboardOnTap() -> some View {
        onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
    
    @ViewBuilder
    func KokowaBackground() -> some View {
            LinearGradient(
                colors: [
                    Color(red: 0.90, green: 0.97, blue: 0.95),
                    Color(red: 0.99, green: 0.97, blue: 0.91),
                    Color(red: 0.94, green: 0.98, blue: 0.97)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
}


