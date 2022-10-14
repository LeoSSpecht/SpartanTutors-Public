//
//  SwiftUIView.swift
//  AnimationTest
//
//  Created by Leo on 8/16/22.
//

import SwiftUI

struct BarGraph: View {
    var data_points: Array<DataPoint>
    var color: Color
    var title: String? = nil
    
    @Namespace var graph_bars
    var max_value: Double{
        var temp = -Double.infinity
        for i in self.data_points{
            if i.y > temp{
                temp = i.y
            }
        }
        return temp
    }
    
    var count: Int{
        data_points.count
    }
    func normalizedValue(value: Double) -> Double {
        if max_value == 0{
            return 0
        }
        return value/max_value
    }
    
    var body: some View {
        let width: CGFloat = 0.7
        VStack{
            if title != nil{
                Text(title!)
                    .font(.headline)
                    .bold()
                    .padding()
            }
            GeometryReader{geometry in
                let bar_width = (geometry.size.width / CGFloat(count))*width
                HStack(alignment: .bottom, spacing: 0){
                    ForEach(data_points.indices, id: \.self){ i in
                        BarChartCell(
                            normalized_value: normalizedValue(value: data_points[i].y),
                            value: data_points[i].y,
                            max_height: geometry.size.height,
                            barColor: color,
                            width: bar_width
                        )
                        .frame(width:(geometry.size.width / CGFloat(count)), alignment: .center)
                        .matchedGeometryEffect(id: i, in: graph_bars)
                        .animation(.easeInOut, value: data_points)
                        
                    }
                }
                
                
            }
        }
        
    }
}

struct BarChartCell: View {
    var normalized_value: Double
    var value: Double
    var max_height: CGFloat
    var barColor: Color
    var width: CGFloat? = nil
    
    var height: CGFloat{
        max_height * CGFloat(0.93) * CGFloat(normalized_value)
    }
    
    var body: some View {
    
        VStack(alignment:.center,spacing: 0){
            Spacer()
            RoundedRectangle(cornerRadius: 5)
                .fill(barColor)
                .frame(width: width != nil ? width : .greatestFiniteMagnitude, height: height)
        }
        .overlay(
            Text("\(Int(floor(value)))")
                    .padding(.bottom,5)
                    .font(.caption)
                .offset(y: -height)
            ,alignment: .bottom
        )
        .frame(maxHeight: max_height)
        
    }
}

struct DataPoint: Identifiable, Equatable{
    var id = UUID()
    var x: String
    var y: Double
}


