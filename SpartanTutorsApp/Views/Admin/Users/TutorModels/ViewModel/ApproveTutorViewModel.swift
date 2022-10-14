//
//  ApproveTutorViewModel.swift
//  SpartanTutors
//
//  Created by Leo on 7/8/22.
//

import Foundation
import FirebaseFirestore

class ApproveTutorViewModel:ObservableObject{
    @Published private (set) var model = TutorList()
    @Published var filter_tutor_payment = false
    private var db = Firestore.firestore()
    
    init(){
        getAllTutors()
    }
    
    var approved_tutors: Array<Tutor>{
        model.tutors.filter{
            $0.approved == true
        }
    }
    
    var unapproved_tutors:Array<Tutor>{
        model.tutors.filter{
            $0.approved == false
        }
    }
    
    func toggle_confirmation(_ of: ConfirmOptions, on: Tutor){
        let i = model.tutors.firstIndex(where:{$0.id == on.id})!
        model.toggle_confirmation(of, i)
    }
    
    func getAllTutors(){
        let ref = db.collection("users")
        ref.whereField("role", isEqualTo: "tutor")
            .addSnapshotListener() { (querySnapshot, err) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                let allTutors = documents.map { (queryDocumentSnapshot) -> Tutor in
                    let dict = queryDocumentSnapshot.data()
                    let id = queryDocumentSnapshot.documentID
                    let tutor_object = Tutor(id: id, dict: dict)
                    return tutor_object
                }
                self.model.update_tutors(allTutors)
            }
    }
    
    func approveTutor(id: String){
        //Update tutor on model
        let index = self.model.tutors.firstIndex(where: {$0.id == id})!
//        self.model.approve_tutor(ind: index)
        let tutor = self.model.tutors[index]
        
        //Update that data on the server
        db.collection("users").document(tutor.id).updateData([
            "approved":true
        ]){ err in
            if err != nil{
                print("Error approving document")
            } else {
                print("Document successfully updated")
            }
        }
        
    }
}
