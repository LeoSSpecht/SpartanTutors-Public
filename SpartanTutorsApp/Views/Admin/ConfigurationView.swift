//
//  ConfigurationView.swift
//  SpartanTutors
//
//  Created by Leo on 9/19/22.
//

import SwiftUI

struct ConfigurationViewAdmin: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var adminViewModel: AdminAllSessions
    
    var body: some View{
        VStack{
            ZStack(alignment: .bottomLeading){
                Rectangle()
                    .foregroundColor(Color(red: 0.08, green: 0.35, blue: 0.08))
                VStack(alignment: .leading,spacing: 0){
                    Spacer()
                    Text("\(viewModel.userID.name)")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                        .foregroundColor(.white)
                    
                        Button(action: viewModel.signOut) {
                          Text("Sign out")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top,5)
                            .padding(.bottom,10)
                        }
                    }
                    
                }
                .ignoresSafeArea(edges:.top)
                .frame(maxHeight: 120)
                .padding(.bottom)
            
            LazyVGrid(columns: [GridItem(), GridItem()]){
                NavigationLink(destination: {
                        NotesViews()
                        .tag(admin_tab_options.text)
                        .tabItem{
                            Label("Text",systemImage:"text.alignleft")
                        }
                        .navigationBarTitle("")
                        .navigationBarTitleDisplayMode(.inline)
                    })
                    {
                        Tile(symbol: "doc.text", text: "Notes")
                            .padding()
                    }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                NavigationLink(destination: {
                    AdminScheduleSummary()
                        .environmentObject(adminViewModel) 
                        .tag(admin_tab_options.schedule_summary)
                        .tabItem{
                            Label("Schedules",systemImage:"calendar")
                        }
                        .navigationBarTitle("")
                        .navigationBarTitleDisplayMode(.inline)
                    })
                    {
                        Tile(symbol: "list.dash", text: "Schedule\nSummary")
                            .padding()
                    }
                
                
            }
            .padding()
            
            Spacer()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
}
