//
//  SessionSelectionObject.swift
//  SpartanTutors
//
//  Created by Leo on 7/9/22.
//

import SwiftUI

struct SessionSelectionObject: View {
    @ObservedObject var ViewModel: bookStudentSession
    var is_there_available_time: Bool
    @Binding var info_popup_toggle: Bool
    var next_availble_date_function: () -> Void
    
    
    var image: some View{
        Image(systemName: "questionmark.circle")
            .foregroundColor(.gray)
            .onTapGesture {
                info_popup_toggle = true
            }
    }
    var body: some View {
        VStack{

            VStack{
                Text("Select starting time")
                    .bold()
            }
            .overlay(image.offset(x:25), alignment: .trailing)

            
            if ViewModel.available_times.isEmpty{
//              There are no sessions available
                VStack{
                    Spacer()
                    VStack(alignment: .center){
                        if !is_there_available_time{
                            Text("Sorry 😕 there are no available times for the class, tutor, and date selected.")
                            Text("Please select another time/tutor")
                                .fontWeight(.bold)
                                .padding(.top)
                        }
                        else{
                            Button(action: { next_availble_date_function() }){
                                Text("Go to next available date")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color(red: 0.11, green: 0.34, blue: 0.17))
                                    .cornerRadius(12)
                                    .padding()
                            }
                        }
                        
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    Spacer()
                }
            }
            else{
                ScrollView(.horizontal){
                    LazyHStack{
                        ForEach(ViewModel.available_times){i in
                            TimeCell(session: i)
                                .onTapGesture {
                                    ViewModel.choose_session(i.id)
                                }
                        }
                    }.padding()
                }
            }
            
        }
        
    }
}

struct TimeCell:View{
//    var time: String
//    var isSelected: Bool
    var session: sessionTime
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(session.selected ? Color.blue : Color.gray, lineWidth: 3)
                .foregroundColor(.white)
            Text(session.time_string)
        }
        .aspectRatio(2.5, contentMode: .fit)
        .frame(height:45)
    }
    
}
