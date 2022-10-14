//
//  bookSessionModels.swift
//  SpartanTutors
//
//  Created by Leo on 6/23/22.
//

import Foundation

struct sessionBookerData{
    let initial_time = DayConstants.starting_time
    private (set) var all_tutors: Array<TutorSummary> = []
    private (set) var tutors_for_class:Array<TutorSummary> = []
    private (set) var id_schedule_dict = [String:TutorSchedule]()
    //Class name -> Array of tutor ids
    private (set) var classes_dict = [String:Array<String>]()
    private (set) var available_times:Array<sessionTime> = []
    
    private var all_possible_days = calendarModel.get_all_days_list()
    
    //Date:[ID:Available]
    private (set) var all_available_dates = [String:[String:Bool]]()
    
//  MARK: UPDATING FUNCTIONS
    mutating func update_id_schedule(new: [String:TutorSchedule], classes_available: [String:Array<String>]){
        id_schedule_dict = new
        classes_dict = classes_available
    }
    
    var all_classes: Array<String>{
        Array(classes_dict.keys).sorted()
    }
    
    mutating func update_tutor_schedule(new_schedule: [String:Any], id: String){
        id_schedule_dict[id]!.update_schedule(new_schedule)
    }
    
    mutating func build_all_available_dates(){
        //For each tutor in schedule, see if he is available for date
        //Dict [Date:[id: available(Bool)]]
        for date in all_possible_days{
            for id in id_schedule_dict.keys{
                if let day_schedule = id_schedule_dict[id]?.schedule[date]{
                    //The tutor has the schedule set
                    if day_schedule.is_there_availability_in_day(date_string: date){
                        //Tutor is available at that date
                        if all_available_dates[date] == nil{
                            all_available_dates[date] = [:]
                        }
                        all_available_dates[date]![id] = true
                    }
                    else{
                        //Tutor is not available in that date
                        if all_available_dates[date] == nil{
                            all_available_dates[date] = [:]
                        }
                        all_available_dates[date]![id] = false
                    }
                }
                else{
                    //Tutor has not made the schedule for that day
                    if all_available_dates[date] == nil{
                        all_available_dates[date] = [:]
                    }
                    all_available_dates[date]![id] = false
                }
            }
        }
    }
    
    //END NEW
    mutating func create_available_times(tutor:String = "Any", date: Date = Date(), college_class:String) -> Bool{
        print("Started updating available times")
        let temp_times = build_final_time_list(tutor: tutor, date: date, college_class: college_class)
        
        var equal = true
        if temp_times.count == available_times.count{
            for i in temp_times.indices{
                if !temp_times[i].is_the_same(rhs: available_times[i]){
                    equal = false
                    break
                }
            }
        }
        else{
            equal = false
        }
        if !equal{
            available_times = temp_times
        }
        print("Finished updating times")
        return !equal
        
    }
    
    mutating func choose_session(_ id: Int) -> sessionTime?{
        if let index = available_times.firstIndex(where: {$0.id == id}){
            for i in available_times.indices{
                self.available_times[i].selected = false
            }
            self.available_times[index].selected = true
            return self.available_times[index]
        }
        return nil
    }
    
    func get_tutor_name(id: String) -> String{
        return id_schedule_dict[id]!.tutorName
    }
    
    private func build_available_times(time_frame: Timeframe, duration:Int ,date:Date,string_date: String,tutor_id:String, tutor_name: String) ->[Int:sessionTime]{
//      Description: Decodes from bitstring date format to string time and returns available bitstrings
        var all_available_times:[Int:sessionTime] = [:]
//        Times from 8-22 from 15-15 min
        for i in 0..<(TimeConstants.times_in_day-duration*TimeConstants.times_in_hour+1){
            if time_frame.is_available_in_index(ind: i, duration: duration){
//              If time is already not taken
                let timeframe = String(repeating: "0", count: i)+String(repeating: "2", count: duration*TimeConstants.times_in_hour)+String(repeating: "0", count: TimeConstants.times_in_day-i-duration*TimeConstants.times_in_hour)
                let formatted_date = time_frame_to_date(time_slot: Timeframe(timeframe), date: date)
                // Checks if time is greater than now +1h
                let calendar = Calendar.current
                let today = calendar.date(byAdding: .hour, value: sessionConstants.make_unavailable_before_hours, to: Date())!
                let tutor_available_for_week = self.id_schedule_dict[tutor_id]!.weekly_availability[formatted_date.to_week_number()]!
                if formatted_date > today && tutor_available_for_week{
                    all_available_times[i] = sessionTime(sessionDate: formatted_date, string_date: string_date, tutor: tutor_id, tutor_name: tutor_name, timeframe: Timeframe(timeframe), id: i)
                }
            }
        }
        return all_available_times
    }

    private func return_sorted_schedule(schedule: [Int : sessionTime]) -> Array<sessionTime>{
        return Array(schedule.values).sorted{
            return $0.sessionDate < $1.sessionDate
        }
    }
    
