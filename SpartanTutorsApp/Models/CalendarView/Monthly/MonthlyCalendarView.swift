//
//  MonthlyCalendarView.swift
//  AnimationTest
//
//  Created by Leo on 8/19/22.
//

import Foundation
import SwiftUI

struct MonthlyCalendar: View {
    @ObservedObject var calendarViewModel: MonthlyCalendarVM
    static let size:CGFloat = 45
    static let column = GridItem(.fixed(size), spacing: 0)
    let columns = [
        column,
        column,
        column,
        column,
        column,
        column,
        column
    ]
    
    let days = [
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat",
    ]
    
    var body: some View {
        VStack{
            Text(calendarViewModel.month_selected)
                .fontWeight(.bold)
                .animation(nil)
            
            HStack(alignment: .top, spacing: 10){
                Image(systemName: "chevron.left")
                    .imageScale(.small)
                    .opacity(calendarViewModel.is_there_previous_month ? 1 : 0)
                    .onTapGesture {
                        withAnimation{
                            calendarViewModel.change_month(-1)
                        }
                    }

                VStack(spacing: 0){
                        LazyVGrid(columns:columns){
                            ForEach(0...6, id: \.self){d in
                                Text("\(days[d%7])")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .animation(nil)
                    
                    TabView(selection: $calendarViewModel.month_index){
                        ForEach(0..<calendarViewModel.max_months, id:\.self){ month_index in
                            LazyVGrid(columns:columns, spacing: 0){
                                let key = calendarViewModel.month_key(month_index)
                                ForEach(
                                    (0..<calendarViewModel.days_list[key]!.count),
                                    id: \.self)
                                { i in
                                        let day = calendarViewModel.days_list[key]![i]
                                        if day.value == 0{
                                            dayView(day: "0",
                                                    isValid: day.isValid,
                                                    isSelected: day.isSelected,
                                                    is_availability_possible: false)
                                        }
                                        else{
                                            dayView(day: day.day_number,
                                                    isValid: day.isValid,
                                                    isSelected: day.isSelected,
                                                    is_availability_possible: false)
                                                .onTapGesture{
                                                    if day.isValid{
                                                        calendarViewModel.choose(day.index)
                                                    }
                                                }
                                        }
                                }
                            }
                            .tag(month_index)
                        }
                    }
                    .frame(maxWidth: 315)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .frame(maxHeight: 305)
                
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .opacity(calendarViewModel.is_there_next_month ? 1 : 0)
                    .onTapGesture {
                        withAnimation{
                            calendarViewModel.change_month(1)
                        }
                    }
                
            }
            .animation(.easeIn(duration: 0.5), value: calendarViewModel.month_index)
        }
    }
}


struct MonthlyPreview: PreviewProvider {
    static var previews: some View {
        var viewModel = MonthlyCalendarVM()
        MonthlyCalendar(calendarViewModel: viewModel)
    }
}
