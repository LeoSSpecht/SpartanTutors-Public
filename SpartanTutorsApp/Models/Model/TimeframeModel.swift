//
//  TimeframeModel.swift
//  SpartanTutors
//
//  Created by Leo on 7/11/22.
//

import Foundation

struct Timeframe: Codable, Hashable{
    var data = Array(repeating: 0, count: TimeConstants.times_in_day)
//    var time_zone = TimeZone.current.secon
    
    var to_string:String{
        self.data.map{
            String($0)
        }.joined()
    }
    
    init(){
        
    }
    
    init(_ new_data:String){
        self.update_from_string(new_data)
    }
    
    init(_ new_data:Array<Int>){
        self.data = new_data
    }
    
    init(_ new_timeframe: Timeframe, ignore_sessions:Bool = false){
        if ignore_sessions{
            var new_time = new_timeframe
            for i in new_time.data.indices{
                if new_time.data[i] == 2{
                    new_time.data[i] = 0
                }
            }
            self.data = new_time.data
        }
        else{
            self.data = new_timeframe.data
        }
    }
    
    mutating func update_from_string(_ new_time: String){
        self.data.removeAll()
        for i in new_time{
            let time_frame_value = Int(String(i))
            self.data.append(time_frame_value!)
        }
    }
    
    mutating func update_whole_day(_ new_data:Array<Int>){
        self.data = new_data
    }
    
    mutating func update_time(ind:Int){
        if self.data[ind] == 1{
            self.data[ind] = 0
        }
        else if self.data[ind] == 0{
            self.data[ind] = 1
        }
    }
    
    mutating func cancel_session_time(ind:Int){
        self.data[ind] = 1
    }
    
    mutating func clear_schedule(){
        for i in self.data.indices{
            if self.data[i] == 1{
                self.data[i] = 0
            }
        }
    }
    
    mutating func full_schedule(){
        for i in self.data.indices{
            if self.data[i] == 0{
                self.data[i] = 1
            }
        }
    }
    
    mutating func update_time_for_new_session(session_time: Timeframe) -> Bool{
        for i in session_time.data.indices{
            if session_time.data[i] == 2{
                if self.data[i] != 1{
                    return false
                }
                else if self.data[i] == 1{
                    self.data[i] = 2
                }
            }
        }
        return true
    }

    static func ind_to_min(ind:Int) -> Int{
        if ind % 4 == 0{
            return 0
        }
        else if ind % 2 == 1{
            if ind % 4 == 1{
                return 15
            }
            else{
                return 45
            }
        }
        return 30
    }
    
    static func ind_to_hour(ind: Int) -> Int{
        let inital_time = DayConstants.starting_time
        return inital_time+ind/4
    }
    
    static func get_time_from_frame(ind: Int) -> String{
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        components.hour = ind_to_hour(ind: ind)
        components.minute = ind_to_min(ind: ind)
        let start_time = Calendar.current.date(from: components)
        return "\(start_time!.to_time())"
    }
    
    func get_frame_as_date(date: Date, ind: Int) -> Date{
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.hour = Timeframe.ind_to_hour(ind: ind)
        components.minute = Timeframe.ind_to_min(ind: ind)
        let start_time = Calendar.current.date(from: components)!
        return start_time
    }
    
    func get_duration() -> Int{
        var ind = self.get_first_session_index()!
        var counter = 0
        while ind < 56 && self.data[ind] == 2 {
            counter += 1
            ind += 1
        }
        return counter/TimeConstants.times_in_hour
    }
    
    func get_start_end_time() -> String{
        let ind = self.get_first_session_index()!
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        components.hour = Timeframe.ind_to_hour(ind: ind)
        components.minute = Timeframe.ind_to_min(ind: ind)
        let start_time = Calendar.current.date(from: components)
        components.hour = components.hour! + self.get_duration()
        let end_time = Calendar.current.date(from: components)
        return "\(start_time!.to_time()) - \(end_time!.to_time())"
    }
    
    func is_valid_to_update() -> Bool{
        var counter = 0
        var isValid = true
        for i in self.data{
            if i == 1 || i == 2{
                counter += 1
            }
            else if i == 0{
                if counter < TimeConstants.units_in_session && counter > 0{
                    isValid = false
                }
                else{
                    counter = 0
                }
            }
        }
        return isValid
    }
    
    func get_first_session_index() -> Int?{
        return self.data.firstIndex(where: {$0 == 2})
    }
    
    func is_there_availability_in_day(date_string:String) ->Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let date = dateFormatter.date(from:date_string)
        var isAvailable = false
        let duration = 2
        
        let calendar = Calendar.current
        let today = calendar.date(byAdding: .hour, value: sessionConstants.make_unavailable_before_hours, to: Date())!
        
        for i in 0..<self.data.count - duration*TimeConstants.times_in_hour+1{
            let session_time = self.get_frame_as_date(date: date!, ind: i)
            if self.is_available_in_index(ind: i, duration: 2) && session_time > today{
                isAvailable = true
            }
        }
        return isAvailable
    }
    
    func is_available_in_index(ind:Int, duration:Int) ->Bool{
        let indexes = TimeConstants.times_in_hour*duration
        if self.data[ind] == 1{
            if Array(self.data[ind..<ind+indexes]) == Array(repeating: 1, count: indexes){
                return true
            }
        }
        return false
    }
    
    func count_sessions_in_frame() -> Int{
        var sessions = 0
        var old = 0
        for i in data{
            if i == 2 && old != 2{
                sessions += 1
            }
            old = i
        }
        return sessions
    }
    
    mutating func make_available_on_sessions(){
        for i in data.indices{
            if data[i] == 2{
                data[i] = 1
            }
        }
    }
    
    func copy(_ from: Timeframe?) -> String{
        var original_copy = self
        if let new = from{
            for i in new.data.indices{
                if original_copy.data[i] != 2{
                    original_copy.data[i] = new.data[i]
                }
            }
            return original_copy.to_string
        }
        return self.to_string
    }
    
    mutating func change_session_duration(duration: Double = 1){
        let first_index = self.get_first_session_index()!
        //Check if it has 8 blocks
        var isFullBlock = true
        for i in self.data[first_index..<first_index+8]{
            if i != 2{
                isFullBlock = false
            }
        }
        
        //If it has change the last 4 to be 0
        if isFullBlock{
            for i in first_index+Int(4*duration)..<first_index+8{
                self.data[i] = 0
            }
        }
    }
    
    mutating func update_tutor_schedule_duration(sessionTime: Timeframe, duration: Double = 1.0){
        let first_index = sessionTime.get_first_session_index()!
        //Check if it has 8 blocks
        var counter = 0
        for i in first_index..<first_index+8{ 
            if counter > Int(duration*4)-1{
                self.data[i] = 1
            }
            counter += 1
        }
    }
    
    mutating func append_tutor_schedule(_ new: Timeframe){
        for i in data.indices{
            let current_value = data[i]
            if current_value != 1{
                let time_frame_value = new.data[i]
                if time_frame_value == 1{
                    data[i] = 1
                }
            }
        }
    }
}
