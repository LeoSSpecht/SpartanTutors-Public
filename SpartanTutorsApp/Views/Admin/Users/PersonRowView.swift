//
//  PersonRowView.swift
//  SpartanTutors
//
//  Created by Leo on 8/15/22.
//

import SwiftUI

struct TutorRow: View {
    var tutor:Tutor
    //Open details
    //Approve/Unapprove tutor
    var filter_function: () -> Void
    var scale_size:CGFloat = 1.5
    let img_size:CGFloat = 15
    
    @State var showing_sheet = false
    
    @EnvironmentObject var sessionModel: AdminAllSessions
    @EnvironmentObject var tutor_model: ApproveTutorViewModel
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Colors.tutor_gray_row)
                .shadow(radius: 3)
            HStack{
                VStack(alignment: .leading){
                    HStack{
                        Text(tutor.name)
                            .fontWeight(.bold)
                        
                        Text("Due: $\(sessionModel.due_tutor(tutor), specifier: "%.2f")")
                    }
                    Text("Venmo: \(tutor.venmo)")
                    
                    Link("Phone: \(tutor.phone)", destination: URL(string: "imessage:\(tutor.phone)")!)
                        .foregroundColor(.black)
                    
                    Button(action:{
                        UIPasteboard.general.string = tutor.id
                    }){
                        Text(tutor.id)
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                VStack(spacing: 10){
                    Button(action: filter_function){
                        symbol(
                            name: "calendar",
                            img_size: img_size,
                            color: Color.black)
//                            .onTapGesture {
//                                filter_function()
//                            }
                    }
                    .foregroundColor(.black)
                    
                    
                        
                    symbol(
                        name: "list.dash",
                        img_size: img_size,
                        color: Color.black)
                    .onTapGesture {
                        showing_sheet.toggle()
                    }
                    .sheet(isPresented: $showing_sheet){
                        VStack{
                            HStack{
                                Button(action: {
                                    showing_sheet.toggle()
                                }){
                                    Image(systemName: "xmark")
                                        .imageScale(.large)
                                        .foregroundColor(Color.black)
                                        .padding()
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                            ScheduleSummaryRows(schedule: sessionModel.tutorSchedules[tutor.id] ?? TutorScheduleModel())
                        }
                        
                    }
                    
                    
                    
                    if sessionModel.due_tutor(tutor) != 0{
                        symbol(
                            name: "dollarsign.circle",
                            img_size: img_size,
                            color: Color.black)
                            .onTapGesture {
                                tutor_model.toggle_confirmation(.pay, on: tutor)
                            }
                    }
                    
                }
                
                    
            }.padding()
        }
        .confirm_pop_up(
            with: "Confirm payment for sessions?",
            show: tutor.confirm_payment,
            loading: $sessionModel.loading_payment_confirmation,
            action: {
                sessionModel.pay_all_sessions(tutor){
                    tutor_model.toggle_confirmation(.pay, on: tutor)
                }
                
            },
            dismiss: {tutor_model.toggle_confirmation(.pay, on: tutor)})
        
       
    }
}

struct StudentRow: View {
    var student:Student
    var filter_function: () -> Void
    var scale_size:CGFloat = 1.5
    let img_size:CGFloat = 20
    
    @EnvironmentObject var sessionModel: AdminAllSessions
    @EnvironmentObject var studentModel: StudentsAdminViewModel
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Colors.tutor_gray_row)
                .shadow(radius: 3)
            HStack{
                VStack(alignment: .leading){
                    HStack{
                        Text(student.name)
                            .fontWeight(.bold)
                        
                        Text("Due: $\(sessionModel.student_due(student), specifier: "%.2f")")
                    }
                    
                    Link("Phone: \(student.phone)", destination: URL(string: "imessage:\(student.phone)")!)
                        .foregroundColor(.black)
                    
                    if !student.venmo.isEmpty{
                        Text("Phone: \(student.venmo)")
                    }
                    
                    Button(action:{
                        UIPasteboard.general.string = student.id
                    }){
                        Text(student.id)
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                VStack{
                    symbol(
                        name: "calendar",
                        img_size: img_size,
                        color: Color.black)
                        .onTapGesture {
                            filter_function()
                        }
                    if sessionModel.student_due(student) != 0{
                        symbol(
                            name: "dollarsign.circle",
                            img_size: img_size,
                            color: Color.black)
                            .onTapGesture {
                                studentModel.toggle_confirmation(.pay, on: student)
                            }
                    }
                }
            }.padding()
        }
        .confirm_pop_up(
            with: "Confirm payment for all sessions?",
            show: student.confirm_paid,
            loading: $sessionModel.loading_payment_confirmation,
            action: {
                sessionModel.approve_all_sessions(student){
                    studentModel.toggle_confirmation(.pay, on: student)
                }
            },
            dismiss: {studentModel.toggle_confirmation(.pay, on: student)})
        
       
    }
}
