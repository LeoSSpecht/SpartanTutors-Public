//
//  ContentView.swift
//  SpartanTutors
//
//  Created by Leo on 6/11/22.
//

import SwiftUI
import Firebase
import FirebaseCore
import GoogleSignIn

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State var first_animation = false
    @State var second_animation = false
    
    
    var body: some View {
        if viewModel.userID.isSignedIn {
          // User is signed in.

            if viewModel.loadingSignIn{
                //Loading page
                VStack{
                    Spacer()
                    Header_begin()
                    Spacer()
                }
                
                
            }
            
            else if(viewModel.isFirstSignIn){
                FirstLogin_User()
            }
            
            else if !viewModel.show_alert{
                if(viewModel.userRole != ""){
                    let animation_time = 0.5
                    ZStack{
                        VStack{
                            if second_animation{
                                HomeView(isTutorApproved: viewModel.isTutorApproved, isTutorFirstSignIn:viewModel.isTutorFirstSignIn,
                    currentRole: viewModel.userRole)
                            }
                        }
                        .animation(.easeInOut(duration: animation_time), value: second_animation)
                        if !second_animation{
                            Header_Animation(animationStarter: first_animation)
                                .animation(.easeInOut(duration: animation_time),value: first_animation)
                                .transition(
                                    .asymmetric(
                                        insertion: .identity,
                                        removal: .opacity.animation(
                                            .easeIn(duration: animation_time)
                                                .delay(animation_time)
                                        )))
                        }
                    }
                    .onAppear{
                        first_animation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + animation_time) {
                            second_animation = true
                        }
                    }
                    .onDisappear{
                        first_animation = false
                        second_animation = false
                    }
                }
            }
            else{
                //Error
                Text("An error occured")
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
            
        } else {
          // No user is signed in.
            if viewModel.loadedCheckSignIn{
                LoginView()
            }
        }
    }
}

