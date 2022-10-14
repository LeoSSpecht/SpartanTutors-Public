//
//  EditInfoViewModel.swift
//  SpartanTutors
//
//  Created by Leo on 7/27/22.
//

import Foundation
import FirebaseFirestore
import SwiftUI
class EditInfoTutorViewModel: ObservableObject{
    @Published var yearStatus: String = "No change"
    @Published var major: String = ""
    @Published var phone: String = ""
    @Published var venmo: String = ""
    @Published var zoom_link: String = ""
    @Published var zoom_password: String = ""
    @Published var finished_update: Bool = false
    @Published var error_update = false
    @Published var class_model = classSelectionList()
    
    init(){
        getAllOfferedClasses()
    }
    
    private var db = Firestore.firestore()
    
    func clear_fields(){
        self.yearStatus = "No change"
        self.major = ""
        self.phone = ""
        self.venmo = ""
        self.zoom_link = ""
        self.zoom_password = ""
        class_model.empty()
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
        yearStatus != "No change" ||
        !major.isEmpty ||
        (!phone.isEmpty && phone.is_valid_phone) ||
        !onlySelected.isEmpty ||
        !venmo.isEmpty ||
        !zoom_link.isEmpty ||
        !zoom_password.isEmpty
    }
    
    func update_data(id:String){
        var dict = [String:Any]()
        
        if yearStatus != "No change"{
            dict["yearStatus"] = yearStatus
        }
        if !major.isEmpty{
            dict["major"] = major
        }
        if !venmo.isEmpty{
            dict["venmo"] = venmo
        }
        if !onlySelected.isEmpty{
            dict["classes"] = onlySelected
        }
        if !phone.isEmpty && phone.is_valid_phone{
            dict["phone"] = phone
        }
        if !zoom_link.isEmpty{
            let formatted_id = zoom_link.replacingOccurrences(of: " ", with: "")
            let formatted_link = "https://msu.zoom.us/j/\(formatted_id)"
            dict["zoom_link"] = formatted_link
        }
        if !zoom_password.isEmpty{
            dict["zoom_password"] = zoom_password
        }
        db.collection("users").document(id).updateData(dict){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.error_update = true
            } else {
                print("Document successfully updated")
                self.finished_update = true
                self.clear_fields()
            }
        }
    }
    
    var classList:Array<classSelection>{
        class_model.availableClasses
    }
    
    var class_dict: [String: Array<classSelection>]{
        var temp = [String: Array<classSelection>]()
        for class_ in classList{
            let class_group = String(class_.id.split(separator: " ").first!)
            if temp[class_group] == nil{
                temp[class_group] = []
            }
            temp[class_group]!.append(class_)
        }
        return temp
    }
    
    var onlySelected:Array<String>{
        let filtered_classes = class_model.availableClasses.filter({$0.isSelected})
        return filtered_classes.map{
            $0.id
        }
    }
    
    func select_group(_ group: String){
        class_model.select_group(group)
    }
    
    func update_selection(_ selection:classSelection){
        class_model.select(selection)
    }
    
    func getAllOfferedClasses(){
        db.collection("classesAvailable").document("classes").getDocument{result, err in
            if let result = result, result.exists{
                let data = result.data()!
                let availableClasses = data["classes"] as! Array<String>
                let classesAvailable = availableClasses.map{ selection in
                    classSelection(id: selection)
                }
                self.class_model.create(classesAvailable)
            }
            else{
                print("No available classes were found")
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
