//
//  TutorSessionViewModel.swift
//  SpartanTutors
//
//  Created by Leo on 6/30/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TutorAllSessionsViewModel: ObservableObject{
    @Published private (set) var model = tutorSessionsModel()
    @Published private (set) var studentNames: [String:String] = [:]
    @Published var loading_sessions = false
    @Published var loading_names = false
    
    @Published var loading_late = false
    @Published var confirm_late = false
    
    @Published var fail = false
    @Published var sucess = false
    private var tutor_id:String = ""
    private var db = Firestore.firestore()
    private var initial_time = 8
    
    var loading: Bool{
        loading_sessions || loading_names
    }
    
    var receivables: Double{
        var total = 0.0
        for session in other_Sessions.filter({$0.paid_tutor == false && $0.status == "Approved"}){
            total += session.duration * sessionConstants.tutor_pay
        }
        return total
    }
    
    init(_ id: String){
        tutor_id = id
        retrieveStudentNames()
        retrieveStudentSessions()
        
    }
    
    var specific_tutor_sessions:Array<Session> {
        model.studentSessions.filter{
            $0.tutor_uid == self.tutor_id
        }
    }
    
    var confirmed: Array<Session>{
        self.specific_tutor_sessions.filter{ session in
            (session.status == "Approved" || session.status == "Pending") && session.date >= Date()
        }
        .sorted{
            $0.date < $1.date
        }
        .sorted{
            $0.status != "Pending" && $1.status == "Pending"
        }
    }

    var other_Sessions: Array<Session> {
        self.specific_tutor_sessions.filter{session in
            (session.status != "Approved" && session.status != "Pending" ) || session.date < Date()
        }.sorted{
            $0.date > $1.date
        }
        .sorted{
            $0.status != "Canceled" && $1.status == "Canceled"
        }
    }
    
    func toggle_confirmation(_ of: ConfirmOptions, on: Session){
        let i = model.studentSessions.firstIndex(where:{$0.id == on.id})!
        model.toggle_confirmation(of, i)
    }
    
    func cancel_all_pop_ups(on: Session){
        let i = model.studentSessions.firstIndex(where:{$0.id == on.id})!
        model.cancel_confirmations(i)
    }
    
    func retrieveStudentSessions(){
        self.loading_sessions = true
        let ref = db.collection("Sessions")
        ref.addSnapshotListener(){(querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                self.loading_sessions = false
                return
                
            }
            
            let studentSessions = documents.map { (queryDocumentSnapshot) -> Session in
                var dict = queryDocumentSnapshot.data()
                dict["id"] = queryDocumentSnapshot.documentID
                let stamp: Timestamp = dict["date"] as! Timestamp
                dict["date"] = stamp.dateValue()
                return Session(dict)
            }
            self.model.update_session(new: studentSessions)
            self.loading_sessions = false
        }
    }
    
    func retrieveStudentNames(){
        self.loading_names = true
        let ref = db.collection("users").whereField("role", isEqualTo: "student")
        ref.addSnapshotListener(){(querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                self.loading_names = false
                return
            }
            
            documents.forEach{
                self.studentNames[$0.documentID] = $0["name"] as? String
            }
            self.loading_names = false
        }
        
    }
    
    func running_late(session: Session){
        self.loading_late = true
        let new_status = [
            "tutor_running_late": true,
        ]
        let ref = db.collection("Sessions")
        ref.document(session.id).setData(new_status,merge: true){ (err) in
            if let err = err {
                print("Error updating document: \(err)")
                self.fail = true
                self.loading_late = false
            } else {
                print("Document successfully updated")
                self.sucess = true
                self.loading_late = false
                self.toggle_confirmation(.late, on: session)
            }
        }
    }
}

struct tutorSessionsModel{
    private (set) var studentSessions: Array<Session> = []
    
    mutating func update_session(new:Array<Session>){
//      Removes sessions that are not there anymore
        var new_sessions: Array<Session> = []
        for session in new{
            //Check if session existed previously
            if let old_session = studentSessions.first(where: {$0.id == session.id}){
                var updated_session = session
                updated_session.confirm_late = old_session.confirm_late
                updated_session.student_confirm_cancel = old_session.student_confirm_cancel
                new_sessions.append(updated_session)
            }
            else{
                new_sessions.append(session)
            }
        }
        self.studentSessions = new_sessions
    }
    
    mutating func toggle_confirmation(_ of: ConfirmOptions,_ on: Int){
        self.studentSessions[on].toggle_confirmation(of)
    }
    
    mutating func cancel_confirmations(_ on: Int){
        self.studentSessions[on].cancel_confirmations()
    }
}