    private func build_final_time_list(tutor:String, date:Date,college_class:String) -> Array<sessionTime>{
        let date_convert:String = date.to_int_format()
        if tutor != "Any"{
            //Get times available for specific tutor
            let tutor_name = self.get_tutor_name(id: tutor)
            if let timeframe = self.id_schedule_dict[tutor]!.schedule[date_convert]{
                //DICT index -> Session time with times for specifict tutors
                let availableTimes = build_available_times(time_frame: timeframe, duration: 2, date: date, string_date: date_convert, tutor_id: tutor, tutor_name: tutor_name)
                return return_sorted_schedule(schedule: availableTimes)
            }
            
            return []
        }
        else{
            //Get times for all tutors
            if let tutorsID_for_class = classes_dict[college_class]{
                //Gets all tutors for that day
                var all_tutors_schedule:[TutorSchedule] = []
                tutorsID_for_class.forEach{tutor in
                    if self.id_schedule_dict[tutor]!.schedule[date_convert] != nil{
                        //If the tutor has a schedule for that day
                        all_tutors_schedule.append(TutorSchedule(old: self.id_schedule_dict[tutor]!, specific_date: date_convert))
                    }
                }
                
                //Creating schedule for all tutors
                var final_random_tutor_schedule = [Int:sessionTime]()
                all_tutors_schedule.forEach{ tutor_schedule in
                    let tutor_name = self.get_tutor_name(id: tutor_schedule.id)
                    let availableTimes = build_available_times(
                        time_frame: tutor_schedule.schedule[date_convert]!,
                        duration: 2,
                        date: date,
                        string_date: date_convert,
                        tutor_id: tutor_schedule.id,
                        tutor_name: tutor_name)
                    availableTimes.forEach{time in
                        if final_random_tutor_schedule[time.key] == nil{
                            final_random_tutor_schedule[time.key] = time.value
                        }
                    }
                }
                return return_sorted_schedule(schedule: final_random_tutor_schedule)
            }
            return []
        }
    }
    
    func time_frame_to_date(time_slot:Timeframe, date:Date) -> Date {
        let ind = time_slot.get_first_session_index()!
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.hour = Timeframe.ind_to_hour(ind: ind)
        components.minute = Timeframe.ind_to_min(ind: ind)
        let start_time = Calendar.current.date(from: components)
        return start_time!
    }
}

struct TutorSchedule: Codable, Identifiable, Hashable {
//    Tutor ID
    var id:String = ""
//    Date:Time bitstring
    var schedule: [String:Timeframe] = [:]
    var weekly_availability: [String:Bool] = [:]
//    Classes available
    var classes: Array<String> = []
    var tutorName:String
    
    var schedule_to_string: [String:String]{
        var new_dict = [String:String]()
        for key in schedule.keys{
            new_dict[key] = schedule[key]!.to_string
        }
        return new_dict
    }
    
    init(id:String, available_classes: Array<String>, name: String){
        self.id = id
        self.classes = available_classes
        self.tutorName = name
    }
    
    init(old: TutorSchedule, specific_date: String){
        self.id = old.id
        self.classes = old.classes
        self.schedule[specific_date] = old.schedule[specific_date]!
        self.tutorName = old.tutorName
        
    }
    
    mutating func update_schedule(_ content: [String:Any]){
        var weeks_temp = [String:temp_week_schedule]()
        for key in content.keys{
            if key.count == 8{
                //If it is a schedule
                let frame = Timeframe(content[key]! as! String)
                schedule[key] = frame
                let date = Date.from_int_format(original: key)
                let week = date.to_week_number()
                if weeks_temp[week] == nil{
                    weeks_temp[week] = temp_week_schedule()
                }
                weeks_temp[week]?.current += frame.count_sessions_in_frame()
            }
            else if key.count == 6{
                let max_sessions = Int(content[key]! as! String)!
                if weeks_temp[key] == nil{
                    weeks_temp[key] = temp_week_schedule()
                }
                weeks_temp[key]?.max = max_sessions
            }
        }
        for week in weeks_temp.keys{
            weekly_availability[week] = weeks_temp[week]!.max > weeks_temp[week]!.current
        }
    }
    
    func get_all_days_in_week(week_num: String) -> [Date]{
        let week = Int(week_num.prefix(2))!
        let year = Int(week_num.suffix(4))!
        let calendar = Calendar.current
        let dateComponents = DateComponents(calendar: calendar, year: year, weekday: 1, weekOfYear: week)
        var list_of_days = [Date]()
        let first_date = calendar.date(from: dateComponents)!
        var start = Calendar.current.date(byAdding: .day, value: 0, to: first_date)!
        let end = Calendar.current.date(byAdding: .day, value: 7, to: first_date)!
        while start < end{
            list_of_days.append(start)
            start = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        }
        return list_of_days
    }
    //FIX CALENDAR AVAILABILITY COLORS
    
}

struct temp_week_schedule{
    var current: Int = 0
    var max: Int = 4
}
struct sessionTime: Hashable, Identifiable{
    //Date in the right format
    var sessionDate:Date
    //Date in the int-string format
    var string_date:String
    //Tutor id
    var tutor:String
    var tutor_name:String
    //bitstring
    var timeframe:Timeframe
    var id: Int
    var selected = false
    
    var time_string: String{
        sessionDate.to_time()
    }
    
    func is_the_same(rhs: sessionTime) -> Bool{
        return sessionDate == rhs.sessionDate && self.tutor == rhs.tutor
    }
}
