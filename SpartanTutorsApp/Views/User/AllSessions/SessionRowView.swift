//
//  SessionRowView.swift
//  SpartanTutors
//
//  Created by Leo on 6/16/22.
//

import SwiftUI

struct SessionRowView: View {
    var details:Session
    var tutor_detail: TutorSummary
    var isFuture = false
    @EnvironmentObject var sessionModel: AllSessionsModel
    @State var selected = 1
    
    var pending_buttons: some View{
        Button(action: {
            sessionModel.toggle_confirmation(.cancel, on: details)
        }){
            VStack{
                Text("Cancel session")
                    .foregroundColor(.black)
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color(red: 0.82, green: 0.1, blue: 0.1))
                    .imageScale(.medium)
            }
        }.padding(.top, 0.5)
    }
    
    
    
    var confirmed_buttons: some View{
        let event_detail = "Tutor: \(tutor_detail.name)%0AZoom link for sessions: \(tutor_detail.zoom_link)".replacingOccurrences(of: " ", with: "+")
        let event_name = "\(details.college_class) tutoring session".replacingOccurrences(of: " ", with: "+")
        let url = "https://www.google.com/calendar/render?action=TEMPLATE&text=\(event_name)&dates=\(details.get_calendar_date())&details=\(event_detail)&sf=true&output=xml"
        
        return
            HStack{
                VStack{
                    Button(action:{
                        UIPasteboard.general.string = tutor_detail.zoom_link
                    }){
                        VStack{
                            Image(systemName: "doc.on.clipboard")
                                .imageScale(.small)
                            Text("Copy zoom link")
                                .font(.caption)
                        }
                        .foregroundColor(.black)
                    }
                    .padding(.vertical, 3)

                    Text("Password: \(tutor_detail.zoom_password)")
                        .font(.caption)
                        .padding(.top,1)
                }
                
                //Add to google calendar
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
                
                Divider()
                    .padding(.horizontal, 5)
                    .padding(.vertical, 10)
                
               
                // RUNNING LATE
                if details.student_running_late{
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
            }.multilineTextAlignment(.center)
    }
    
    var body: some View {
        ZStack(alignment: .trailing){
            RoundedRectangle(cornerRadius: 20.0)
                .foregroundColor(get_Status_Color(detail: details))
                .shadow(radius: 3)
            TabView(selection: $sessionModel.selected_tabs[sessionModel.get_session_index(of: details)]){
                InnerRow(details: details,tutor_detail: tutor_detail, tag: $sessionModel.selected_tabs[sessionModel.get_session_index(of: details)], show_late_info: $sessionModel.show_late_info)
                    .tag(1)
                
                if isFuture{
                    ZStack{
                        Rectangle()
                            .foregroundColor(Colors.gray_row)
                        HStack{
                            Image(systemName: "xmark")
                                .imageScale(.medium)
                                .foregroundColor(.black)
                                .padding()
                                .onTapGesture {
                                    sessionModel.selected_tabs[sessionModel.get_session_index(of: details)] = 1
                                }
                            Spacer()
                        }
                        
                        if details.status == "Pending"{
                            pending_buttons
                                .padding(.leading,10)
                        }
                        else if details.status == "Approved"{
                            confirmed_buttons
                                .padding(.leading,10)
                        }
                    }
                    .tag(2)
                    .confirm_pop_up(
                        with: "Are you sure you want to cancel this session?",
                        show: details.student_confirm_cancel,
                        loading: $sessionModel.loading,
                        action: {sessionModel.cancel_session(session: details)},
                        dismiss: {sessionModel.toggle_confirmation(.cancel, on: details)})
                    .confirm_pop_up(
                        with: "Confirm that you are running late?",
                        show: details.confirm_late,
                        loading: $sessionModel.loading,
                        action: {sessionModel.running_late(session: details)},
                        dismiss: {sessionModel.toggle_confirmation(.late, on: details)})
                }
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.leading, 10)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .aspectRatio(3.5, contentMode: .fit)
            .animation(.easeIn(duration: 0.6), value: sessionModel.selected_tabs[sessionModel.get_session_index(of: details)])
            .onChange(of: sessionModel.selected_tabs[sessionModel.get_session_index(of: details)], perform: { newValue in
                if newValue == 2{
                    sessionModel.change_selected_tab(new_value: newValue, new_session: details)
                }
                else{
                    withAnimation{
                        sessionModel.cancel_all_pop_ups(on: details)
                    }
                    
                }
            })
        }

    }
}

struct InnerRow: View{
    var details: Session
    var tutor_detail: TutorSummary
    @Binding var tag: Int
    @Binding var show_late_info: Bool
    
    var image: some View{
        Image(systemName: "questionmark.circle")
            .imageScale(.small)
            .foregroundColor(Color(red: 0.15, green: 0.05, blue: 0.05))
            .onTapGesture {
                show_late_info = true
            }
    }
    
    var body: some View{
        ZStack{
            Rectangle()
                .foregroundColor(Colors.gray_row)
            HStack{
                VStack(alignment: .leading){
                    Text(details.date.to_WeekDay_date())
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(details.get_time_frame())
                        .fontWeight(.bold)
                    Text(tutor_detail.name)
                    Text(details.college_class)
                }
                
                Spacer()
                VStack(alignment: .trailing, spacing: 12){
                    HStack{
                        Text("Status:")
                        Text(details.status)
                            .fontWeight(.bold)
                            .foregroundColor(get_Status_Color(detail: details))
                    }
                    
                    
                    if details.status != "Canceled" && details.date >= Date(){
                        Button{
                            tag = 2
                        } label:{
                            HStack{
                                Text("Options")
                                    .font(.footnote)
                                Image(systemName: "chevron.right")
                                    .imageScale(.medium)
                            }
                            .foregroundColor(.black)
                        }
                        
                        if details.tutor_running_late{
                            Text("Tutor may be late")
                                .font(.caption)
                                .foregroundColor(Color(red: 130/255, green: 0, blue: 0))
                                .padding(.horizontal,15)
//                                .padding(.vertical,10)
                                .offset(x:-5)
                                .onTapGesture {
                                    show_late_info = true
                                }
                                .overlay(image, alignment: .trailing)
                        }
                    }
                }
            }.padding()
        }
    }
}






