//
//  CreateUserModel.swift
//  SpartanTutors
//
//  Created by Leo on 6/16/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
class UserCreationModel:ObservableObject{
    @Published var first_name:String = ""
    @Published var last_name: String = ""
    @Published var major:String = ""
    @Published var phone:String = ""
    @Published var yearStatus:String = ""
    private var db = Firestore.firestore()
    @Published var isLoading = false
    
    var name:String{
        if first_name.isEmpty || last_name.isEmpty{
            return ""
        }
        return first_name + " " + last_name
    }
    
    var formatted_phone:Binding<String> {
        Binding<String>(
            get: {
                self.phone.applyPatternOnNumbers(pattern: "(###) ###-####", replacementCharacter: "#")
                
            },
            set: {
                self.phone = $0.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
            }
        )
    }
    
    var filled_all: Bool{
        !name.isEmpty && !major.isEmpty && !phone.isEmpty && phone.is_valid_phone && !yearStatus.isEmpty
    }
    
    func createUser(uid:String, sms_check: Bool,first_sign_in:Bool = false, error_user_creation: Bool = false, completion: @escaping (Bool)->Void){
        print("got to create user part")
        print("\(filled_all)")
        if filled_all || first_sign_in{
            print("Trying to create user \(uid)")
            let user = user_first_time(
                id:uid,
                name: name,
                major: major,
                phone: phone,
                yearStatus: yearStatus,
                firstSignIn: first_sign_in)
            
            if self.name.contains("TuToR"){
                let tutor_info = Tutor(student_keys: user)
                createUser_tutor(userInfo: tutor_info){
                    completion($0)
                }
            }
            else{
                createUser_student(userInfo: user){
                    completion($0)
                }
            }
        }
    }
    
    func createUser_student(userInfo: user_first_time,completion: @escaping (Bool)->Void){
        do{
            try db.collection("users").document(userInfo.id).setData(from: userInfo){ err in
                if let err = err {
                    print("Error writing document: \(err)")
                    completion(false)
                } else {
                    print("Document successfully written!")
                    completion(true)
                }
            }
        }
        catch let erro{
            print(erro)
            completion(false)
        }
    }
    
    func createUser_tutor(userInfo: Tutor, completion: @escaping (Bool)->Void) {
        do{
            try db.collection("users").document(userInfo.id).setData(from: userInfo){ err in
                if let err = err {
                    print("Error writing document: \(err)")
                    completion(false)
                } else {
                    print("Document successfully written!")
                    completion(true)
                }
            }
        }
        catch let erro{
            print(erro)
            completion(false)
        }
        
    }
}

struct user_first_time: Codable, Identifiable, Hashable{
    var id: String = ""
    var name:String
    var major:String
    var phone:String
    var yearStatus:String
    var role = "student"
    var firstSignIn = false
    var accepted_privacy_policy = true
    var accepted_cancelation_policy = true
    var created_at = Date()
    
    enum CodingKeys: String, CodingKey {
        case name
        case major
        case phone
        case yearStatus
        case role
        case firstSignIn
        case accepted_privacy_policy
        case accepted_cancelation_policy
        case created_at
    }
}
