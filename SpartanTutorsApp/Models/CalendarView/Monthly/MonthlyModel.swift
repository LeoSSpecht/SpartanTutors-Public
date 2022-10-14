//
//  MonthlyModel.swift
//  AnimationTest
//
//  Created by Leo on 8/19/22.
//

import Foundation

struct MonthlyModel{
    var today:Date = Date()
    var days_list:[String: Array<dayModel>] = [:]
    var months: [String] = []
    
    init(){
        build_date()
    }
    
    mutating func build_date(){
        var months = [String]()
        var month_day: [String: Array<dayModel>] = [:]
        
        let today = self.today
        let calendar = Calendar.current
        let first_day_month = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: today))!

        var start  = first_day_month
        let end = Calendar.current.date(byAdding: .month, value: 1, to: today)!
        var count = 0
        while start < end{
            let month = start.format("MMYYYY")
            if month_day[month] == nil{
                count = 0
                //Create dicitionary
                months.append(month)
                month_day[month] = []
                //Fill with blanks
                let weekday_first_day = Calendar.current.component(.weekday, from: start)
                for _ in 0..<weekday_first_day-1{
                    month_day[month]?.append(
                        dayModel(date: Date(), isValid: false, index: 0, isSelected: false, value: 0)
                    )
                    count += 1
                }
            }
            
            var isValid = true
            let isSelected = false
            if start < today{
                isValid = false
            }
            if calendar.isDate(start, inSameDayAs: today){
                isValid = true
            }
            let day = dayModel(date: start, isValid: isValid, index: count, isSelected: isSelected, value: count)
            
            month_day[month]?.append(day)
            start = Calendar.current.date(byAdding: .day, value: 1, to: start)!
            count += 1
        }
        
        //Fills
        for key in month_day.keys{
            let remainder = 42 - month_day[key]!.count
            for _ in 0..<remainder{
                month_day[key]?.append(
                    dayModel(date: Date(), isValid: false, index: 0, isSelected: false, value: 0)
                )
            }
        }
        
        days_list = month_day
        self.months = months
    }
    
    mutating func choose(_ ind:Int, month: String) -> Bool{
        if days_list[month]![ind].isValid
        {
            days_list[month]![ind].isSelected.toggle()
            return days_list[month]![ind].isSelected
        }
        return false
    }
}

//static func get_all_days_list() -> [String]{
//    var list_of_days = [String]()
//    let first_date = Date()
//    var start = Calendar.current.date(byAdding: .day, value: 0, to: first_date)!
//    let end = Calendar.current.date(byAdding: .month, value: 1, to: first_date)!
//    while start < end{
//        list_of_days.append(start.to_int_format())
//        start = Calendar.current.date(byAdding: .day, value: 1, to: start)!
//    }
//    return list_of_days
//}
  
