//
//  UserHomePage.swift
//  SpartanTutors
//
//  Created by Leo on 6/16/22.
//

import SwiftUI

struct UserHomePage: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @ObservedObject var tab_vm = tab_selection()
    //Maybe change this to observable object
    @ObservedObject var sessionViewModel: AllSessionsModel
    @ObservedObject var bookSessionViewModel: bookStudentSession
    @ObservedObject var profileViewModel: ProfileViewModel
    var id: String
    
    init(id: String, name:String){
        self.id = id
        sessionViewModel = AllSessionsModel(uid: id)
        bookSessionViewModel = bookStudentSession(student_id: id)
        profileViewModel = ProfileViewModel(id: id, name: name)
        if #available(iOS 15.0, *){
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    var body: some View {
        
        TabView(selection: $tab_vm.selection){
            bookSessionView().environmentObject(bookSessionViewModel).environmentObject(tab_vm)
                .tabItem{
                    Label("Book", systemImage: "calendar")
                }
                .tag(1)
            allSessionsView().environmentObject(sessionViewModel)
                .tabItem{
                    Label("My Sessions", systemImage:"square.and.pencil")
                }
                .tag(2)
            MyProfile(viewModel:profileViewModel,id: self.id, content: {EditInfoView(show_edit_view: $0, id: $1)})
                .tabItem{
                    Label("My Account",systemImage:"person.circle")
                }
                .tag(3)
        }
    }
}
