//
//  tutorScheduleModel.swift
//  SpartanTutors
//
//  Created by Leo on 7/3/22.
//

import Foundation

struct TutorScheduleModel{
    var schedule: [String:Timeframe] = [:]
    var n_of_session: [String:Int] = [:]
    
    init(){
        
    }
    
    //Gets a date in int format and timeframe as string
    init(new: [String:String]?){
        if let unwrapped = new{
            self.updateSchedule(new: unwrapped)
        }
    }
    
    mutating func updateSchedule(new: [String:String]){
        var new_dict:[String:Timeframe] = [:]
        var weekly_sessions: [String:Int] = [:]
        for day_schedule in new.keys{
            //If it is a date
            if day_schedule.count == 8{
                new_dict[day_schedule] = Timeframe(new[day_schedule]!)
            }
            //If it is a week
            else if day_schedule.count == 6{
                weekly_sessions[day_schedule] = Int(new[day_schedule]!)
            }
            
        }
        self.schedule = new_dict
        self.n_of_session = weekly_sessions
    }
    
    mutating func update_time(ind:Int, date:String){
        self.schedule[date]!.update_time(ind: ind)
    }
    
    mutating func set_day(date:Date){
        let string_date = date.to_int_format()
        self.schedule[string_date] = Timeframe()
    }
    
    mutating func set_week(date:Date){
        let week_n = date.to_week_number()
        if self.n_of_session[week_n] == nil{
            self.n_of_session[week_n] = 4
        }
    }
    
    mutating func clear_schedule(date:String){
        schedule[date]!.clear_schedule()
    }
    
    mutating func full_schedule(date:String){
        schedule[date]!.full_schedule()
    }
    
    mutating func append_to_any(new: TutorScheduleModel){
        var weekly_sessions: [String:Int] = self.n_of_session
        var current_dict:[String:Timeframe] = self.schedule
        
        for day_schedule in new.schedule.keys{
            //If it is a date
            let new_schedule = new.schedule[day_schedule]!
            if current_dict[day_schedule] != nil{
                //Schedule already exists, update
                current_dict[day_schedule]!.append_tutor_schedule(new_schedule)
            }
            else{
                current_dict[day_schedule] = Timeframe(new_schedule,ignore_sessions: true)
            }
        }
        
        for week_num in new.n_of_session.keys{
            //If it is a week
            weekly_sessions[week_num] = weekly_sessions[week_num] ?? 0 + Int(new.n_of_session[week_num]!)
        }
        self.schedule = current_dict
        self.n_of_session = weekly_sessions
    }
}



