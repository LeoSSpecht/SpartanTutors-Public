//
//  TutorHomePage.swift
//  SpartanTutors
//
//  Created by Leo on 6/16/22.
//

import SwiftUI

struct TutorHomePage: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @ObservedObject var tutorSessionsViewModel:TutorAllSessionsViewModel
    @ObservedObject var UpdateScheduleViewModel:scheduleUpdateViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var monthVM: MonthlyCalendarVM
    var id:String
    
    init(_ id: String, name: String){
        self.id = id
        self.UpdateScheduleViewModel = scheduleUpdateViewModel(id)
        self.tutorSessionsViewModel = TutorAllSessionsViewModel(id)
        self.profileViewModel = ProfileViewModel(id: id, name: name)
        self.monthVM = MonthlyCalendarVM()
        
        if #available(iOS 15.0, *){
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    var body: some View {
        TabView(){
            if tutorSessionsViewModel.loading{
                VStack{
                    Header_end()
                    LoadingCircle()
                }
            }
            else{
                allSessionsTutor()
                    .tabItem{
                        Label("My sessions", systemImage: "calendar")
                    }
                    .environmentObject(tutorSessionsViewModel)
                    .tag(1)
                
                updateScheduleView()
                    .environmentObject(UpdateScheduleViewModel)
                    .environmentObject(monthVM)
                    .tabItem{
                        Label("My schedule", systemImage: "square.and.pencil")
                    }
                    .tag(2)
                
                ScheduleSummary()
                    .environmentObject(UpdateScheduleViewModel)
                    .tabItem{
                        Label("Summary", systemImage: "calendar")
                    }
                    .tag(3)
                
                
                MyProfile(viewModel:profileViewModel,id: self.id, content: {EditTutorInfoView(show_edit_view: $0, id: $1)})
                    .tabItem{
                        Label("My account",systemImage:"person.circle")
                    }
                    .tag(4)
            }
        }
    }
}
