//
//  EditInfoView.swift
//  SpartanTutors
//
//  Created by Leo on 7/28/22.
//

import SwiftUI

//POP UP
//TITLE

//First time sign in completion

struct EditInfoView: View {
    @Binding var show_edit_view: Bool
    @StateObject var viewModel: EditInfoStudentViewModel = EditInfoStudentViewModel()
    
    var years = ["Freshman","Sophomore","Junior","Senior", "No change"]
    var id:String
    
    var body: some View {
        
        VStack(spacing: 0){
            title
                .ignoresSafeArea(edges:.top)
                .overlay(xmark, alignment: .topLeading)
                .frame(maxHeight: 120)
                
            Spacer()
            
            VStack{
                TextBox(variable: $viewModel.major, text: "Major")
                TextBox(variable: viewModel.formatted_phone, text: "Phone", isPhone: true,phone: viewModel.phone)
                
                ZStack{
                    Menu{
                        Picker(selection: $viewModel.yearStatus, label: EmptyView()){
                            ForEach(years, id: \.self){
                                Text($0)
                            }
                        }
                    } label:{
                        Text(viewModel.yearStatus == "No change" ? "Year status" : viewModel.yearStatus)
                            .foregroundColor(viewModel.yearStatus == "No change" ? .gray : .black)
                    }
                    RoundedRectangle(cornerRadius:10)
                        .stroke(lineWidth: 3)
                        .fill(viewModel.yearStatus == "No change" ? Color.gray : .green)
                }
                .frame(maxHeight: 50)
                .padding(3)
                
//                Toggle("SMS Marketing", isOn: <#T##Binding<Bool>#>)
            }
            .padding()
            
            Spacer()
                .onTapGesture {
                    hideKeyboard()
                }
            
            Button(action:{
                viewModel.update_data(id: self.id)
            }){
                Text("Update my information")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.at_least_one_change ?
                                    Color(red: 0.1, green: 0.4, blue: 0.1) : .gray)
                    .cornerRadius(12)
                    .padding()
            }
            .disabled(!viewModel.at_least_one_change)
        }
        .popup(isPresented: $viewModel.finished_update, type: .toast, position: .top, autohideIn: 2) { // 3
            PopUpBody(text: "Your information was updated", color: Color(red: 0.8, green: 1, blue: 0.8))
        }
        
        .navigationBarHidden(true)
 
    }
    
    var title: some View{
        ZStack(alignment: .bottom){
            Rectangle()
                .foregroundColor(Color(red: 0.08, green: 0.35, blue: 0.08))
            VStack(alignment: .center,spacing: 0){
                Spacer()
                Text("Edit my info")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .foregroundColor(.white)
            }
        }
        
    }
    
    var xmark: some View{
        Image(systemName: "xmark")
            .imageScale(.large)
            .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            .padding()
            .onTapGesture {
                show_edit_view = false
            }
            
    }
}

//struct EditInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditInfoView()
//    }
//}
