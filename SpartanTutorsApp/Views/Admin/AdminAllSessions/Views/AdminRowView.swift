//
//  SwiftUIView.swift
//  SpartanTutors
//
//  Created by Leo on 6/26/22.
//

import SwiftUI

struct AdminRowView: View {
    @EnvironmentObject var all_sessions_view_model: AdminAllSessions
    var sessionDetail:Session
    var s_name:String
    var t_name:String
    var body: some View {
        AdminRow(
                 details: sessionDetail,
                 s_name:s_name,
                 t_name:t_name).aspectRatio(3, contentMode: .fit)
    }
}

struct AdminRow: View{
    @EnvironmentObject var viewModel:AdminAllSessions
    var details: Session
    var s_name:String
    var t_name:String
    var body: some View{
        ZStack(alignment: .trailing){
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(get_Status_Color(detail: details))
                .shadow(radius: 3)
            InnerAdminRow(details: details,
                          s_name:s_name,
                          t_name:t_name)
                .padding(.leading, 10)
        }
    
    }
}

struct InnerAdminRow: View{
    @EnvironmentObject var viewModel:AdminAllSessions
    @State var tab = 1
    var details: Session
    var s_name:String
    var t_name:String
    
    var confirm_button: some View{
        Button(action:
                {
                    viewModel.toggle_confirmation(.confirm, on: details)
                },
                label: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Colors.green_dark)
                        .imageScale(.medium)
                })
            .padding()
    }
    
    var cancel_button: some View{
        Button(action:
                {
                    viewModel.toggle_confirmation(.cancel_admin, on: details)
                },
                label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Colors.red_dark)
                        .imageScale(.medium)
                })
            .padding()
    }
    
    var one_hour_session_button: some View{
        Button(action:{
            viewModel.toggle_confirmation(.make_1h, on: details)
        }){
            Text("1h Session")
                .font(.caption)
                .foregroundColor(.white)
                .padding(7)
                .background(Capsule().foregroundColor(Colors.light_blue))
        }
    }
    
    var one_and_half_session_button: some View{
        Button(action:{
            viewModel.toggle_confirmation(.make1_5h, on: details)
        }){
            Text("1:30h Session")
                .font(.caption)
                .foregroundColor(.white)
                .padding(7)
                .background(Capsule().foregroundColor(Colors.light_blue))
        }
    }
    
    var refund_session: some View{
        Button(action:{
            viewModel.toggle_confirmation(.make_refund, on: details)
        }){
            Text("Refund/Replacement session")
                .font(.caption)
                .foregroundColor(.white)
                .padding(7)
                .background(Capsule().foregroundColor(Colors.light_blue))
        }
    }
    
    var main_tab: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Colors.gray_row)
            HStack{
                VStack(alignment: .leading){
                    Text(details.date.to_WeekDay_date())
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(details.get_time_frame())
                        .fontWeight(.bold)
                    
                    Text("Tutor: \(t_name)") // Tutor
                    Text("Student: \(s_name)") //Student
                    Text(details.college_class)
                }
                Spacer()
                VStack(alignment: .trailing){
                    HStack{
                        Text("Status:")
                        Text(details.status)
                            .fontWeight(.bold)
                            .foregroundColor(get_Status_Color(detail: details))
                    }
                    
                    if details.date < Date(){
                        if details.status == "Pending"{
                            cancel_button
                        }
                    }
                    else if details.status == "Pending"{
                        HStack{
                            cancel_button
                            confirm_button
                        }
                    }
                    else if details.status == "Approved"{
                        cancel_button
                    }
                }
            }.padding()
        }
    }
    
    var second_tab: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Colors.gray_row)
            HStack{
                if details.duration == 2{
                    one_hour_session_button
                        .padding(5)
                    one_and_half_session_button
                        .padding(5)
                }
                
                if(details.paid){
                    refund_session
                        .padding(5)
                }
            }
            
        }
        .confirm_pop_up(
            with: "Make session 1h?",
            show: details.make_1h,
            loading: $viewModel.loading_1h,
            action: {
                viewModel.change_session_duration(session: details)
            },
            dismiss: {viewModel.toggle_confirmation(.make_1h, on: details)})
        .confirm_pop_up(
            with: "Refund/Mark session as replacement",
            show: details.make_refund,
            loading: $viewModel.loading_1h,
            action: {
                viewModel.make_session_refund(session: details)
            },
            dismiss: {viewModel.toggle_confirmation(.make_refund, on: details)})
        .confirm_pop_up(
            with: "Make session 1:30h?",
            show: details.make_1_5h,
            loading: $viewModel.loading_1h,
            action: {
                viewModel.change_session_duration(session: details, duration: 1.5)
            },
            dismiss: {viewModel.toggle_confirmation(.make1_5h, on: details)})
    }
    var body: some View{
        TabView(selection: $tab){
            main_tab
                .tag(1)
            if (details.duration == 2 &&  details.status != "Canceled") || details.paid{
                second_tab
                    .tag(2)
            }
        }
        .background(Colors.gray_row)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .confirm_pop_up(
            with: "Confirm session?",
            show: details.confirm_session_admin,
            loading: $viewModel.loading_cancel_approve,
            action: {
                viewModel.changeSessionStatus(
                    session:details,
                    session_status: "Approved")
                },
            dismiss: {viewModel.toggle_confirmation(.confirm, on: details)})
        .confirm_pop_up(
            with: "Cancel session?",
            show: details.cancel_session_admin,
            loading: $viewModel.loading_cancel_approve,
            action: {
                viewModel.changeSessionStatus(
                    session:details,
                    session_status: "Canceled")
                },
            dismiss: {viewModel.toggle_confirmation(.cancel_admin, on: details)})
        
    }
}

