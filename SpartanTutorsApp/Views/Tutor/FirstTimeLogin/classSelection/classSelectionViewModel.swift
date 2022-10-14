//
//  classSelectionViewModel.swift
//  SpartanTutors
//
//  Created by Leo on 6/30/22.
//

import Foundation
import FirebaseFirestore

class classSelectionViewModel:ObservableObject{
    @Published var model = classSelectionList()
    private var db = Firestore.firestore()
    
    init(){
        getAllOfferedClasses()
    }
    
    var classList:Array<classSelection>{
        model.availableClasses
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
        let filtered_classes = model.availableClasses.filter({$0.isSelected})
        return filtered_classes.map{
            $0.id
        }
    }
    
    func update_selection(_ selection:classSelection){
        model.select(selection)
    }
    
    func select_group(_ group: String){
        model.select_group(group)
    }
    
    func getAllOfferedClasses(){
        db.collection("classesAvailable").document("classes").getDocument{result, err in
            if let result = result, result.exists{
                let data = result.data()!
                let availableClasses = data["classes"] as! Array<String>
                let classesAvailable = availableClasses.map{ selection in
                    classSelection(id: selection)
                }
                self.model.create(classesAvailable)
            }
            else{
                print("No available classes were found")
            }
        }
    }
}

struct classSelection:Identifiable, Hashable{
    var id: String
    var isSelected = false
}

struct classSelectionList{
    var availableClasses: Array<classSelection> = []
    var available_groups: [String:Bool] = [:]
    
    mutating func empty(){
        availableClasses.removeAll()
    }
    
    mutating func create(_ available:Array<classSelection>){
        availableClasses = available
        var temp = [String: Bool]()
        for class_ in available{
            let class_group = String(class_.id.split(separator: " ").first!)
            temp[class_group] = false
        }
        available_groups = temp
    }
    
    mutating func select_group(_ group: String){
        for key in available_groups.keys {
            if key != group{
                available_groups[key]! = false
            }
        }
        available_groups[group]!.toggle()
    }
    
    mutating func select(_ selection:classSelection){
        if let chosenIndex = availableClasses.firstIndex(where: {$0.id == selection.id}){
            self.availableClasses[chosenIndex].isSelected.toggle()
        }
    }
}
