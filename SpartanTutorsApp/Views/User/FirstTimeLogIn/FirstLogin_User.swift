//
//  FirstLogin_User.swift
//  SpartanTutors
//
//  Created by Leo on 6/13/22.
//

import SwiftUI

struct FirstLogin_User: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @StateObject var createUserModel = UserCreationModel()
    @State var error = false
    @State var cancelation_policy_check = false
    @State var privacy_policy_check = false
    
    @State var sms_check = false
    
    @State var show_safari = false
    @State var link = "https://spartantutorsmsu.com/privacy/"
    
    var accepted_policies: Bool{
        cancelation_policy_check && privacy_policy_check
    }
    
    var years = ["Freshman","Sophomore","Junior","Senior"]
    var body: some View {
        VStack{
            Text("Spartan Tutors")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
            Divider()
                .background(Color.green)
//                .padding(.bottom, 30.0)
           
            Text("We just need some information before we get started")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                

            VStack{
                HStack{
                    TextBox(variable: $createUserModel.first_name, text: "First name")
                    TextBox(variable: $createUserModel.last_name, text: "Last name")
                }
                
                
                TextBox(variable: $createUserModel.major, text: "Major")
                TextBox(variable: createUserModel.formatted_phone, text: "Phone number", isPhone: true, phone: createUserModel.phone)
                ZStack{
                    Menu{
                        Picker(selection: $createUserModel.yearStatus, label: EmptyView()){
                            ForEach(years, id: \.self){
                                Text($0)
                            }
                        }
                    } label:{
                        Text(createUserModel.yearStatus.isEmpty ? "Select year status" : createUserModel.yearStatus)
                            .foregroundColor(createUserModel.yearStatus.isEmpty ? .gray : .black)
                    }
                    RoundedRectangle(cornerRadius:10)
                        .stroke(lineWidth: 3)
                        .fill(createUserModel.yearStatus.isEmpty ? Color.gray : .green)
                }
                .frame(maxHeight: 50)
                .padding(3)
            }
            .padding()
            
            Toggle(isOn: $sms_check) {
                Text("I would like to receive marketing text and emails")
                    .font(.caption)
            }
            .toggleStyle(CheckboxStyle())
            
            Toggle(isOn: $cancelation_policy_check) {
                Text("I accept the Cancellation Policy")
                    .underline()
                    .font(.caption)
                    .onTapGesture {
                        link = "https://spartantutorsmsu.com/cancellation/"
                        show_safari.toggle()
                    }
            }
            .toggleStyle(CheckboxStyle())
            
            Toggle(isOn: $privacy_policy_check) {
                Text("I accept the Privacy Policy")
                    .underline()
                    .font(.caption)
                    .onTapGesture {
                        link = "https://spartantutorsmsu.com/privacy/"
                        show_safari.toggle()
                    }
                    
            }
            .toggleStyle(CheckboxStyle())
            
            
            Button(action:{
                createUserModel.isLoading = true
                createUserModel.createUser(
                    uid: viewModel.userID.uid,
                    sms_check: self.sms_check
                ){
                    viewModel.userID.isNewUser = !$0
                    viewModel.isFirstSignIn = !$0
                    if $0{
                        viewModel.getRole()
                    }
                    createUserModel.isLoading = false
                    self.error = !$0
                }
                
                print("Log user")
            }){
                Text("Submit information")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(createUserModel.filled_all && !createUserModel.isLoading && accepted_policies ? Color(.blue) : .gray)
                    .cornerRadius(12)
                    .padding()
            }
            .disabled(!createUserModel.filled_all || createUserModel.isLoading || !accepted_policies)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .popup(isPresented: $error, type: .toast, position: .top, autohideIn: 1.8) { // 3
            PopUpBody(text: "Sorry, something went wrong :( Please try again", color: Color(red: 1, green: 0.8, blue: 0.8))
        }
        .fullScreenCover(isPresented: $show_safari, content: {
            SFSafariViewWrapper(url: URL(string: link)!)
        })
    }
}

struct TextBox:View{
    @Binding var variable:String
    var text:String
    var isPhone = false
    var phone = ""
    
    var body: some View{
        ZStack{
            if isPhone{
                HStack{
                    Text("+1")
                        .padding()
                    Spacer()
                }
            }
            TextField(text, text: $variable)
                .keyboardType(isPhone ? .phonePad : .default)
                .padding()
                .multilineTextAlignment(.center)
            RoundedRectangle(cornerRadius:10)
                .stroke(lineWidth: 3)
                .fill(variable.isEmpty || (isPhone && !phone.is_valid_phone) ? Color.gray : Color.green)
        }
        .frame(maxHeight: 50)
        .padding(3)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct FirstLogin_User_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            FirstLogin_User()
        }
    }
}


