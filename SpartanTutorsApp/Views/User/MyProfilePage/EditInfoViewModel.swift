//
//  EditInfoViewModel.swift
//  SpartanTutors
//
//  Created by Leo on 7/27/22.
//

import Foundation
import FirebaseFirestore
import SwiftUI
class EditInfoStudentViewModel: ObservableObject{
    @Published var yearStatus: String = "No change"
    @Published var major: String = ""
    @Published var phone: String = ""
    @Published var sms_check: Bool = false
    @Published var finished_update: Bool = false
    @Published var error_update = false
    
    private var db = Firestore.firestore()
    
    func clear_changes(){
        yearStatus = "No change"
        major = ""
        phone = ""
    }
    var formatted_phone:Binding<String> {
        Binding<String>(
            get: {
                self.phone.applyPatternOnNumbers(pattern: "(###) ###-####", replacementCharacter: "#")
                
            },
            set: {
                self.phone = $0.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
            }
        )
    }
    
    var at_least_one_change:Bool{
        yearStatus != "No change" || !major.isEmpty || (!phone.isEmpty && phone.is_valid_phone)
    }
    
    func update_data(id:String){
        var dict = [String:String]()
        
        if yearStatus != "No change"{
            dict["yearStatus"] = yearStatus
        }
        if !major.isEmpty{
            dict["major"] = major
        }
        if !phone.isEmpty && phone.is_valid_phone{
            dict["phone"] = phone
        }
        
        db.collection("users").document(id).updateData(dict){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.error_update = true
            } else {
                print("Document successfully updated")
                self.finished_update = true
                self.clear_changes()
                
            }
        }
    }
//    Tutor
//      Major
//      Phone
//      Classes
//      Venmo
//      YearStatus
//      Zoom link
    
//    Student
//      Major
//      Phone
//      Year status
}
