//
//  sessionModels.swift
//  SpartanTutors
//
//  Created by Leo on 6/21/22.
//

import Foundation
import FirebaseFirestore
struct Session: Identifiable, Hashable{
    var id: String = ""
    var student_uid:String
    var tutor_uid:String
    var date: Date
    var time_slot_obj: Timeframe = Timeframe()
    var college_class: String
//        Possible: Pending, Approved, Canceled
    var status: String = "Pending"
    var paid: Bool = false
    var refunded: Bool = false
    var duration: Double = 2.0
    var paid_tutor: Bool = false
    var created_at = Date()
    var confirmed_at:Date? = nil
    var time_slot: String{
        time_slot_obj.to_string
    }
    var tutor_running_late = false
    var student_running_late = false
    
//  Pop ups for rows
    var student_confirm_cancel = false
    var confirm_late = false
    var confirm_session_admin = false
    var cancel_session_admin = false
    var make_1h = false
    var make_refund = false
    var make_1_5h = false
    
    
    init(_ content: [String: Any]){
        id = content["id"] as! String
        student_uid = content["student_uid"] as! String
        tutor_uid = content["tutor_uid"] as! String
        self.date = content["date"] as! Date
        time_slot_obj = Timeframe(content["time_slot"] as! String)
        college_class = content["college_class"] as! String
        if((content["status"]) != nil){
            status = content["status"] as! String
        }
        if((content["paid"]) != nil){
            paid = content["paid"] as! Bool
        }
        if((content["refunded"]) != nil){
            refunded = content["refunded"] as! Bool
        }
        if((content["duration"]) != nil){
            duration = content["duration"] as! Double
        }
        if((content["tutor_running_late"]) != nil){
            tutor_running_late = content["tutor_running_late"] as! Bool
        }
        if((content["student_running_late"]) != nil){
            student_running_late = content["student_running_late"] as! Bool
        }
        if((content["paid_tutor"]) != nil){
            paid_tutor = content["paid_tutor"] as! Bool
        }
        if((content["created_at"]) != nil){
            let stamp = content["created_at"] as! Timestamp
            created_at = stamp.dateValue()
        }
        if((content["confirmed_at"]) != nil){
            confirmed_at = content["confirmed_at"] as? Date
        }
    }
    
    mutating func toggle_confirmation(_ of: ConfirmOptions){
        switch of {
        case .cancel:
            student_confirm_cancel.toggle()
        case .late:
            confirm_late.toggle()
        case .confirm:
            confirm_session_admin.toggle()
        case .cancel_admin:
            cancel_session_admin.toggle()
        case .make_1h:
            make_1h.toggle()
        case .make1_5h:
            make_1_5h.toggle()
        case .make_refund:
            make_refund.toggle()
        default:
            break
        }
    }
    
    mutating func cancel_confirmations(){
        student_confirm_cancel = false
        confirm_late = false
    }
    
    func generate_dict() -> [String:Any]{
        return [
            "id": id,
            "student_uid":student_uid,
            "tutor_uid":tutor_uid,
            "date":date,
            "college_class":college_class,
            "status":status,
            "paid":paid,
            "refunded":refunded,
            "duration":duration,
            "paid_tutor":paid_tutor,
            "time_slot":time_slot,
            "tutor_running_late":tutor_running_late,
            "student_running_late":student_running_late,
            "created_at": created_at
        ]
    }
    
    func get_time_frame() -> String {
        if let ind = self.time_slot_obj.data.firstIndex(where: {$0 == 2}){
            var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.date)
            components.hour = Timeframe.ind_to_hour(ind: ind)
            components.minute = Timeframe.ind_to_min(ind: ind)
            let start_time = Calendar.current.date(from: components)
            let end_time = Calendar.current.date(byAdding: .minute, value: Int(60*duration), to: start_time!)
//            let end_time = Calendar.current.date(from: components)
            return "\(start_time!.to_time()) - \(end_time!.to_time())"
        }
        return ""
    }
    
    func get_calendar_date() -> String {
        if let ind = self.time_slot_obj.data.firstIndex(where: {$0 == 2}){
            var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.date)
            components.hour = Timeframe.ind_to_hour(ind: ind)
            components.minute = Timeframe.ind_to_min(ind: ind)
            let start_time = Calendar.current.date(from: components)
//            components.hour = Timeframe.ind_to_hour(ind: ind) + duration
//            let end_time = Calendar.current.date(from: components)
            let end_time = Calendar.current.date(byAdding: .minute, value: Int(60*duration), to: start_time!)
            return "\(start_time!.to_google_calendar_format())/\(end_time!.to_google_calendar_format())"
        }
        return ""
    }
    
    mutating func update_from_session(_ new:Session){
        let old_cancel = self.student_confirm_cancel
        let old_late = self.confirm_late
        self = new
        self.confirm_late = old_late
        self.student_confirm_cancel = old_cancel
    }
}

enum ConfirmOptions {
    case cancel
    case late
    case pay
    case confirm
    case cancel_admin
    case make_1h
    case make1_5h
    case make_refund
}
