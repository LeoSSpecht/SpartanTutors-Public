//
//  ConfirmationPopUp.swift
//  SpartanTutors
//
//  Created by Leo on 7/31/22.
//

import SwiftUI

struct confirmation_pop_up: View{
    var show: Bool
    @Binding var loading: Bool
    var text: String
    var work_action: ()->Void
    var dismiss: () -> Void
    var aspect:CGFloat = 2.5
    
    var body: some View{
        if show{
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.white)
                VStack(alignment: .center, spacing: 10){
                    HStack{
                        
                        Text(loading ? "Loading..." : text)
//                        .multilineTextAlignment(.center)
//                        .lineLimit(2)
                        
                    }
                    HStack(spacing: 40){
                        Button(action: {dismiss()}){
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        Button(action: {
                            work_action()
                        })
                        {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .disabled(loading)
                    .imageScale(.large)
                }
                .padding()
            }
            .aspectRatio(aspect,contentMode: .fit)
            .animation(.easeOut(duration: 0.25))
            .transition(.move(edge: .trailing))
        }
    }
}

struct Confirm_pop_up: ViewModifier {
    var text: String
    var confirm: Bool
    @Binding var loading: Bool
    var action: () -> Void
    var dismiss: () -> Void
    func body(content: Content) -> some View {
        content
            .overlay(confirmation_pop_up(show: confirm, loading: $loading, text: text, work_action: action, dismiss: dismiss),alignment: .trailing)
    }
}

extension View {
    func confirm_pop_up(with text: String, show: Bool, loading: Binding<Bool>, action: @escaping () -> Void, dismiss: @escaping () -> Void) -> some View {
        modifier(Confirm_pop_up(text: text, confirm: show, loading: loading, action: action, dismiss: dismiss))
    }
}
