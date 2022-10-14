//
//  updateScheduleView.swift
//  SpartanTutors
//
//  Created by Leo on 6/30/22.
//

import SwiftUI
import PopupView
struct updateScheduleView: View {
    @EnvironmentObject var UpdateScheduleViewModel:scheduleUpdateViewModel
    @StateObject var calendarViewModel = calendarVM()
    @State var show_copy_schedule = false
    @State var rotation = false
    
    var space: some View{
        Spacer().frame(width: 50)
    }
    var body: some View {
        
        
        VStack{
            Header_end()
            VStack(spacing:0){
                Text("Please select your schedule")
                    .font(.title3)
                    .bold()
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
                CalendarView(calendarViewModel: calendarViewModel,selected_date: $UpdateScheduleViewModel.date, weekly_schedule: $UpdateScheduleViewModel.session_week)
                
                
                
                ScrollView{
                        ForEach(UpdateScheduleViewModel.schedule!.data.indices){ ind in
                            HStack{
                                space
                                ZStack{
                                    RoundedRectangle(cornerRadius:3)
                                        .stroke(lineWidth: 3)
                                        .fill(getColor(value: UpdateScheduleViewModel.schedule!.data[ind]))
                                        .foregroundColor(.white)
                                    Text("\(Timeframe.get_time_from_frame(ind: ind)) - \(Timeframe.get_time_from_frame(ind: ind+1))")
                                }.aspectRatio(contentMode: .fit)
                                space
                                    
                            }
                            .onTapGesture {
                                UpdateScheduleViewModel.selectTime(ind: ind)
                            }
                        }
                        .padding(.vertical)
                    
                }
                
                ScheduleSummaryRow(values: UpdateScheduleViewModel.schedule!.data, show_times: true)
                    .padding(.horizontal,10)
                    .padding(.vertical,5)
                    .animation(.easeInOut(duration: 0.2), value: UpdateScheduleViewModel.schedule!.data)
                
                HStack(spacing:5){
                    Menu(content: {
                        Button(action: {show_copy_schedule.toggle()}){
                            Text("Copy selected schedule")
                        }
                        
                        Button(action: {UpdateScheduleViewModel.select_four.toggle()}){
                            HStack{
                                Text("Select schedule hourly")
                                    .fontWeight(.semibold)
                                    
                                Spacer()
                                if UpdateScheduleViewModel.select_four{
                                    Image(systemName:  "checkmark.circle.fill")
                                        
                                }
                            }
                            
                        }
                        Button(action: UpdateScheduleViewModel.full_schedule){
                            Text("Full")
                        }
                        Button(action: UpdateScheduleViewModel.clear_schedule){
                            Text("Clear")
                        }
                        
                    }, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.gray)
                            Image(systemName: "gear")
                                .imageScale(.large)
                                .foregroundColor(.white)
                                .rotationEffect(rotation ? .degrees(60) : .degrees(0))
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 50)
                        
                        
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        rotation.toggle()
                    })
                    
                    Button(action: {
                        UpdateScheduleViewModel.try_to_update_schedule()
                    }) {
                      Text("Update times")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemIndigo))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
            }
            .sheet(isPresented: $show_copy_schedule){
                UpdateAllSchedules()
            }
        }
        .popup(isPresented: $UpdateScheduleViewModel.showInvalidPopUp, type: .toast, position: .top, autohideIn: 1.8) { // 3
            PopUpBody(text: "You need to select at least \(TimeConstants.units_in_session) blocks, for 2 hour sessions", color: Color(red: 1, green: 0.8, blue: 0.8))
        }
        .popup(isPresented: $UpdateScheduleViewModel.showWorkedPopUp, type: .toast, position: .top, autohideIn: 2, closeOnTapOutside: true) { // 3
            PopUpBody(text: "Updated schedule for \(UpdateScheduleViewModel.date.to_WeekDay_date())", color: Color(red: 0.8, green: 1, blue: 0.8))
        }
        .popup(isPresented: $UpdateScheduleViewModel.showErrorPopUp, type: .toast, position: .top, autohideIn: 2) { // 3
            PopUpBody(text: "Sorry there was an error :(", color: Color(red: 0.8, green: 1, blue: 0.8))
        }
    }
}

struct ToolBarButton:View{
    var text:String
    var hidden:Bool
    var action: () -> Void
    var body: some View{
        Button(action: self.action){
            Text(text)
        }
        .opacity(self.hidden ? 0: 1)
        .disabled(self.hidden)
    }
}

struct PopUpBody:View{
    var text:String
    var color:Color
    var body: some View{
        Text(text)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding(EdgeInsets(top: 60, leading: 32, bottom: 16, trailing: 32))
            .frame(maxWidth: .infinity,minHeight: 119, alignment: .center)
            .background(color)
            .cornerRadius(10.0)
    }
}

//struct updateScheduleView_Previews: PreviewProvider {
//    static var previews: some View {
//        updateScheduleView("123")
//    }
//}

func getColor(value:Int) -> Color{
    switch value {
    case 2:
        return Color.blue
    case 1:
        return Color.green
    default:
        return Color.red
    }
}
