//
//  AdminHomePage.swift
//  SpartanTutors
//
//  Created by Leo on 6/16/22.
//

import SwiftUI

struct AdminHomePage: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @ObservedObject var adminViewModel = AdminAllSessions()
    @ObservedObject var approval_tutor_view_model = ApproveTutorViewModel()
    @State var tab_manager = AdminTabManager()
    @ObservedObject var students_view_model = StudentsAdminViewModel()
    @ObservedObject var dashboard_calendar = calendarVM(show_more_dates: true)
    @State var dashboard_date = Date()
    
    init(){
        if #available(iOS 15.0, *){
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
    }
    
    var body: some View {
        if adminViewModel.loading{
            Header_end()
            LoadingCircle()
        }
        else{
            NavigationView{
                TabView(selection: $tab_manager.tab){
                    AdminDashBoard(viewModel:dashboard_calendar, date: $dashboard_date)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tag(admin_tab_options.dashboard)
                        .tabItem{
                            Label("Overview", systemImage: "speedometer")
                        }
                        .environmentObject(adminViewModel)
                        .environmentObject(tab_manager)
                        .environmentObject(approval_tutor_view_model)
                    
                    allSessionsAdmin()
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tag(admin_tab_options.sessions)
                        .tabItem{
                            Label("Sessions", systemImage: "calendar")
                        }
                        .environmentObject(adminViewModel)
                        .animation(.easeInOut,value: tab_manager.tab)
                        
                    TutorsViewAdmin(AllTutors: approval_tutor_view_model)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tag(admin_tab_options.tutors)
                        .tabItem{
                            Label("Tutors",systemImage:"person.circle")
                        }
                        .environmentObject(adminViewModel)
                        .environmentObject(tab_manager)
                        .environmentObject(approval_tutor_view_model)
                    
                    StudentViewAdmin(AllStudents:students_view_model)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tag(admin_tab_options.users)
                        .tabItem{
                            Label("Students",systemImage:"person.circle")
                        }
                        .environmentObject(adminViewModel)
                        .environmentObject(tab_manager)
                        .environmentObject(students_view_model)
                    
                    ConfigurationViewAdmin()
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .environmentObject(viewModel)
                        .environmentObject(adminViewModel)
                        .tabItem{
                            Label("Sign out",systemImage:"xmark.circle")
                        }
                        .tag(admin_tab_options.sign_out)
                }
            }
        }
    }
    
    var sign_out: some View{
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
            
            Spacer()
        }
        
    }
}

class AdminTabManager: ObservableObject{
    @Published var tab: admin_tab_options = .sessions
}

enum admin_tab_options{
    case sessions
    case users
    case tutors
    case sign_out
    case dashboard
    case text
    case schedule_summary
}
struct AdminHomePage_Previews: PreviewProvider {
    static var previews: some View {
        AdminHomePage()
    }
}
