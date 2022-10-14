//
//  makePaymentView.swift
//  SpartanTutors
//
//  Created by Leo on 6/26/22.
//

import SwiftUI

struct makePaymentView: View {
    @EnvironmentObject var bookViewModel: bookStudentSession
    @EnvironmentObject var tab_vm: tab_selection
    var body: some View {
        VStack{
            Text("Session confirmed!")
                .font(.title)
                .bold()
                .foregroundColor(Color(red: 0.11, green: 0.34, blue: 0.17))
            Spacer()
            Text("Awesome 😁 your session is scheduled! All that's left is to pay. Please send $60 using one of the payment methods below. Once we get the payment of $60, we will confirm your session and you will receive an email containing the Zoom link and some more info regarding your upcoming session.")
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            PaymentMethodsView()

            Text("Please note it may take some time for us to confirm your session after your payment, but be patient, we will get to it as soon as we can. It shouldn't be more than 1-2 hours.")
                .multilineTextAlignment(.center)
                .padding(.vertical)
            
            Spacer()
            
            Button(action: {
                print("See sessions")
                tab_vm.selection = 2
                bookViewModel.reset_tabs()
            }) {
                Text("See my sessions")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemIndigo))
                    .cornerRadius(12)
                    .padding()
            }
        }.padding()
        .navigationBarBackButtonHidden(true)
        .onDisappear{
            bookViewModel.reset_tabs()
        }
    }
}

//struct makePaymentView_Previews: PreviewProvider {
//    static var previews: some View {
//        makePaymentView()
//    }
//}
