//
//  TutorFirstTimeViewModel.swift
//  SpartanTutors
//
//  Created by Leo on 6/30/22.
//

import Foundation
import FirebaseFirestore

class TutorCreationModel:ObservableObject{
    @Published var venmo:String = ""
    @Published var zoom_link:String = ""
    @Published var zoom_password: String = ""
        
    var both_filled: Bool{
        !venmo.isEmpty && !zoom_link.isEmpty && !zoom_password.isEmpty
    }
    private var db = Firestore.firestore()
    
    func updateTutor(uid:String,classes: Array<String>, completion: @escaping () -> Void){
        let formatted_id = zoom_link.replacingOccurrences(of: " ", with: "")
        let formatted_link = "https://msu.zoom.us/j/\(formatted_id)"
        db.collection("users").document(uid).updateData([
            "venmo": venmo,
            "zoom_link": formatted_link,
            "zoom_password": zoom_password,
            "classes": classes,
            "TutorFirstSignIn":false
            ]){ (err) in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                completion()
            }
        }
    }
}

