//
//  bookSessionViewModel.swift
//  SpartanTutors
//
//  Created by Leo on 6/23/22.
//
import Foundation
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift
class bookStudentSession: ObservableObject {
//    settings.isPersistenceEnabled = false
    private var db =  Firestore.firestore()
    private let student_id:String
    private var listeners =  [ListenerRegistration]()
    @Published var model = sessionBookerData()
    @Published var tutorSelection:TutorSummary = TutorSummary(id: "Any", name: "Any", zoom_link: "")
    @Published var dateSelection:Date = Date()
    @Published var sessionSelections:sessionTime?
    @Published var selectedClass:String = ""
    @Published var finishedLoading = false
    @Published var error_on_book = false
    @Published var load_confirmation = false
    @Published var load_payment = false
    @Published var loading_booking = false
    
    //ID -> Schedule
    
    init(student_id:String){
        self.student_id = student_id
        get_all_tutors()
    }
    
    deinit{
        for i in self.listeners.indices{
            self.listeners[i].remove()
        }
    }
    
//  MARK: GETTERS
    var classes_:Array<String>{
        self.model.all_classes
    }
    
    var grouped_classes: [String: Array<String>]{
        var temp = [String: Array<String>]()
        
        for class_ in classes_{
            let class_group = String(class_.split(separator: " ").first!)
            if temp[class_group] == nil{
                temp[class_group] = []
            }
            temp[class_group]!.append(class_)
        }
        return temp
    }
    
    var available_dates_filtered: [String: Bool]{
        var available_dates = [String: Bool]()
        // For each day see if the tutor for the class is available
        // If the tutos is any, the check if any tutors for the class are available
        if tutorSelection.id == "Any"{
            //Possible tutors = tutors
            for date in model.all_available_dates.keys{
                var is_any_tutor_available = false
                for tutor in tutors{
                    let week = Date.from_int_format(original: date).to_week_number()
                    let tutor_available_week = model.id_schedule_dict[tutor.id]!.weekly_availability[week] ?? false
                    if let tutor_availability = model.all_available_dates[date]![tutor.id], tutor_availability, tutor_available_week{
                        is_any_tutor_available = true
                        break
                    }
                }
                available_dates[date] = is_any_tutor_available
            }
        }
        else{
            for date in model.all_available_dates.keys{
                let week = Date.from_int_format(original: date).to_week_number()
                let tutor_available_week = model.id_schedule_dict[tutorSelection.id]!.weekly_availability[week] ?? false
                if let tutor_availability = model.all_available_dates[date]![tutorSelection.id], tutor_available_week{
                    available_dates[date] = tutor_availability
                }
                else{
                    available_dates[date] = false
                }
            }
        }
        return available_dates
    }
    
    var next_available_dates: [String: Bool]{
        available_dates_filtered.filter{
            let string_date = $0.key
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let date = dateFormatter.date(from:string_date)
            return $0.value && date ?? Date() > dateSelection
        }
    }
    
    var available_times:Array<sessionTime>{
        model.available_times
    }
    
    var tutors:Array<TutorSummary>{
        if let av = model.classes_dict[selectedClass]{
            var all_tutors_list = [TutorSummary]()
            for id in av{
                if is_tutor_ever_available(id: id){
                    all_tutors_list.append(TutorSummary(id: id, name: model.id_schedule_dict[id]!.tutorName, zoom_link: ""))
                }
            }
            //Sorting tutors by name, maybe sort by rating?
            return all_tutors_list.sorted{$0.name < $1.name}
        }
        return []
    }
    
    func is_tutor_ever_available(id:String) -> Bool{
        for date in model.all_available_dates.keys{
            if let tutor_availability = model.all_available_dates[date]![id], tutor_availability{
                return true
            }
        }
        return false
    }
//  MARK: UPDATING FUNCTIONS
    func update_times(){
        _ = model.create_available_times(tutor: tutorSelection.id, date: dateSelection, college_class: selectedClass)
        if !self.model.available_times.isEmpty{
            self.choose_session(self.model.available_times.first!.id)
        }
        else{
            sessionSelections = nil
        }
    }

//  MARK: DATABASE ACCESS
    func get_all_tutors(){
        let ref = db.collection("users")
        ref.whereField("role", isEqualTo: "tutor").whereField("approved", isEqualTo: true)
            .getDocuments() { (querySnapshot, err) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                var dataDict = [String:TutorSchedule]()
                var classes_dict = [String:Array<String>]()
//                var allTutors = [TutorSummary]()
                //Creates a dictionary with id -> TutorSchedule, but empyt schedule
                documents.forEach{ queryDocumentSnapshot in
                    let doc_id = queryDocumentSnapshot.documentID
                    let dict = queryDocumentSnapshot.data()
                    let classes = dict["classes"] as! Array<String>
                    let name = dict["name"] as! String
                    dataDict[doc_id] = TutorSchedule(id: doc_id, available_classes: classes, name: name)
//                    allTutors.append(TutorSummary(id: doc_id, name: name))
                    //Creates a dict with all the classes -> ID of the tutors for that class
                    classes.forEach{ available_class in
                        if classes_dict[available_class] == nil{
                            classes_dict[available_class] = []
                        }
                        classes_dict[available_class]?.append(doc_id)
                    }
                }
                
//                self.model.update_tutors(new_tutors: allTutors)
                self.model.update_id_schedule(new: dataDict, classes_available: classes_dict)
                if self.model.all_classes.contains("CSE 102"){
                    self.selectedClass = "CSE 102"
                }
                else{
                    self.selectedClass = self.model.all_classes.first ?? "Bug"
                }
                self.generateTutorSchedules()
            }
    }
    
