//
//  View+.swift
//  Bottles_V2
//
//  Created by BOMBSGIE on 2023/01/30.
//

import Foundation
import SwiftUI

extension View {
    func shakeEffect(trigger: Bool) -> some View {
        modifier(ShakeEffect(trigger: trigger))
    }
    /// 최상단 Stack에서 .customAlert으로 CustomAlert을 띄울 수 있습니다.
    func customAlert(
        isPresented: Binding<Bool>,
        message: String,
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void,
        withCancelButton: Bool) -> some View
    {
        modifier(CustomAlertModifier(
            isPresented: isPresented,
            message: message,
            primaryButtonTitle: primaryButtonTitle,
            primaryAction: primaryAction,
            withCancelButton: withCancelButton
        ))
    }
    
    /// title이 포함된 .customAlert입니다.
    func cartCustomAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void,
        withCancelButton: Bool) -> some View
    {
        modifier(CartCustomAlertModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            primaryButtonTitle: primaryButtonTitle,
            primaryAction: primaryAction,
            withCancelButton: withCancelButton
        ))
    }
    
    /// SkeletonUI .setSkeletonView
    func setSkeletonView(opacity: Double, shouldShow: Bool) -> some View {
        self.modifier(BlinkingAnimatinoModifier(shouldShow: shouldShow, opacity: opacity))
    }
    
}

// MARK: - 빈 공간 터치로 키보드를 내리기 위한 View Extension
/// 필요한 View에서 onTapGesture를 통해 사용
extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil
        )
    }
}
