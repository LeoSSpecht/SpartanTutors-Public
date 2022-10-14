//
//  Tile.swift
//  SpartanTutors
//
//  Created by Leo on 9/19/22.
//

import SwiftUI

struct Tile: View{
    var symbol: String
    var text: String
    var aspect: CGFloat = 1
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .shadow(radius: 3)
                .foregroundColor(.white)
            VStack{
                Image(systemName: symbol)
                Text(text)
                    
            }
            .foregroundColor(.black)
            
        }
        .aspectRatio(aspect,contentMode: .fit)
    }
}
