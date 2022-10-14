//
//  DateFormatters.swift
//  SpartanTutors
//
//  Created by Leo on 7/11/22.
//

import Foundation


extension Date {
    func format(_ new_format: String) -> String{
        let df = DateFormatter()
        df.dateFormat = new_format
        let formatted = df.string(from: self)
        return formatted
    }
    
    func to_time() -> String{
        let df = DateFormatter()
        df.dateFormat = "hh:mm a"
        df.amSymbol = "AM"
        df.pmSymbol = "PM"
        let formatted = df.string(from: self)
        return formatted
    }

    func to_WeekDay_date() -> String{
        let df = DateFormatter()
        df.dateFormat = "eee - MM/dd/YY"
        let formatted = df.string(from: self)
        return formatted
    }

    func to_int_format() -> String{
        let df = DateFormatter()
        df.dateFormat = "YYYYMMdd"
        let formatted = df.string(from: self)
        return formatted
    }
    
    func to_google_calendar_format() -> String{
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd'T'HHmmss"
        let formatted = df.string(from: self)
        return formatted
    }
    
    func to_week_number() -> String{
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        let weekOfYear = calendar.component(.weekOfYear, from: self)
        return String(format: "%02d\(self.format("YYYY"))", weekOfYear)
    }
    
    static func from_int_format(original:String) -> Date{
        let dateFormatter = DateFormatter()
        // Set Date Format
        dateFormatter.dateFormat = "YYYYMMdd"
        // Convert String to Date
        return dateFormatter.date(from: original)!
        
    }
}
