//
//  bookSessionView.swift
//  SpartanTutors
//
//  Created by Leo on 6/16/22.
//

import SwiftUI

struct bookSessionView: View {
    @EnvironmentObject var bookViewModel: bookStudentSession
    @StateObject var calendarViewModel = calendarVM()
    @State var show_help_pop_up = false
    @State var showed = true
    private var dateProxy:Binding<Date> {
        Binding<Date>(get: {self.bookViewModel.dateSelection }, set: {
            self.bookViewModel.dateSelection = $0
            bookViewModel.update_times()
        })
    }
    
    private var tutorProxy:Binding<TutorSummary> {
        Binding<TutorSummary>(get: {self.bookViewModel.tutorSelection }, set: {
            self.bookViewModel.tutorSelection = $0
            bookViewModel.update_times()
        })
    }
    
    private var classProxy:Binding<String> {
        Binding<String>(get: {self.bookViewModel.selectedClass }, set: {
            self.bookViewModel.selectedClass = $0
            self.bookViewModel.tutorSelection = TutorSummary(id: "Any", name: "Any")
            bookViewModel.update_times()
        })
    }
    
    var body: some View {
        if !bookViewModel.finishedLoading{
            VStack{
                Header_end()
                LoadingCircle()
            }
        }
        else{
            NavigationView{
                VStack(spacing: 20){
                    Header_end()
                    Spacer(minLength: 50)

                    HStack{
                        Text("Select a class")
                            .fontWeight(.bold)
                        Spacer()
                        Menu{
                            ForEach(
                                bookViewModel.grouped_classes.keys.sorted(by: {$0 < $1}),
                                id: \.self
                            ) { key in
                                Menu(key){
                                    Picker(selection: classProxy, label: EmptyView()) {
                                        let classes_in_group = bookViewModel.grouped_classes[key]!
                                        ForEach(classes_in_group, id: \.self) { item in
                                            Text(item)
                                        }
                                    }
                                }
                            }
//                            Picker(selection: classProxy, label: EmptyView()) {
//                                ForEach(bookViewModel.classes_, id: \.self) { item in
//                                    Text(item)
//                                }
//                            }
                        }label: {
                            picker_label(selection: self.bookViewModel.selectedClass)
                        }
                    }.padding(.horizontal)

                    HStack{
                        Text("Select a tutor")
                            .fontWeight(.bold)
                        Spacer()
                        Menu{
                            Picker(selection: tutorProxy, label: EmptyView()
                            ) {
                                Text("Any").tag(TutorSummary(id: "Any", name: "Any"))
                                ForEach(bookViewModel.tutors, id: \.self) { item in
                                    Text(item.name).tag(item)
                                }
                            }
                        }label: {
                            picker_label(selection: self.bookViewModel.tutorSelection.name)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                    }.padding(.horizontal)

                    CalendarView(calendarViewModel: calendarViewModel,selected_date: dateProxy, is_availability_possible: true, tutor_availability: self.bookViewModel.available_dates_filtered, weekly_schedule: Binding.constant(nil))
                    
                    SessionSelectionObject(ViewModel: bookViewModel,
                                           //If you want to see the NEXT available time change the filter
                                           is_there_available_time: !self.bookViewModel.next_available_dates.isEmpty, info_popup_toggle: $show_help_pop_up)
                    {
                        if let new_date = calendarViewModel.next_available_day(availability: self.bookViewModel.next_available_dates){
                            self.bookViewModel.dateSelection = new_date
                            bookViewModel.update_times()
                        }
                    }
                    .frame(maxHeight: 300)
                    
                    
                    
                    
                    NavigationLink(
                        destination: ConfirmSessionView()
                        ,isActive: self.$bookViewModel.load_confirmation
                    ){
                        EmptyView()
                    }.isDetailLink(false)

                    Button(action: {
                        print("Status after: \(self.bookViewModel.load_confirmation)")
                        self.bookViewModel.load_confirmation = true
                        print("Status after: \(self.bookViewModel.load_confirmation)")
                        print("Going to confirmation")
                    }) {
                        Text("Book Session")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(self.bookViewModel.sessionSelections != nil ? .systemIndigo: .gray))
                            .cornerRadius(12)
                            .padding()
                    }.disabled(!(self.bookViewModel.sessionSelections != nil))
                }
                .navigationBarHidden(true)
            }
            .onAppear{
                if !showed{
                    self.bookViewModel.generateTutorSchedules()
                }
                showed = false
            }
            .popup(isPresented: $bookViewModel.error_on_book, type: .toast, position: .top, autohideIn: 3) {
                PopUpBody(text: "Sorry there was an error when booking your session please try again", color: Color(red: 1, green: 0.8, blue: 0.8))
            }
            .popup(isPresented: $show_help_pop_up, type: .default, position: .bottom, closeOnTapOutside: true, backgroundColor: Color(.gray).opacity(0.6)){
                InfoPopUp(show: $show_help_pop_up)
            }
            
        }
    }
}

struct InfoPopUp: View{
    @Binding var show: Bool
    var body: some View{
        VStack{
            Text("Session duration:")
                .bold()
            Text("All of the sessions are 2 hours long. View or FAQ to learn why.")
                .padding(.bottom,10)
            Text("What you see are the possible starting times, so if you select 8:00AM the session will run from 8:00AM - 10:00AM.")
        }
        .overlay(
            Image(systemName: "xmark"), alignment: .topLeading)
        .multilineTextAlignment(.center)
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
        .background(Color.white.cornerRadius(20))
        .padding(.horizontal,37)
    }
}
struct picker_label:View {
    var selection: String
    
    var body: some View{
        HStack{
            Text(selection)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
                .frame(maxWidth: 10)
            Image(systemName: "chevron.down")
                .foregroundColor(.gray)
        }
        .padding(.vertical,5)
        .padding(.horizontal,10)
        .background(
            Capsule()
                .foregroundColor(Color(red: 24/256, green: 69/256, blue: 59/256))
        )
    }
}
