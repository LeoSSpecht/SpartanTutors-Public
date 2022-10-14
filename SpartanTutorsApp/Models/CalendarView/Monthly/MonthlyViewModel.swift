//
//  MonthlyViewModel.swift
//  AnimationTest
//
//  Created by Leo on 8/19/22.
//

import Foundation
import SwiftUI

class MonthlyCalendarVM: ObservableObject{
    @Published var model = MonthlyModel()
    @Published var month_index = 0
    @Published var selected_dates = [Date]()

    var days_list: [String: Array<dayModel>] {
        model.days_list
    }
    
    var max_months: Int{
        model.months.count
    }
    
    var cur_month_key: String{
        return model.months[month_index]
    }
    
    var month_selected:String{
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        let month_dates = days_list[month_key(month_index)]!
        let start_month = df.string(from: month_dates.first(where: {$0.value != 0})!.date)
        return start_month
    }
    
    var is_there_next_month: Bool{
        return month_index < model.months.count-1
    }
    
    var is_there_previous_month: Bool{
        return month_index > 0
    }
    
    func change_month(_ to: Int){
        if to > 0{
            if is_there_next_month{
                month_index += 1
            }
        }
        else{
            if is_there_previous_month{
                month_index -= 1
            }
        }
    }
    
    func month_key(_ ind: Int) -> String{
        model.months[ind]
    }
    
    func choose(_ ind: Int){
        if model.choose(ind, month: cur_month_key){
            //Add to list
            selected_dates.append(days_list[cur_month_key]![ind].date)
        }
        else{
            //Remove from list
            let date_to_remove = days_list[cur_month_key]![ind].date
            let ind = selected_dates.firstIndex(where: {$0 == date_to_remove})!
            selected_dates.remove(at: ind)
        }
    }
    
    func clear_dates(){
        for date in selected_dates{
            let month = date.format("MMYYYY")
            if let list = model.days_list[month]{
                let ind = list.firstIndex(where: {$0.date == date})!
                _ = model.choose(ind, month: month)
            }
        }
        selected_dates.removeAll()
    }
}
