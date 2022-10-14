//
//  getRoleModel.swift
//  SpartanTutors
//
//  Created by Leo on 6/16/22.
//

import Foundation
import FirebaseFirestore

class getRoleModel: ObservableObject{
    
    private var db = Firestore.firestore()
    @Published var userRole:String = ""
    @Published var isFirstSignIn:Bool = false
    @Published var isTutorApproved:Bool = false
    @Published var isTutorFirstSignIn:Bool = false
    @Published var isLoading:Bool = true
    @Published var error:Bool = false
    var tried_to_create_user = false
    var list_of_listeners = [ListenerRegistration]()
    deinit{
        print("Ran role deinit")
        for i in list_of_listeners.indices{
            print(list_of_listeners[i])
            list_of_listeners[i].remove()
        }
    }
    
    func getRole(uid:String){
        print("Getting role")
        let docRef = db.collection("users").document(uid)
        let listen = docRef.addSnapshotListener{ [self] (document, error) in
            if let document = document {
                if document.exists{
                    let data = document.data()
                    if let data = data {
                        self.userRole = data["role"] as? String ?? ""
                        self.isFirstSignIn = data["firstSignIn"] as? Bool ?? false
                        if self.userRole == "tutor"{
                            //Check for tutor specific variables
                            if data["approved"] != nil {
                                self.isTutorApproved = (data["approved"] as? Bool)!
                            }
                            if data["TutorFirstSignIn"] != nil{
                                self.isTutorFirstSignIn = (data["TutorFirstSignIn"] as? Bool)!
                            }
                        }
                        self.tried_to_create_user = true
                        self.isLoading = false
                    }
                }
                else{
                    print("Document does not exist")
                    self.error = true
//                    if !tried_to_create_user{
//                        let createUserModel = UserCreationModel()
//                        createUserModel.createUser(uid: uid, sms_check: false,first_sign_in: true, error_user_creation: true){
//                            print($0)
//                            self.isLoading = false
//                            self.error = !$0
//                            self.tried_to_create_user = true
//                        }
//                    }
                }
                
            } else {
                //If did not find document creates a new one
                print("Error in role model")
                print(error as Any)
                self.error = true
            }
        }
        list_of_listeners.append(listen)
    }
}
