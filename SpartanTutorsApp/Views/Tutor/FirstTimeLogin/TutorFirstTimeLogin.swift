//
//  TutorFirstTimeLogin.swift
//  SpartanTutors
//
//  Created by Leo on 6/30/22.
//

import SwiftUI

struct TutorFirstTimeLogin: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @StateObject var createUserModel = TutorCreationModel()
    @StateObject var allClassesViewModel = classSelectionViewModel()
    
    var body: some View {
        NavigationView{
            VStack{                
                Text("Spartan Tutors")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                Divider()
                    .background(Color.green)
               
                Text("We just need some information before we get started")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    

                VStack{
                    classSelectionView(allClassesViewModel: allClassesViewModel)
                    TextBox(variable: $createUserModel.venmo, text: "Venmo username")
                    TextBox(variable: $createUserModel.zoom_link, text: "Your zoom meeting ID")
                    TextBox(variable: $createUserModel.zoom_password, text: "Your zoom password")
                }
                .padding()

                Button(action:{
                    createUserModel.updateTutor(
                        uid: viewModel.userID.uid,
                        classes: allClassesViewModel.onlySelected
                    ){
                        viewModel.getRole()
                    }
                }){
                    Text("Submit information")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.blue))
                        .cornerRadius(12)
                        .padding()
                }
                .disabled(!createUserModel.both_filled)
            }
        }
    }
}

struct TutorFirstTimeLogin_Previews: PreviewProvider {
    static var previews: some View {
        TutorFirstTimeLogin()
    }
}
