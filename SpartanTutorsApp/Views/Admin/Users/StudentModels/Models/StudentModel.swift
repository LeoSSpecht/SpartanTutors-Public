//
//  AllStudentsModel.swift
//  SpartanTutors
//
//  Created by Leo on 8/16/22.
//
import Foundation
struct Student: Identifiable, Hashable{
    var id: String = ""
    var name:String
    var phone:String
    var venmo = ""
    
    var confirm_paid = false
    
    init(content: [String:Any], id:String){
        self.id = id
        name = content["name"] as? String ?? "No name"
        phone = content["phone"] as? String ?? "No Phone"
        if content["venmo"] != nil{
            venmo = content["venmo"] as! String
        }
    }
    
    mutating func toggle_confirmation(_ of: ConfirmOptions){
        switch of {
        case .pay:
            confirm_paid.toggle()
        default:
            break
        }
    }
}
