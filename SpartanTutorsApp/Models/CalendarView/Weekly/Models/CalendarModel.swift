//
//  CalendarModel.swift
//  AnimationTest
//
//  Created by Leo on 7/9/22.
//

import Foundation

struct calendarModel{
    var today:Date
    var allow_previous_dates = false
    var days_list:[dayModel] = []
    var index_of_selection:Int = 0
    
    var week_selection_index:Int = 0
    
    mutating func change_index(_ to: Int){
        index_of_selection = to
    }
    
    mutating func change_week(_ to: Int){
        week_selection_index = to
    }
    
    static func get_all_days_list() -> [String]{
        var list_of_days = [String]()
        let first_date = Date()
        var start = Calendar.current.date(byAdding: .day, value: 0, to: first_date)!
        let end = Calendar.current.date(byAdding: .month, value: 1, to: first_date)!
        while start < end{
            list_of_days.append(start.to_int_format())
            start = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        }
        return list_of_days
    }
        
    init(){
        today = Date()
        generate_all_days()
    }
    
    init(more_dates: Bool){
        today = Date()
        self.allow_previous_dates = more_dates
        generate_all_days()
    }
    
    mutating func generate_all_days(){
        let day_of_week = Calendar.current.component(.weekday, from: self.today) // 1 Sun -> 7 Sat
        var start = Calendar.current.date(byAdding: .day, value: -day_of_week+1, to: today)!
        
        if allow_previous_dates{
            let new_start = Calendar.current.date(byAdding: .day, value: -60, to: today)!
            let day_of_week = Calendar.current.component(.weekday, from: new_start) // 1 Sun -> 7 Sat
            start = Calendar.current.date(byAdding: .day, value: -day_of_week+1, to: new_start)!
        }
        
        var end = Calendar.current.date(byAdding: .month, value: 1, to: today)!
        let end_day_week = Calendar.current.component(.weekday, from: end) // 1 Sun -> 7 Sat
        end = Calendar.current.date(byAdding: .day, value: 7-end_day_week+1, to: end)!
        var count = 0
        while start < end{
            var isValid = true
            var isSelected = false
            
            if start < today{
                isValid = allow_previous_dates
            }
            
            if start == today{
                isSelected = true
                index_of_selection = count
                week_selection_index = index_of_selection/7
            }
            days_list.append(dayModel(date: start, isValid: isValid, index: count, isSelected: isSelected))
            start = Calendar.current.date(byAdding: .day, value: 1, to: start)!
            count += 1
        }
    }
    
    mutating func choose(_ ind:Int) -> Bool{
        if ind != index_of_selection
            && days_list[ind].isValid
        {
            days_list[index_of_selection].isSelected = false
            days_list[ind].isSelected = true
            index_of_selection = ind
            return true
        }
        return false
    }
}

struct dayModel: Hashable{
    var date: Date
    var isValid: Bool
    var index: Int
    var isSelected = false
    var value = 0
    
    var day_number: String{
        let df = DateFormatter()
        df.dateFormat = "d"
        return df.string(from: date)
    }
}
