//
//  allSessionsAdmin.swift
//  SpartanTutors
//
//  Created by Leo on 6/26/22.
//

import SwiftUI

struct allSessionsAdmin: View {
//    Change this to environmentObject
    @EnvironmentObject var sessionModel: AdminAllSessions
    var body: some View {
        VStack{
            Header_end()
            ScrollView{
                VStack(alignment: .leading){
                    HStack{
                        Text("All Sessions")
                            .fontWeight(.bold)
                            .font(.title)
                            .padding(.leading)
                        
                        Spacer()
                        
                        if sessionModel.filtered_id != nil || !sessionModel.filtered_name.isEmpty{
                            Button("Clear filter", action: {sessionModel.clear_filters()})
                                .padding(.horizontal)
                        }
                    }
                    
                    HStack{
                        Text("Pending sessions")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding()
                        
                        TextField("Person", text: $sessionModel.filtered_name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    
                    
                    ForEach(sessionModel.pending_future){ session in
                        
                        AdminRowView(sessionDetail: session,
                                     s_name: sessionModel.studentNames[session.student_uid] ?? "Error",
                                     t_name: sessionModel.tutorNames[session.tutor_uid]?.name ?? "Error")
                    }.padding(.horizontal, 5.0)
                    
                    Text("Upcoming sessions")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding()
                    
                    ForEach(sessionModel.confirmed_sessions){ session in
                        AdminRowView(sessionDetail: session,
                                     s_name: sessionModel.studentNames[session.student_uid] ?? "Error",
                                     t_name: sessionModel.tutorNames[session.tutor_uid]?.name ?? "Error")
                    }.padding(.horizontal, 5.0)
                    
                    
                    
                    Text("Past sessions")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding()
                    
                    ForEach(sessionModel.past){ session in
                        AdminRowView(sessionDetail: session,
                                     s_name: sessionModel.studentNames[session.student_uid] ?? "Error",
                                     t_name: sessionModel.tutorNames[session.tutor_uid]?.name ?? "Error")
                    }.padding(.horizontal, 5.0)
                }
            }
        }
        
        
    }
}
