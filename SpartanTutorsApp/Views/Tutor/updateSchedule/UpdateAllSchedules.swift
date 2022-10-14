//
//  SwiftUIView.swift
//  SpartanTutors
//
//  Created by Leo on 8/21/22.
//

import SwiftUI

struct UpdateAllSchedules: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var UpdateScheduleViewModel:scheduleUpdateViewModel
    @EnvironmentObject var monthVM: MonthlyCalendarVM
    
    var body: some View {
        VStack(spacing: 15){
            HStack{
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }){
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .foregroundColor(Color.black)
                        .padding()
                }
                Spacer()
            }
            .padding()
            
            Spacer()
            
            HStack{
                Text("Copy schedule from: ")
                Text("\(UpdateScheduleViewModel.date.to_WeekDay_date())")
                    .bold()
            }
            .padding()
            
            
            Text("Copy schedule to:")
                .bold()
            MonthlyCalendar(calendarViewModel: monthVM)
            Spacer()
            HStack(spacing:3){
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.gray)
                
                Text("This does not update the n of weekly sessions for every week.")
                    .font(.footnote)
            }
            .padding(10)
            
            Button(action: {
                UpdateScheduleViewModel.try_to_update_schedule(all: true ,dates: monthVM.selected_dates)
            }) {
              Text("Update all days")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemIndigo))
                .cornerRadius(12)
                .padding(10)
            }
            .padding(.horizontal,10)
        }
        .popup(isPresented: $UpdateScheduleViewModel.showUpdatedAllPopUp, type: .toast, position: .top, autohideIn: 1.3) {
            PopUpBody(text: "Updated schedule for all selected dates", color: Color(red: 0.8, green: 1, blue: 0.8))
        }
        .onDisappear{
            monthVM.clear_dates()
        }
    }
}
