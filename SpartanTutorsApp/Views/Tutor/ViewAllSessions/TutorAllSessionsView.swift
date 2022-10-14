//
//  TutorAllSessionsView.swift
//  SpartanTutors
//
//  Created by Leo on 6/30/22.
//

import SwiftUI

struct allSessionsTutor: View {
//    Change this to environmentObject
    @EnvironmentObject var sessionModel: TutorAllSessionsViewModel
    @State var past_open = false
    var body: some View {
        VStack{
            Header_end()
            ScrollView{
                VStack(alignment: .leading){
                    Text("Your Sessions")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding(.leading)
                    
                    Text("Upcoming sessions")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding()
                    TutorLoopRows(type:.future)
                    
                    HStack{
                        Text("Past or canceled sessions")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding()
                        
                        Spacer()
                        
                        HStack{
                            Text("Total due: ")
                            Text("$\(sessionModel.receivables, specifier: "%.2f")")
                                .bold()
                        }
                        .padding(.horizontal)
                        
                        Button(action: {withAnimation{past_open.toggle()}}){
                            Image(systemName: "chevron.down")
                                .rotationEffect(past_open ? Angle(degrees: 0) : Angle(degrees: 180))
                                .animation(.easeInOut, value: past_open)
                        }
                        .foregroundColor(.gray)
                        .padding(.trailing)
                    }
                    if past_open{
                        TutorLoopRows(type:.past)
                    }
                    
                }
            }
        }
    }
}

struct TutorLoopRows: View{
    var type: StatusTypes
    @EnvironmentObject var sessionModel: TutorAllSessionsViewModel
    
    var list: Array<Session>{
        type == .future ? sessionModel.confirmed : sessionModel.other_Sessions
    }
    var body: some View{
        if list.isEmpty{
            VStack(alignment: .center){
                Text("You currently have no \(type.rawValue) sessions")
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            
        }
        let counter = 0.09
        ForEach(list){session in
            let session_i = list.firstIndex(of: session)!
            TutorSessionRow(details: session, student_name: sessionModel.studentNames[session.student_uid] ?? "Error", status_type: type)
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))

                .animation(.easeIn(duration: 0.2).delay(counter*Double(session_i)))
        }
        .padding(.horizontal, 7)
    }
}

enum StatusTypes: String{
    case future = "confirmed"
    case past = "pending"
}
