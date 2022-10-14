//
//  AllStudentModel.swift
//  SpartanTutors
//
//  Created by Leo on 8/16/22.
//

import Foundation

struct StudentsList{
    var students: Array<Student> = []
    
    mutating func update_students(new: Array<Student>){
        self.students = new.sorted(by: {$0.name < $1.name})
    }
    
    mutating func toggle_confirmation(_ of: ConfirmOptions,_ on: Int){
        self.students[on].toggle_confirmation(of)
    }
}