    func choose_session(_ id: Int){
        self.sessionSelections = self.model.choose_session(id)
    }
    
    func generateTutorSchedules(){
        let ref = db.collection("tutor_schedules")
//        let listen =
        ref.getDocuments{ (querySnapshot, err) in
            
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            print("Fetched Times")
            documents.forEach{ queryDocumentSnapshot in
                let dict = queryDocumentSnapshot.data()
                let doc_id = queryDocumentSnapshot.documentID
                if self.model.id_schedule_dict[doc_id] != nil{
//                  Update tutor in model
                    self.model.update_tutor_schedule(new_schedule: dict, id: doc_id)
                }
            }
            
            if self.selectedClass == ""{
                
                if self.model.all_classes.contains("CSE 102"){
                    self.selectedClass = "CSE 102"
                }
                else{
                    self.selectedClass = self.model.all_classes.first ?? "Bug"
                }
            }
            
            
            // Gets the first time available for that date
            var changed = false
            if self.selectedClass != "Bug"{
                changed = self.model.create_available_times(tutor: self.tutorSelection.id ,date: self.dateSelection, college_class: self.selectedClass)
            }

            if self.model.available_times.isEmpty{
                self.sessionSelections = nil
            }
            else if changed{
                self.choose_session(self.model.available_times.first!.id)
            }
 
            //Generates "calendar" to show which dates the tutor/any have available
            self.model.build_all_available_dates()
            self.finishedLoading = true
        }
//        self.listeners.append(listen)
    }
    
    func updateTutorSchedule(tutor_schedule:TutorSchedule){
        let ref = db.collection("tutor_schedules").document(tutor_schedule.id)
        ref.updateData(tutor_schedule.schedule_to_string){(err) in
            if let err = err {
                print("Error updating tutor schedule: \(err)")
            } else {
                print("Sucessufuly updated tutor schedule")
            }
        }
    }
    
    typealias CompletionHandler = (_ success:Bool, _ schedule: TutorSchedule?) -> Void
    func getSpecificTutorTime(tutor_uid: String, complete: @escaping CompletionHandler){
        let ref = db.collection("tutor_schedules").document(tutor_uid)
        ref.getDocument{ (querySnapshot, err) in
            guard let documents = querySnapshot?.data() else {
                print("No documents")
                complete(false,nil)
                return
            }
            let dict = documents
            var schedule = TutorSchedule(id: querySnapshot!.documentID, available_classes: [], name: "")
            schedule.update_schedule(dict)
            complete(true,schedule)
        }
    }

// MARK: Helper functions
    func createSessionObject(){
        self.loading_booking = true
        var content:[String:Any] = [
            "id" : "",
            "tutor_uid" : sessionSelections?.tutor as Any,
            "date" : sessionSelections?.sessionDate as Any,
            "time_slot" : sessionSelections?.timeframe.to_string as Any,
            "college_class" : selectedClass
        ]
        content["student_uid"] = student_id
        let sessionToBook = Session(content)
        bookSession(sessionToBook)
    }
    
    func update_single_time(session_timeframe:Timeframe,tutor_timeframe:Timeframe) -> Timeframe?{
        var tutor_updated_str = tutor_timeframe
        if tutor_updated_str.update_time_for_new_session(session_time: session_timeframe){return tutor_updated_str}
        return nil
    }
    
    func bookSession(_ session: Session){
        let myGroup = DispatchGroup()
        myGroup.enter()
        var updated_scheduled:TutorSchedule = TutorSchedule(id: "", available_classes: [], name: "")
        self.getSpecificTutorTime(tutor_uid: session.tutor_uid,complete: { success, schedule in
            if let s = schedule{
                updated_scheduled = s
            }
            myGroup.leave()
        })
        
        myGroup.notify(queue: .main) {
            var isAvailable = true
            let date_convert:String = session.date.to_int_format()
            var final_tutor_schedule = Timeframe()
            if(updated_scheduled.schedule[date_convert] != nil){
                let str = session.time_slot_obj
                let tutor_updated_str = updated_scheduled.schedule[date_convert]!
                
                if let schedule = self.update_single_time(session_timeframe: str, tutor_timeframe: tutor_updated_str){
                    final_tutor_schedule = schedule
                }
                else{
                    isAvailable = false
                }
            }
    
            if isAvailable {
                // Tutor is available, proceed to book session
                //Create session
                self.upload_session_to_database(session: session){ uploaded in
                    if uploaded{
                        updated_scheduled.schedule[date_convert] = final_tutor_schedule
                        print("Starting tutor schedule update")
                        self.updateTutorSchedule(tutor_schedule: updated_scheduled)
                        self.load_payment = true
                    }
                    else{
                        //Go back to main page
                        self.reset_tabs()
                        self.error_on_book.toggle()
                    }
                }
            }
            else{
                //Tutor is not available
                self.reset_tabs()
                self.error_on_book.toggle()
            }
        }
    }
    
    func reset_tabs(){
        self.load_confirmation = false
        self.load_payment = false
        self.loading_booking = false
    }
    
    func upload_session_to_database(session: Session, completion: @escaping (_: Bool) -> Void){
        var final_session = session
        let ref = self.db.collection("Sessions")
        let docId = ref.document().documentID
        final_session.id = docId
        print(final_session)
        self.db.collection("Sessions").document(docId).setData(final_session.generate_dict()){(err) in
            if let err = err {
                print("Error on creating session: \(err)")
                completion(false)
            } else {
                print("Session created")
                completion(true)
            }
        }
    }
    
    
}
