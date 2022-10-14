//
//  Constants.swift
//  SpartanTutors
//
//  Created by Leo on 7/11/22.
//
import Foundation
import SwiftUI

struct TimeConstants{
    static let time_interval = 15
    static let units_in_session = 60*2/time_interval
    static let times_in_hour = 60/time_interval
    static let times_in_day:Int = (DayConstants.ending_time-DayConstants.starting_time)*(60/time_interval)
}

struct sessionConstants{
    static let price = [
        1.0: 35.0,
        1.5: 50.0,
        2.0: 60.0
    ]
    
    static let tutor_pay = 20.0
    static let make_unavailable_before_hours = 1
}
struct DayConstants{
    static let starting_time = 8
    static let ending_time = 22
}

struct FontConstants{
    static var calendar_day_scale:CGFloat = 1.6
}

struct SmallButtonLegend: ButtonStyle {
    var color_main = Color(red: 0.6, green: 0.6, blue: 0.6)
    var color_pressed = Color(red: 0.5, green: 0.5, blue: 0.5)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .padding(5)
            .background(configuration.isPressed ? color_pressed : color_main)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct Colors{
    static let green_dark: Color = Color(red: 0.2, green: 0.51, blue: 0.2)
    static let red_dark: Color = Color(red: 204/255, green: 43/255, blue: 43/255)
    static let gray_tone:Double = 242/255
    static let gray_row: Color = Color(red: 214/255, green: 206/255, blue: 203/255)
    static let pending_yellow: Color = Color(red: 199/255, green: 143/255, blue: 14/255)
    static let tutor_gray_row: Color = Color(red: gray_tone, green: gray_tone, blue: gray_tone)
    static let light_blue: Color = Color(red: 59/255, green: 62/255, blue: 237/255)
}

func get_Status_Color(detail:Session) -> Color{
    let status = detail.status
    if status == "Approved"{
        return Colors.green_dark
    }
    else if status == "Pending"{
        return Colors.pending_yellow
    }
    return Colors.red_dark
}

func get_Status_Color_string(detail:String) -> Color{
    let status = detail
    if status == "Approved"{
        return Color.green
    }
    else if status == "Pending"{
        return Color.yellow
    }
    return Color.red
}
