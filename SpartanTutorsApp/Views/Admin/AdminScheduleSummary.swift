//
//  ScheduleSummary.swift
//  SpartanTutors
//
//  Created by Leo on 9/5/22.
//

import SwiftUI
struct AdminScheduleSummary: View {
    @EnvironmentObject var ScheduleViewModel:AdminAllSessions
    @StateObject var calendarViewModel = calendarVM()
    
    var space: some View{
        Spacer().frame(width: 50)
    }
    
    var body: some View {
        VStack{
//            Header_end()
            VStack{
                Text("Schedule summary")
                    .font(.title3)
                    .bold()
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
                Menu{
                    Button("All classes"){
                        ScheduleViewModel.select_tutor(selected_class: "All classes", tutor: "Any")
                    }
                    ForEach(
                        ScheduleViewModel.schedule_for_tutor.keys.sorted(by: {$0 < $1}),
                        id: \.self
                    ) { class_group in
                        Menu(class_group){
                            ForEach(
                                ScheduleViewModel.schedule_for_tutor[class_group]!.keys.sorted(by: {$0 < $1}).sorted(by: {i1,i2 in i1 == "Any"}),
                                id: \.self){ person in
                                Button("\(person)"){
                                    ScheduleViewModel.select_tutor(selected_class: class_group, tutor: person)
                                }
                            }
                        }
                    }
                }label: {
                    picker_label(selection: self.ScheduleViewModel.selected_item)
                }
                
                ScheduleSummaryRows(schedule: ScheduleViewModel.tutor_schedule_model)
                Rectangle()
                    .frame(maxHeight: 1)
                    .foregroundColor(.white)
            }
        }
    }
}

struct ScheduleSummaryRows: View{
    var schedule: TutorScheduleModel
    @StateObject var calendarViewModel = calendarVM()
    
    var body: some View{
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
                        values:
                            schedule.schedule[day.date.to_int_format()]?.data ?? Array(repeating: 0, count: TimeConstants.times_in_day),
                        size: .thick,
                        show_times: true)
                    .frame(minHeight: 50)
                }
                .padding(.horizontal)
                .padding(.vertical,5)
            }
            
        }
    }
}
