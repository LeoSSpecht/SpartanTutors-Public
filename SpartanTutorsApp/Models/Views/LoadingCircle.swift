//
//  LoadingCircle.swift
//  SpartanTutors
//
//  Created by Leo on 7/9/22.
//

import SwiftUI

struct LoadingCircle: View {
    @State var animationAmount = 1.0
    var maxAnimation = 2.0
    
    var body: some View {
        ZStack{
            Circle()
                .foregroundColor(Color(red: 0.11, green: 0.34, blue: 0.17))
                .overlay(
                    Circle()
                        .stroke(Color.green)
                        .scaleEffect(CGFloat(animationAmount))
                        .opacity(maxAnimation-animationAmount)
                        .animation(.easeInOut(duration: 1)
                                    .repeatForever(autoreverses: false),
                                   value: animationAmount)

                )
                .onAppear{
                    animationAmount = maxAnimation
                }
            Text("Loading...")
                .foregroundColor(.white)
                .fontWeight(.bold)
        }.padding(130)
    }
}

