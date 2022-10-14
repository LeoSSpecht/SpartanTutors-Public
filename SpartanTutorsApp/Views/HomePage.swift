//
//  HomePage.swift
//  SpartanTutors
//
//  Created by Leo on 6/11/22.
//

import SwiftUI
import GoogleSignIn
import Firebase
import FirebaseCore
struct HomeView: View {
  // 1
    @EnvironmentObject var viewModel: AuthenticationViewModel
    var isTutorApproved:Bool
    var isTutorFirstSignIn:Bool
    var currentRole:String
    var body: some View {
//    Get user role, depending on the role load certain page
        if currentRole == "student"{
            UserHomePage(id: viewModel.userID.uid, name: viewModel.userID.name)
        }
        else if currentRole == "tutor"{
            if isTutorApproved{
                if isTutorFirstSignIn{
                    //Load first time page
                    TutorFirstTimeLogin()
                }
                else{
                    TutorHomePage(viewModel.userID.uid, name: viewModel.userID.name)
                }
            }
            else{
                //Load waiting for approval
                Text("You are not approved yet, please wait for approval and try again")
            }
        }
        else if currentRole == "admin"{
            AdminHomePage()
        }
        else{
            Text("There was an error, please try again")
            Button(action: viewModel.signOut) {
            Text("Sign out")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemIndigo))
                .cornerRadius(12)
                .padding()
            }
        }
  }
}
