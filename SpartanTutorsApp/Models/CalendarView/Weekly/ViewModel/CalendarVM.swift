//
//  CalendarVM.swift
//  AnimationTest
//
//  Created by Leo on 7/9/22.
//

import Foundation

class calendarVM: ObservableObject{
    @Published var model = calendarModel()
//    @Published var startingIndex = 0
    
    init(){
    }
    
    init(show_more_dates: Bool){
        self.model = calendarModel(more_dates: true)
    }
    //CHANGE INDEX OF SELECTION AND WEEK INDEX
    var startingIndex: Int{
        get{
            model.week_selection_index
        }
        set{ newValue
            model.change_week(newValue)
        }
    }
    
    var week_index: Int{
        startingIndex*7
    }
    
    var week_days: Array<dayModel>{
        Array(model.days_list[week_index...ind_end])
    }
    
    var max_week_index: Int{
        (model.days_list.count-1)/7
    }
    
    var is_there_next_week: Bool{
        let maxIndex = (model.days_list.count-1)/7
        return startingIndex < maxIndex
    }
    
    var is_there_previous_week: Bool{
        startingIndex > 0
    }
    
    var all_days: [dayModel]{
        model.days_list
    }
    
    var month_selected:String{
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        let start_month = df.string(from: model.days_list[ind_begin].date)
        let end_month = df.string(from: model.days_list[ind_end].date)
        if start_month == end_month{
            return start_month
        }
        else{
            return "\(start_month) - \(end_month)"
        }
    }
    
    var ind_begin: Int{
        self.week_index
    }
    
    var ind_end: Int{
        let ind_max = self.model.days_list.count-1
        return ind_begin+6 < ind_max ? ind_begin+6 : ind_max
    }
    
    func ind_end_func(week_index:Int) -> Int{
        let ind_max = self.model.days_list.count-1
        return week_index*7+6 < ind_max ? week_index*7+6 : ind_max
    }
    
    func choose(_ ind: Int) -> Bool{
        return model.choose(ind)
    }
    
    func change_week(to: Int){
//        print("changed week")
        if to < 0{
            if startingIndex > 0{
                startingIndex -= 1
            }
        }
        else{
            let maxIndex = (model.days_list.count-1)/7
            if startingIndex < maxIndex{
                startingIndex += 1
            }
        }
    }
    
    func next_available_day(availability: [String:Bool]) -> Date?{
        for day in model.days_list{
            if let available_date = availability[day.date.to_int_format()], available_date{
                if self.choose(day.index){
                    let week_index = day.index/7
                    if week_index <= (model.days_list.count-1)/7 && week_index >= 0{
                        startingIndex = week_index
                    }
                    return day.date
                }
            }
        }
        return nil
    }
}
