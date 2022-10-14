//
//  TutorRowView.swift
//  SpartanTutors
//
//  Created by Leo on 6/30/22.
//

import SwiftUI

struct TutorSessionRow: View{
    var details: Session
    var student_name: String
    var status_type: StatusTypes
    @EnvironmentObject var sessionModel: TutorAllSessionsViewModel
    @State var selected = 1
    
    var approved_buttons: some View{
        let event_name = "\(details.college_class) tutoring session".replacingOccurrences(of: " ", with: "+")
        let url = "https://www.google.com/calendar/render?action=TEMPLATE&text=\(event_name)&dates=\(details.get_calendar_date())&sf=true&output=xml"
        return HStack{
//            Spacer()
            
            if details.tutor_running_late{
                Text("Late option\nselected")
                    .font(.caption)
                    .foregroundColor(Color(red: 130/255, green: 0, blue: 0))
                    .bold()
            }
            else{
                Button{
                    sessionModel.toggle_confirmation(.late, on: details)
                } label: {
                    Text("Will you\nbe late?")
                        .font(.caption)
                        .foregroundColor(Color(red: 130/255, green: 0, blue: 0))
                        .bold()
                }
            }
            Divider()
                .padding(.horizontal, 5)
                .padding(.vertical, 10)
            
            Link(destination: URL(string: url)!){
                VStack(spacing: 10){
                    Image(systemName: "calendar")
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.4))
                        .font(.caption)
                    
                    Text("Add to\nGoogle Calendar")
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.4))
                        .font(.caption)
                }
            }
            
//            Spacer()
        }
        .multilineTextAlignment(.center)
        
    }
    var body: some View{
        ZStack(alignment: .trailing){
            RoundedRectangle(cornerRadius: 20.0)
                .foregroundColor(get_Status_Color(detail: details))
                .shadow(radius: 3)
            TabView(selection: $selected){
                InnerTutorRow(details: details,student_name:student_name, tag: $selected)
                    .tag(1)
                
                if status_type == .future && details.status == "Approved"{
                    ZStack{
                        Rectangle()
                            .foregroundColor(.white)
                        HStack{
                            Image(systemName: "xmark")
                                .imageScale(.medium)
                                .foregroundColor(.black)
                                .padding()
                                .onTapGesture {
                                    selected = 1
                                    sessionModel.cancel_all_pop_ups(on: details)
//                                    sessionModel.selected_tabs[sessionModel.get_session_index(of: details)] = 1
                                    
                                }
                            Spacer()
                        }
                        
//                        if details.status == "Pending"{
//                            pending_buttons
//                                .padding(.leading,10)
//                        }
                        if details.status == "Approved"{
                            approved_buttons
                                .padding(.leading,10)
                        }
                    }
                    .tag(2)
                    .confirm_pop_up(
                        with: "Confirm that you are running late?",
                        show: details.confirm_late,
                        loading: $sessionModel.loading_late,
                        action: {sessionModel.running_late(session: details)},
                        dismiss: {sessionModel.toggle_confirmation(.late, on: details)})
                }
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.leading, 10)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .aspectRatio(3, contentMode: .fit)
            .animation(.easeIn(duration: 0.6), value: selected)
//            .onChange(of: sessionModel.selected_tabs[sessionModel.get_session_index(of: details)], perform: { newValue in
//                if newValue == 2{
//                    sessionModel.change_selected_tab(new_value: newValue, new_session: details)
//                }
//            })
        }
    }
}

struct InnerTutorRow: View{
    var details: Session
    var student_name: String
    @Binding var tag: Int
    var body: some View{
        ZStack{
            Rectangle()
                .foregroundColor(.white)
            HStack{
                VStack(alignment: .leading){
                    Text(details.date.to_WeekDay_date())
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(details.get_time_frame())
                        .fontWeight(.bold)
                    Text("Student: \(student_name)") //Student
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
                    
                    if details.status == "Approved" && details.date >= Date(){
                        Button{
                            tag = 2
                        } label:{
                            Image(systemName: "ellipsis")
                                .imageScale(.medium)
                                .foregroundColor(.black)
                        }
                        .padding(.top,10)
                        if details.student_running_late{
                            Text("Student will be late")
                                .font(.caption)
                                .foregroundColor(Color(red: 130/255, green: 0, blue: 0))
                                .padding(.vertical,10)
                        }
                    }
                }
            }.padding()
        }
    }
}

