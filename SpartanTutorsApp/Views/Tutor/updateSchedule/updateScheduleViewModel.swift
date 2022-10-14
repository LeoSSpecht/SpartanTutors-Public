//
//  updateScheduleViewModel.swift
//  SpartanTutors
//
//  Created by Leo on 7/3/22.
//

import Foundation
import FirebaseFirestore

class scheduleUpdateViewModel: ObservableObject{
    @Published var date = Date()
    @Published var showWorkedPopUp = false
    @Published var showInvalidPopUp = false
    @Published var showErrorPopUp = false
    @Published var showUpdatedAllPopUp = false
    @Published var model = TutorScheduleModel()
    
    
    @Published var selected_dates = [Date]()
    @Published var select_four = false
    private var listeners: [ListenerRegistration] = []
    private var id:String
    
    init(_ id:String){
        self.id = id
        getAllSchedules()
    }
    
    deinit{
        for i in listeners.indices{
            listeners[i].remove()
        }
    }
    private var db = Firestore.firestore()
    
    var schedule: Timeframe?{
        let day = date.to_int_format()
        check_if_date_exists()
        return model.schedule[day]
    }
    
    var session_week: Int?{
        get{
            check_if_week_exists()
            return model.n_of_session[date.to_week_number()]
        }
        set{ 
            model.n_of_session[date.to_week_number()] = newValue
        }
    }
    
    
    var hide_bar:Bool {
        self.showInvalidPopUp || self.showWorkedPopUp
    }
    func clear_schedule(){
        let day = date.to_int_format()
        model.clear_schedule(date: day)
    }
    func full_schedule(){
        let day = date.to_int_format()
        model.full_schedule(date: day)
    }
    
    func try_to_update_schedule(all: Bool = false, dates: [Date]? = nil){
        
        if checkIfSelectedValid(){
            if all {
                update_all_schedules(dates: dates!){completed in
                    if completed{
                        self.showUpdatedAllPopUp = true
                        self.showErrorPopUp = false
                    }
                    else{
                        self.showErrorPopUp = true
                        self.showUpdatedAllPopUp = false
                    }
                }
            }
            else{
                //Selection is valid, trying to update
                updateSchedule(){completed in
                    if completed{
                        self.showWorkedPopUp = true
                        self.showErrorPopUp = false
                    }
                    else{
                        self.showErrorPopUp = true
                        self.showWorkedPopUp = false
                    }
                }
            }
            
        }
        else{
            //Date is not valid, show error pop up
            showInvalidPopUp = true
            showWorkedPopUp = false
        }
    }
    
    func check_if_date_exists(){
        let day = date.to_int_format()
        if model.schedule[day] == nil{
            //Date  doesn't exists
            model.set_day(date: date)
        }
    }
    
    func check_if_week_exists(){
        let day = date.to_week_number()
        if model.n_of_session[day] == nil{
            //Date  doesn't exists
            model.set_week(date: date)
        }
    }
    
    
    func selectTime(ind:Int){
        let day = date.to_int_format()
        if select_four{
            let select_many = 4
                let max_index = ind+select_many < TimeConstants.times_in_day ? ind+select_many : TimeConstants.times_in_day
                //If making available, make 4 at a time
                //Checks if next 4 are available
                var areAvailable = true
                for i in ind..<max_index{
                    if model.schedule[day]?.data[i] == 1 || model.schedule[day]?.data[i] == 2{
                        areAvailable = false
                    }
                }
                if areAvailable{
                    for i in ind..<max_index{
                        model.update_time(ind: i, date: day)
                    }
                }
                //If making unavailable, make 1 at a time
                else{
                    model.update_time(ind: ind, date: day)
                }
        }
        else{
            model.update_time(ind: ind, date: day)
        }
    }
    
    func getAllSchedules(){
        let listen = db.collection("tutor_schedules").document(self.id).addSnapshotListener{result, err in
            if let result = result, result.exists{
                let data = result.data()!
                let tutor_schedules = data as! [String:String]
                self.model.updateSchedule(new: tutor_schedules)
            }
            else{
                print("No schedule exists yet")
            }
        }
        listeners.append(listen)
    }
    
    
    func updateSchedule(_ completion: @escaping (_ err:Bool) -> Void){
        let day = self.date.to_int_format()
        let week = self.date.to_week_number()
        let schedule_string = model.schedule[day]!.to_string
        let weekly_sessions = "\(model.n_of_session[week]!)"
        db.collection("tutor_schedules").document(self.id).setData(
            //Updates only the day the tutor has currently selected
            //If you want to update all the changes made do: model.schedule -> Remeber to make all of them strings
            [day:schedule_string,
             week: weekly_sessions], merge: true
        )
        {(err) in
            if let err = err {
                print("Error updating document: \(err)")
                
                completion(false)
            } else {
                print("Document successfully updated")
                completion(true)
            }
        }
    }
    
    func update_all_schedules(dates: [Date], _ completion: @escaping (_ err:Bool) -> Void){
        //REMOVE ALL ON DISMISS
        var complete_dict = [String:String]()
        let original_date = self.date.to_int_format()
        var schedule_to_copy = model.schedule[original_date]!
        
        complete_dict[original_date] = schedule_to_copy.to_string
        //Makes sessions to available
        schedule_to_copy.make_available_on_sessions()
        
        
        for day in dates{
            let day_formatted = day.to_int_format()
            if model.schedule[day_formatted] != nil{
                //Schedule exists, maintain sessions
                complete_dict[day_formatted] = model.schedule[day_formatted]?.copy(schedule_to_copy)
            }
            else{
                //Schedule doesnt exist, create new
                complete_dict[day_formatted] = schedule_to_copy.to_string
            }
            
        }
        db.collection("tutor_schedules").document(self.id).setData(
            //Updates only the day the tutor has currently selected
            //If you want to update all the changes made do: model.schedule -> Remeber to make all of them strings
            complete_dict, merge: true
        )
        {(err) in
            if let err = err {
                print("Error updating document: \(err)")
                
                completion(false)
            } else {
                print("Document successfully updated")
                completion(true)
            }
        }
        
    }
    
    func checkIfSelectedValid() -> Bool{
        let day = date.to_int_format()
        return model.schedule[day]!.is_valid_to_update()
    }
}
