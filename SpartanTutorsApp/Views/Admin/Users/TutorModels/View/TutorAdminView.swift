//
//  ApproveTutors.swift
//  SpartanTutors
//
//  Created by Leo on 7/5/22.
//

import SwiftUI

struct TutorsViewAdmin: View {
    @ObservedObject var AllTutors: ApproveTutorViewModel
    @EnvironmentObject var sessionModel: AdminAllSessions
    @EnvironmentObject var tab_manager: AdminTabManager
    
    var body: some View {
        NavigationView{
            
            VStack(spacing:0){
                Header_end()
                ScrollView{
                    VStack(alignment: .leading, spacing: 0){
                        if !AllTutors.unapproved_tutors.isEmpty{
                            Text("Pending tutors")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding()
                            ForEach(AllTutors.unapproved_tutors){tutor in
                                ApproveTutorRow(tutor:tutor,approve_function: AllTutors.approveTutor)
                                    .aspectRatio(3,contentMode: .fill)
                                    .padding([.top, .leading, .trailing],6)
                            }
                        }
                        HStack(spacing: 15){
                            Text("Tutors")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Button(action: {AllTutors.filter_tutor_payment.toggle()}){
                                Image(systemName: "dollarsign.circle")
                                    .foregroundColor(.black)
                                    .imageScale(.large)
                            }
                            
                            
                            Spacer()
                            
                            Text("No. of tutors: \(AllTutors.approved_tutors.count)")
                                .font(.callout)
                        }
                        .padding(.horizontal)
                        .padding(.vertical,5)
                        
                        HStack{
                            Text("Total due now: $\(sessionModel.total_due_now , specifier: "%.2f")")
                            Spacer()
                            Text("Total due: $\(sessionModel.total_due, specifier: "%.2f")")
                        }
                        .font(.callout)
                        .padding(.horizontal)
                        .padding(.bottom,10)
                        
                        ForEach(
                            AllTutors.approved_tutors.filter({
                                if AllTutors.filter_tutor_payment{
                                    return sessionModel.due_tutor($0) != 0
                                }
                                return true
                            })){tutor in
                            TutorRow(tutor:tutor,
                                     filter_function: {
                                        sessionModel.filtered_id = tutor.id
                                        tab_manager.tab = .sessions
                                     })
                                .aspectRatio(3,contentMode: .fill)
                                .padding([.top, .leading, .trailing],6)
                        }
                    }
                }
                
            }
            .navigationBarHidden(true)
        }
        
        
    }
}
