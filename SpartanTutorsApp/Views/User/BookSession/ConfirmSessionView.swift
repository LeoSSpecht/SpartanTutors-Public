//
//  ConfirmSessionView.swift
//  SpartanTutors
//
//  Created by Leo on 6/23/22.
//

import SwiftUI

struct ConfirmSessionView: View {
    @EnvironmentObject var bookViewModel: bookStudentSession
    //STORE THE CURRENT SESSION SELECTION IN A SESSION OBJECT
    var body: some View {
        VStack{
            Spacer()
                .frame(maxHeight: 50)
            Text("Would you like to confirm this session?")
                .bold()
            Spacer()
            VStack{
                Text("Date: ").bold() + Text("\(bookViewModel.dateSelection.to_WeekDay_date())")
                Text("Time: ").bold() + Text("\(bookViewModel.sessionSelections?.timeframe.get_start_end_time() ?? "No session selected")")
                Text("Tutor: ").bold() + Text("\(bookViewModel.sessionSelections?.tutor_name ?? "No session selected")")
                Text("Class: ").bold() + Text("\(bookViewModel.selectedClass)")
                Text("Duration: ").bold() + Text("2 Hours")
                Text("Total price: $60")
                    .bold()
            }
            
            Spacer()
            NavigationLink(
                destination: makePaymentView(),isActive: self.$bookViewModel.load_payment){
            }
            .isDetailLink(false)
            
            Button(action: {
                bookViewModel.createSessionObject()
            }){
                Text(bookViewModel.loading_booking ? "Loading..." : "Confirm")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(bookViewModel.loading_booking ? .gray : Color(.systemIndigo))
                    .cornerRadius(12)
                    .padding()
                    
            }.disabled(bookViewModel.loading_booking)
            
        }
        .padding()
        
    }
}

//struct ConfirmSessionView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConfirmSessionView()
//    }
//}
