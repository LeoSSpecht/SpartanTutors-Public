//
//  ScheduleSummaryRow.swift
//  Tests (iOS)
//
//  Created by Leo on 9/4/22.
//

import SwiftUI

struct ScheduleSummaryRow: View {
    var values: [Int]
    var subtitles = ["8 AM","10 AM" ,"12 PM" , "2 PM", "04 PM", "6 PM", "8 PM","10 PM"]
    
    var size: thickness = .thin
    var show_times = false
    
    var colors: [Int: Color] = [
        0: .red,
        1: .green,
        2: .blue
    ]
    
    var opacity = 0.7
    
    var count: Int{
        values.count
    }
    
    var legend_space: Int{
        count/(subtitles.count-1)-1
    }
    
    var body: some View {
        VStack(spacing:3){
            
            if show_times{
                HStack(spacing: 0){
                    ForEach(self.values.indices, id: \.self){i in
                        if i%legend_space == 0{
                            let subtitle_ind = i/legend_space
                            let offset = subtitle_ind == 0 || subtitle_ind == subtitles.count-1 ? 0 : ((-subtitles.count/2 + subtitle_ind)*3)
    
                            Text(subtitles[subtitle_ind])
//                                .font(.caption2)
                                .font(.system(size: 10))
                                .offset(x: CGFloat(offset))
                            
                            if subtitle_ind != subtitles.count-1{
                                Spacer()
                            }
                        }
                        
                    }
                }
            }
            
            HStack(spacing:0){
                ForEach(values.indices, id: \.self){i in
                    Rectangle()
                        .foregroundColor(colors[values[i]])
                        .opacity(opacity)
                    if (i+1) % 4 == 0 && i != values.count-1{
                        Divider()
                            .frame(width: 1)
                            .background(Color.black)
                            
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .frame(maxHeight: self.size.rawValue)
        }
    }
    
    enum thickness: CGFloat{
        case thin = 8
        case thick = 40
    }
}
