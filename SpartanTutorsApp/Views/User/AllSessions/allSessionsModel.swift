//
//  sessionModel.swift
//  SpartanTutors
//
//  Created by Leo on 6/16/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class AllSessionsModel: ObservableObject{
    private var db = Firestore.firestore()
    private var initial_time = 8
    private var listeners: [ListenerRegistration] = []
    @Published private (set) var studentSessions: Array<Session> = []
    @Published private (set) var tutors: Array<TutorSummary> = []
    @Published var selected_tabs = [Int]()
    @Published var sucess = false
    @Published var fail = false
    @Published var loading = false
    @Published var show_late_info = false
    
    private var student_id:String
    
    init(uid: String){
        student_id = uid
        retrieveStudentSessions()
        getAllTutors()
    }
    
    deinit{
        print("Ran deinit")
        for i in self.listeners.indices{
            self.listeners[i].remove()
        }
    }
    
    var total_amount_due: Double{
        var total_value = 0.0
        let pending_sessions = confirmed.filter({session in session.status == "Pending"})
        pending_sessions.forEach(
            {session in
                total_value += sessionConstants.price[session.duration]!
            }
        )
        return total_value
    }
    
    var confirmed: Array<Session>{
        self.studentSessions.filter{ session in
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
        self.studentSessions.filter{session in
            (session.status != "Approved" && session.status != "Pending" ) || session.date < Date()
        }.sorted{
            $0.date > $1.date
        }
        .sorted{
            $0.status != "Canceled" && $1.status == "Canceled"
        }
    }
    
    func toggle_confirmation(_ of: ConfirmOptions, on: Session){
        let i = studentSessions.firstIndex(where:{$0.id == on.id})!
        studentSessions[i].toggle_confirmation(of)
    }
    
    func cancel_all_pop_ups(on: Session){
        let i = studentSessions.firstIndex(where:{$0.id == on.id})!
        studentSessions[i].cancel_confirmations()
    }
    
    func change_selected_tab(new_value: Int, new_session: Session){
        let new_session_index = studentSessions.firstIndex(where:{$0.id == new_session.id})!
        for i in selected_tabs.indices {
            if selected_tabs[i] == 2 && i != new_session_index{
                selected_tabs[i] = 1
                cancel_all_pop_ups(on: studentSessions[i])
                break
            }
        }
    }
    
    func get_session_index(of: Session) -> Int{
        return studentSessions.firstIndex(where:{$0.id == of.id}) ?? 1
    }
    func retrieveStudentSessions(){
        let ref = db.collection("Sessions")
        self.studentSessions.removeAll()
        let listen = ref.whereField("student_uid", isEqualTo: student_id)
            .addSnapshotListener() { (querySnapshot, err) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.studentSessions = documents.map { (queryDocumentSnapshot) -> Session in
                    var dict = queryDocumentSnapshot.data()
                    dict["id"] = queryDocumentSnapshot.documentID
                    let stamp: Timestamp = dict["date"] as! Timestamp
                    dict["date"] = stamp.dateValue()
                    return Session(dict)
                }
                if self.studentSessions.count != self.selected_tabs.count{
                    self.selected_tabs = Array(repeating: 1, count: self.studentSessions.count)
                }
//
            }
        self.listeners.append(listen)
    }
    
    func getAllTutors(){
        let ref = db.collection("users")
        let listen = ref.whereField("role", isEqualTo: "tutor")
            .addSnapshotListener() { (querySnapshot, err) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                let allTutors = documents.map { (queryDocumentSnapshot) -> TutorSummary in
                    let dict = queryDocumentSnapshot.data()
                    let id = queryDocumentSnapshot.documentID
                    let password = dict["zoom_password"] ?? "123"
                    return TutorSummary(id: id, name: dict["name"]! as! String, zoom_link: dict["zoom_link"]! as! String, zoom_password: password as! String)
                }
                self.tutors = allTutors
            }
        self.listeners.append(listen)
    }
    
    func cancel_session(session: Session){
        self.loading = true
        let new_status = [
            "status": "Canceled",
        ]
        updateCanceledSchedule(date: session.date, sessionTimeFrame: session.time_slot, tutor_id: session.tutor_uid)
        let ref = db.collection("Sessions")
        ref.document(session.id).updateData(new_status){ (err) in
            if let err = err {
                print("Error updating document: \(err)")
                self.fail = true
                self.loading = false
            } else {
                print("Document successfully updated")
                self.sucess = true
                self.loading = false
            }
        }
    }
    
    func running_late(session: Session){
        self.loading = true
        let new_status = [
            "student_running_late": true,
        ]
        let ref = db.collection("Sessions")
        ref.document(session.id).setData(new_status,merge: true){ (err) in
            if let err = err {
                print("Error updating document: \(err)")
                self.fail = true
                self.loading = false
            } else {
                print("Document successfully updated")
                self.sucess = true
                self.loading = false
            }
        }
    }
    
    func updateCanceledSchedule(date:Date,sessionTimeFrame:String,tutor_id:String){
        let day = date.to_int_format()
        get_specific_tutor_schedule(tutor_id: tutor_id, day: day, session_schedule: Timeframe(sessionTimeFrame)){ new_schedule in
            print(new_schedule!)
            self.db.collection("tutor_schedules").document(tutor_id).updateData(
                [day:new_schedule as Any]
            )
            {(err) in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Made tutor available again")
                }
            }
        }
    }
    
    func get_specific_tutor_schedule(tutor_id:String, day: String, session_schedule: Timeframe, completion: @escaping (_: String?) -> Void){
        db.collection("tutor_schedules").document(tutor_id).getDocument{(document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                if let schedule = data[day]{
                    let tutor_new_time = self.change_session_time(session_time: session_schedule, tutor_schedule: Timeframe((schedule as? String)!))
                    completion(tutor_new_time.to_string)
                }
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }
    
    func change_session_time(session_time:Timeframe, tutor_schedule: Timeframe) -> Timeframe{
        print("Session time \(session_time.to_string)")
        print("tutor time \(tutor_schedule.to_string)")
        var tutor = tutor_schedule
        for i in session_time.data.indices{
            if session_time.data[i] == 2{
                tutor.data[i] = 1
            }
        }
        print("tutor new time \(tutor.to_string)")
        return tutor
    }
}

