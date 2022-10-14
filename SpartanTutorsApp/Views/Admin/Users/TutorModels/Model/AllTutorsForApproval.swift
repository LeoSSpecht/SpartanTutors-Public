//
//  AllTutorsForApproval.swift
//  SpartanTutors
//
//  Created by Leo on 7/8/22.
//

import Foundation

struct TutorList{
    var tutors: Array<Tutor> = []
    
    //Repeated function from bookSessionViewModel
    mutating func update_tutors(_ new: Array<Tutor>){
        self.tutors = new.sorted(by: {$0.name < $1.name})
    }
    
    mutating func approve_tutor(ind:Int){
        tutors[ind].approved = true
    }
    
    mutating func toggle_confirmation(_ of: ConfirmOptions,_ on: Int){
        self.tutors[on].toggle_confirmation(of)
    }
    
}
