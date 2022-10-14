//
//  allSessionsView.swift
//  SpartanTutors
//
//  Created by Leo on 6/18/22.
//

import SwiftUI

struct allSessionsView: View {
    @EnvironmentObject var sessionModel: AllSessionsModel
    @State var past_open = false
    @State var confirmed_open = false
    var body: some View {
        VStack{
            Header_end()
            ScrollView{
                VStack(alignment: .leading){
                    HStack{
                        Text("Your Sessions")
                            .fontWeight(.bold)
                            .font(.title)
                            .padding(.leading)
                        
                        Spacer()
                        
                        Menu{
                            PaymentMethodsView()
                        } label: {
                            Text("Make a Payment")
                        }
                        .padding()
                    }
                    
                    HStack{
                        Text("Upcoming sessions")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding()
                        Spacer()
                        HStack{
                            Text("Total due: ")
                            Text("$\(sessionModel.total_amount_due, specifier: "%.2f")")
                                .bold()
                        }
                        .padding(.horizontal)
                    }
                    
                    
                    Loop_rows(show_animation: .constant(false), empty: "upcoming")
                    
                    
                    HStack{
                        Text("Past or canceled sessions")
                            .font(.title3)
                            .fontWeight(.semibold)
                            
                        Spacer()
                        
                        Button(action: {withAnimation{past_open.toggle()}}){
                            Image(systemName: "chevron.down")
                                .rotationEffect(past_open ? Angle(degrees: 0) : Angle(degrees: 180))
                                .animation(.easeInOut, value: past_open)
                        }
                        .foregroundColor(.gray)
                    }
                    .padding()
                    
                    if past_open{
                        Loop_rows(show_animation: $past_open, empty: "past")
//                            .animation(.easeInOut, value: past_open)
                    }
                    
                }
            }
        }
        .popup(isPresented: $sessionModel.show_late_info, type: .default, position: .bottom, closeOnTapOutside: true, backgroundColor: Color(.gray).opacity(0.6)){
            LateInfoPopUp(show: $sessionModel.show_late_info)
        }
        .popup(isPresented: $sessionModel.sucess, type: .toast, position: .top, autohideIn: 3) {
            PopUpBody(text: "The session was updated sucessfully", color: Color(red: 0.8, green: 1, blue: 0.8))
        }

    }
}

struct Loop_rows: View{
    @EnvironmentObject var sessionModel: AllSessionsModel
    @Binding var show_animation: Bool
    var empty: String
    
    var list: Array<Session>{
        empty == "upcoming" ? sessionModel.confirmed : sessionModel.other_Sessions
    }
    
    var body: some View{
        if list.isEmpty{
            VStack(alignment: .center){
                Text("You currently have no \(empty) sessions")
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            
        }
        let counter = 0.09
        ForEach(list.indices, id: \.self){ session_i in
            let session = list[session_i]
            let tutor_detail = sessionModel.tutors.first(where: {$0.id == session.tutor_uid}) ?? TutorSummary(id: "Error", name: "Error", zoom_link: "Contact us")
            SessionRowView(details: session,tutor_detail: tutor_detail, isFuture: empty == "upcoming" ? true : false)
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
//                .transition(.opacity.animation(.easeIn.delay(counter*Double(session_i))))
                .animation(.easeIn(duration: 0.2).delay(counter*Double(session_i)))
        }.padding(.horizontal, 7)
    }
}

struct LateInfoPopUp: View{
    @Binding var show: Bool
    var body: some View{
        VStack{
            Text("This means that the tutor is going to be up to 15 min late.")
                .bold()
            Text("For more details see our Frequently Asked Questions.")
                .padding(.top,5)
            Text("Sorry for the inconvenience :(")
                
        }
        .multilineTextAlignment(.center)
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
        .background(Color.white.cornerRadius(20))
        .padding(.horizontal,37)
    }
}
