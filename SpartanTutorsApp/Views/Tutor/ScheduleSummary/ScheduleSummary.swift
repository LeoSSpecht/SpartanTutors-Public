//
//  ScheduleSummary.swift
//  SpartanTutors
//
//  Created by Leo on 9/5/22.
//

import SwiftUI
struct ScheduleSummary: View {
    @EnvironmentObject var UpdateScheduleViewModel:scheduleUpdateViewModel
    @StateObject var calendarViewModel = calendarVM()
    
    var space: some View{
        Spacer().frame(width: 50)
    }

    
    var body: some View {
        
        
        VStack{
            Header_end()
            VStack{
                Text("Schedule summary")
                    .font(.title3)
                    .bold()
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
                ScrollView{
                    ForEach(calendarViewModel.all_days, id: \.self){ day in
                        HStack{
                            Text(day.date.format("MMM dd"))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(7)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(day.isSelected ? Color.blue : Color.white, lineWidth: 2)
                                )

                            
                            
                            ScheduleSummaryRow(
                                values: UpdateScheduleViewModel.model.schedule[day.date.to_int_format()]?.data ?? Array(repeating: 0, count: TimeConstants.times_in_day),
                                size: .thick,
                                show_times: true)
                            .frame(minHeight: 50)
                        }
                        .padding(.horizontal)
                        .padding(.vertical,5)
                    }
                    
                }
                
                
            }
            Rectangle()
                .frame(maxHeight: 1)
                .foregroundColor(.white)
        }
    }
}
