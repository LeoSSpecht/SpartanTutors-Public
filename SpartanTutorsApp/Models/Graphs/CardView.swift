//
//  CardView.swift
//  AnimationTest
//
//  Created by Leo on 8/16/22.
//

import SwiftUI

struct CardView: View {
    var size: CGSize
    var text: String
    var number: Double
    var format: number_formats = .none
    
    var formatted_number: String{
        switch format {
        case .money:
            return String(format: "$ %.2f", number)
        default:
            return "\(Int(round(number)))"
        }
    }
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 2)
                .shadow(radius: 2)
            VStack{
                Text(formatted_number)
                    .font(.title)
                    .bold()
                    .padding(.bottom, 1)
                Text(text)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal,5)
            }
            
        }
        .frame(maxWidth: size.width, maxHeight: size.height)
        
    }
}

enum number_formats{
    case none
    case money
}
