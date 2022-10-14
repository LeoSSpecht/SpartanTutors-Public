//
//  TutorModel.swift
//  SpartanTutors
//
//  Created by Leo on 7/8/22.
//

import Foundation
import FirebaseFirestore
struct Tutor:  Codable, Identifiable, Hashable{
    var id: String = ""
    var name:String
    var major:String
    var phone:String
    var yearStatus:String
    var created_at: Date
    var role = "tutor"
    var firstSignIn = false
    var approved = false
    var classes:Array<String> = []
    var venmo = ""
    var zoom_link = ""
    var TutorFirstSignIn = true
    var confirm_payment = false
    
    
    init(student_keys: user_first_time){
        id = student_keys.id
        name = student_keys.name.replacingOccurrences(of: "TuToR", with: "")
        major = student_keys.major
        phone = student_keys.phone
        yearStatus = student_keys.yearStatus
        created_at = student_keys.created_at
    }
    
    init(id: String, dict: [String: Any]){
        self.id = id
        self.name = ""
        self.phone = ""
        self.major = ""
        self.yearStatus = ""
        if let name = dict["name"] {
            self.name = name as! String
        }
        if let major = dict["major"] {
            self.major = major as! String
        }
        if let phone = dict["phone"] {
            self.phone = phone as! String
        }
        if let yearStatus = dict["yearStatus"] {
            self.yearStatus = yearStatus as! String
        }
        if let firstSignIn = dict["firstSignIn"] {
            self.firstSignIn = firstSignIn as! Bool
        }
        if let approved = dict["approved"] {
            self.approved = approved as! Bool
        }
        if let classes = dict["classes"] {
            self.classes = classes as! Array<String>
        }
        if let venmo = dict["venmo"] {
            self.venmo = venmo as! String
        }
        if let zoom_link = dict["zoom_link"] {
            self.zoom_link = zoom_link as! String
        }
        if let TutorFirstSignIn = dict["TutorFirstSignIn"] {
            self.TutorFirstSignIn = TutorFirstSignIn as! Bool
        }
        if let created = dict["created_at"] {
            var stamp = created as! Timestamp
            self.created_at = stamp.dateValue()
        }
        else{
            self.created_at = Date()
        }
    }
    
    mutating func toggle_confirmation(_ of: ConfirmOptions){
        switch of {
        case .pay:
            confirm_payment.toggle()
        default:
            break
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case major
        case phone
        case yearStatus
        case role
        case firstSignIn
        case approved
        case classes
        case venmo
        case zoom_link
        case TutorFirstSignIn
        case created_at
    }
}
//
//struct TutorSummary{
//    var id:String
//    var name:String
//    var zoom_link:String
//}

