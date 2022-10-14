//
//  allSessionsViewModel.swift
//  SpartanTutors
//
//  Created by Leo on 6/26/22.
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class AdminAllSessions: ObservableObject{
    private var db = Firestore.firestore()
    @Published private (set) var studentSessions: Array<Session> = []
    @Published var tutorSchedules = [String:TutorScheduleModel]()
    @Published var studentNames = [String:String]()
    @Published var tutorNames = [String:Tutor]()
    
    @Published var selected_tutor = "Any"
    @Published var selected_class = "All classes"
    
    var selected_item: String{
        if selected_class == "All classes"{
            return "All classes"
        }
        return selected_tutor
    }
    
    var tutor_classes: [String:Array<Tutor>]{
        var temp = [String:Array<Tutor>]()
        for id in tutorNames.keys{
            let tutor = tutorNames[id]!
            
            for c in tutor.classes{
                let class_group = String(c.prefix(3))
                if temp[class_group] == nil{
                    temp[class_group] = []
                }
                temp[class_group]!.append(tutor)
            }
        }
        return temp
    }
    
    var all_classes_schedule: TutorScheduleModel{
        var temp = TutorScheduleModel()
        for tutor in tutorSchedules{
            temp.append_to_any(new: tutor.value)
        }
        return temp
    }
    
    var schedule_for_tutor: [String:[String:TutorScheduleModel]]{
        //[
        //  "CSE": [
        //      "Any": TutorSceduleModel
        //      "Leonardo": TutorScheduleModule
        //      ]
        //  ]
        var temp = [String:[String:TutorScheduleModel]]()
        for c in tutor_classes.keys{
            if temp[c] == nil{
                temp[c] = [:]
            }
            let tutors_for_class = tutor_classes[c]!
            
            temp[c]!["Any"] = TutorScheduleModel()
            for tutor in tutors_for_class{
                let tutor_schedule = tutorSchedules[tutor.id]
                if tutor_schedule != nil{
                    temp[c]![tutor.name] = tutor_schedule
                    temp[c]!["Any"]!.append_to_any(new: tutor_schedule!)
                }
            }
        }
        return temp
    }
    
    
    func select_tutor(selected_class: String, tutor: String){
        //Tutor = Tutor id
        self.selected_class = selected_class
        self.selected_tutor = tutor
    }
    
    var tutor_schedule_model: TutorScheduleModel{
        if selected_class == "All classes"{
            return all_classes_schedule
        }
        return schedule_for_tutor[selected_class]![selected_tutor]!
    }
    
    
    @Published var filtered_id:String? = nil
    @Published var filtered_name: String = ""
    
    @Published var loading_sessions = false
    @Published var loading_schedules = false
    @Published var loading_name = false
    
    @Published var loading_payment_confirmation = false
    @Published var loading_cancel_approve = false
    @Published var loading_1h = false
    @Published var sucess = false
    @Published var failure = false
    var loading: Bool{
        loading_sessions || loading_schedules || loading_name
    }
    
    init(){
        retrieveStudentSessions()
        getAllTutorSchedules()
        retrieveNames(role: "student")
        retrieveNames(role: "tutor")
    }
    
    
    var all_sessions: Array<Session>{
        if filtered_id == nil && filtered_name.isEmpty{
            return studentSessions
        }
        else {
            if filtered_id != nil{
                return studentSessions.filter({$0.student_uid == filtered_id || $0.tutor_uid == filtered_id })
            }
            
            return studentSessions.filter({
                let student_name = studentNames[$0.student_uid]?.lowercased() ?? "Error"
                let tutor_name = tutorNames[$0.tutor_uid]?.name.lowercased() ?? "Error"
                let lower_case = filtered_name.lowercased()
                return student_name.contains(lower_case) || tutor_name.contains(lower_case)
            })
        }
    }
    
    var confirmed_sessions: Array<Session>{
        self.all_sessions.filter{ session in
            (session.status == "Approved") && session.date >= Date()
        }
        .sorted{
            $0.date < $1.date
        }
    }
    
    var pending_future: Array<Session>{
        self.all_sessions.filter{ session in
            (session.status == "Pending") && session.date >= Date()
        }
        .sorted{
            $0.date < $1.date
        }
    }
    
    var past: Array<Session> {
        self.all_sessions.filter{session in
            (session.status != "Approved" && session.status != "Pending" ) || session.date < Date()
        }.sorted{
            $0.date > $1.date
        }
        .sorted{
            $0.status != "Canceled" && $1.status == "Canceled"
        }
    }
    
    var tutor_session_for_payment: [String: Array<Session>]{
        var temp = [String: Array<Session>]()
        for session in past{
            if session.status == "Approved" && session.paid_tutor == false{
                if temp[session.tutor_uid] == nil{
                    temp[session.tutor_uid] = []
                }
                temp[session.tutor_uid]!.append(session)
            }
        }
        return temp
    }
    var total_due_now: Double{
        var total = 0.0
        for id in tutor_session_for_payment{
            for session in id.value{
                total += session.duration * sessionConstants.tutor_pay
            }
        }
        return total
    }
    var total_due: Double{
        var future_due = 0.0
        for i in confirmed_sessions{
            if i.status == "Approved" && i.paid_tutor == false{
                future_due += i.duration * sessionConstants.tutor_pay
            }
        }
        
        return future_due + total_due_now
    }
    var student_session_for_payment: [String: Array<Session>]{
        var temp = [String: Array<Session>]()
        for session in pending_future{
            if temp[session.student_uid] == nil{
                temp[session.student_uid] = []
            }
            temp[session.student_uid]!.append(session)
        }
        return temp
    }
    
    func clear_filters(){
        filtered_id = nil
        filtered_name = ""
    }
    
    func get_data_points(dates: Array<dayModel>, session_status: String) -> Array<DataPoint>{
        var temp = [DataPoint]()
        let calendar = Calendar.current
        for date in dates{
            temp.append(
                DataPoint(
                    x: date.day_number,
                    y: Double(
                        all_sessions.filter({calendar.isDate($0.date,inSameDayAs: date.date) && $0.status == session_status}).count)
                )
            )
        }
        return temp
    }
    
    func sessions_today(date: Date, status:String) -> Int{
        let calendar = Calendar.current
        return all_sessions.filter({calendar.isDate($0.date,inSameDayAs: date) && $0.status == status}).count
    }
    
    func session_on_month(date: Date, status: String) -> Int{
        let calendar = Calendar.current
        return all_sessions.filter({calendar.isDate($0.date,equalTo: date, toGranularity: .month) && $0.status == status}).count
    }
    
    func profit_on_period(date: Date, component: Calendar.Component) -> Double{
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        var temp = 0.0
        //Sessions that were paid for -> Does not include costs of sessions we had to replace
        all_sessions.filter({calendar.isDate($0.date,equalTo: date, toGranularity: component) && $0.status == "Approved" && $0.paid}).forEach({
            let revenue = Double(sessionConstants.price[$0.duration]!) * 0.97
            let tutor_costs = Double($0.duration*sessionConstants.tutor_pay)
            temp += (revenue - tutor_costs)
        })
        
        var session_replacement_costs = 0.0
        all_sessions.filter({calendar.isDate($0.date,equalTo: date, toGranularity: component) && $0.status == "Approved" && !$0.paid}).forEach({
            let tutor_costs = Double($0.duration*sessionConstants.tutor_pay)
            session_replacement_costs += tutor_costs
        })
        return temp - session_replacement_costs
    }
    
    
    func toggle_confirmation(_ of: ConfirmOptions, on: Session){
        let i = studentSessions.firstIndex(where:{$0.id == on.id})!
        studentSessions[i].toggle_confirmation(of)
    }
    
    func retrieveNames(role:String){
        self.loading_name = true
        let ref = db.collection("users").whereField("role", isEqualTo: role)
        ref.addSnapshotListener(){(querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                self.loading_name = false
                return
            }
            
            documents.forEach{
                if role == "student"{
                    self.studentNames[$0.documentID] = $0["name"] as? String
                }
                else{
                    
                    self.tutorNames[$0.documentID] = Tutor(id: $0.documentID, dict: $0.data())
                }
            }
            self.loading_name = false
        }
    }
    
    func pay_all_sessions(_ tutor: Tutor, _ completion: @escaping () -> Void){
        if let sessions = tutor_session_for_payment[tutor.id]{
            let payment_date = Date()
            self.loading_payment_confirmation = true
            
            // Get new write batch
            let batch = db.batch()
            
            for session in sessions{
                let ref = db.collection("Sessions").document(session.id)
                batch.setData(["paid_tutor":true, "paid_tutor_at": payment_date], forDocument: ref, merge: true)
            }

            // Commit the batch
            batch.commit() { err in
                if let err = err {
                    print("Error writing batch \(err)")
                    self.loading_payment_confirmation = false
                    self.failure = true
                } else {
                    print("Batch write succeeded.")
                    self.loading_payment_confirmation = false
                    self.sucess = true
                }
                completion()
            }

        }
    }
    
    func approve_all_sessions(_ student: Student, _ completion: @escaping () -> Void){
        if let sessions = student_session_for_payment[student.id]{
            let confirmed_date = Date()
            self.loading_payment_confirmation = true
            
            // Get new write batch
            let batch = db.batch()
            
            for session in sessions{
                let ref = db.collection("Sessions").document(session.id)
                batch.setData(["status":"Approved","paid":true, "confirmed_at": confirmed_date], forDocument: ref, merge: true)
            }

            // Commit the batch
            batch.commit() { err in
                if let err = err {
                    print("Error writing batch \(err)")
                    self.loading_payment_confirmation = false
                    self.failure = true
                } else {
                    print("Batch write succeeded.")
                    self.loading_payment_confirmation = false
                    self.sucess = true
                }
                completion()
            }

        }
    }
    
    func due_tutor(_ tutor: Tutor) -> Double{
        if let sessions = tutor_session_for_payment[tutor.id]{
            var total = 0.0
            for session in sessions{
                total += session.duration * sessionConstants.tutor_pay
            }
            return round(total*100)/100
        }
        return 0
    }
    
    func student_due(_ student: Student) -> Double{
        if let sessions = student_session_for_payment[student.id]{
            var total = 0.0
            for session in sessions{
                total += sessionConstants.price[session.duration]!
            }
            return total
        }
        return 0
    }
    
    func retrieveStudentSessions(){
        self.loading_sessions = true
        let ref = db.collection("Sessions")
        self.studentSessions.removeAll()
        ref.addSnapshotListener(){(querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                self.loading_sessions = false
                return
            }
            
            self.studentSessions = documents.map { (queryDocumentSnapshot) -> Session in
                var dict = queryDocumentSnapshot.data()
                dict["id"] = queryDocumentSnapshot.documentID
                let stamp: Timestamp = dict["date"] as! Timestamp
                dict["date"] = stamp.dateValue()
                return Session(dict)
            }
            self.loading_sessions = false
        }
    }
    
    func changeSessionStatus(session: Session, session_status: String){
        self.loading_cancel_approve = true
        var newStatus: [String:Any] = [
            "status": session_status
        ]
        switch session_status {
            case "Approved":
                newStatus["paid"] = true
                newStatus["confirmed_at"] = Date()
            case "Canceled":
                newStatus["refunded"] = true
                newStatus["canceled_at"] = Date()
                //Update tutor schedule
                updateCanceledSchedule(date: session.date, sessionTimeFrame: session.time_slot, tutor_id: session.tutor_uid)
            default:
                print("do nothing")
        }
        let ref = db.collection("Sessions")
        ref.document(session.id).updateData(newStatus){ (err) in
            if let err = err {
                print("Error updating document: \(err)")
                self.failure = true
                self.loading_cancel_approve = false
            } else {
                print("Document successfully updated")
                self.sucess = true
                self.loading_cancel_approve = false
            }
        }
    }
    
    func change_session_duration(session:Session, duration: Double = 1){
        self.loading_1h = true
        //Change duration of session
        var updated_session = session
        updated_session.duration = duration
        
        //Change the timeframe of the session
        updated_session.time_slot_obj.change_session_duration()
        
        let batch = db.batch()
        let ref = db.collection("Sessions").document(session.id)
        batch.setData(
            ["duration":duration,
             "time_slot": updated_session.time_slot],
            forDocument: ref,
            merge: true)
        
        let ref_tutors = db.collection("tutor_schedules").document(session.tutor_uid)
        //Change the timeframe of the tutor
        if let tutorSchedule = tutorSchedules[session.tutor_uid]{
            if var day = tutorSchedule.schedule[session.date.to_int_format()]{
                day.update_tutor_schedule_duration(sessionTime: session.time_slot_obj,duration: duration)
                batch.setData(
                    [session.date.to_int_format():day.to_string],
                    forDocument: ref_tutors,
                    merge: true)
            }
        }
        
        // Commit the batch
        batch.commit() { err in
            self.loading_1h = false
            if let err = err {
                print("Error making session 1h \(err)")
                self.failure = true
            } else {
                print("Batch write succeeded.")
                self.sucess = true
            }
        }
    }
    
    func make_session_refund(session:Session){
        self.loading_1h = true
        let ref = db.collection("Sessions")
        ref.document(session.id).updateData(["paid": false]){ (err) in
            if let err = err {
                print("Error updating document: \(err)")
                self.failure = true
                self.loading_1h = false
            } else {
                print("Document successfully updated")
                self.sucess = true
                self.loading_1h = false
            }
        }
    }
    
    
    func getAllTutorSchedules(){
        self.loading_schedules = true
        db.collection("tutor_schedules").addSnapshotListener{result, err in
            guard let documents = result?.documents else {
                print("Error fetching documents: \(err!)")
                self.loading_schedules = false
                return
            }
            
            var schedules = [String:TutorScheduleModel] ()
            documents.forEach{tutor in
                schedules[tutor.documentID] = TutorScheduleModel(new: tutor.data() as? [String:String] ?? nil)
            }
            self.tutorSchedules = schedules
            self.loading_schedules = false
        }
    }
    
    func updateCanceledSchedule(date:Date,sessionTimeFrame:String,tutor_id:String){
        let day = date.to_int_format()
        
        //Updates the model variable
        for i in sessionTimeFrame.indices{
            if sessionTimeFrame[i] == "2"{
                self.tutorSchedules[tutor_id]!.schedule[day]!.cancel_session_time(ind: i.utf16Offset(in: sessionTimeFrame))
            }
        }
        
        //Converting the array of ints to Array of string
        let schedule_string = self.tutorSchedules[tutor_id]!.schedule[day]!.to_string
        
        db.collection("tutor_schedules").document(tutor_id).updateData(
            [day:schedule_string]
        )
        {(err) in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
}

