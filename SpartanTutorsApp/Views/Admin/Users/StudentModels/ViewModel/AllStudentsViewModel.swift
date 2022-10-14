//
//  ApproveTutorViewModel.swift
//  SpartanTutors
//
//  Created by Leo on 7/8/22.
//

import Foundation
import FirebaseFirestore

class StudentsAdminViewModel:ObservableObject{
    @Published private (set) var model = StudentsList()
    @Published var filter_names = ""
    
    private var db = Firestore.firestore()
    
    init(){
        getAllStudents()
    }
    
    var students: Array<Student>{
        if filter_names.isEmpty{
            return model.students.filter({!$0.name.isEmpty})
        }
        else{
            return model.students.filter(
                {
                    let lower_name = $0.name.lowercased()
                    let filtered = filter_names.lowercased()
                    return lower_name.contains(filtered) && !lower_name.isEmpty
                })
        }
    }

    func toggle_confirmation(_ of: ConfirmOptions, on: Student){
        let i = model.students.firstIndex(where:{$0.id == on.id})!
        model.toggle_confirmation(of, i)
    }
    
    func getAllStudents(){
        let ref = db.collection("users")
        ref.whereField("role", isEqualTo: "student")
            .addSnapshotListener() { (querySnapshot, err) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                let allStudents = documents.map { queryDocumentSnapshot -> Student in
                    let dict = queryDocumentSnapshot.data()
                    let id = queryDocumentSnapshot.documentID
                    let student_object = Student(content: dict, id: id)
                    return student_object
                }
                self.model.update_students(new: allStudents)
            }
    }
}
