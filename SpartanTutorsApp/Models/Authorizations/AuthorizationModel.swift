//
//  AuthorizationModel.swift
//  SpartanTutors
//
//  Created by Leo on 6/11/22.
//

import Firebase
import FirebaseCore
import GoogleSignIn

class AuthenticationViewModel: ObservableObject {
    @Published var userID: userObject = userObject()
    @Published var loadedCheckSignIn = false
    @Published var loadingSignIn = false
    @Published var show_alert = false
    private var db = Firestore.firestore()
    
    //ROLE
    @Published var userRole:String = ""
    @Published var isFirstSignIn:Bool = false
    @Published var isTutorApproved:Bool = false
    @Published var isTutorFirstSignIn:Bool = false
    
    private func checkSignIn(){
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
          GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
            authenticateUser(for: user, with: error){c in
                //Get role here
                self.handle_get_role(should_continue: c)
            }
          }
        }
        else{
            loadedCheckSignIn = true
        }
    }
    
    init(){
        //This auto signs the user in, if you dont want that remove this.
//        checkSignIn()
        loadedCheckSignIn = true
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?,completion: @escaping (Bool) -> Void) {
      // 1
      if let error = error {
        print(error.localizedDescription)
        return
      }
      guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
      Auth.auth().signIn(with: credential) { [unowned self] (result, error) in
        if let error = error {
          print(error.localizedDescription)
            //Alert
        } else {
            guard let newUserStatus = result?.additionalUserInfo?.isNewUser else {return}
            if(newUserStatus){
                print("User is first time")
//                If it is a new user, create the user in the database
                let createUserModel = UserCreationModel()
                self.userID.isNewUser = true
                createUserModel.createUser(uid: result!.user.uid, sms_check: false,first_sign_in: true, completion: {
                    self.userID.isSignedIn = true
                    self.userID.uid = result?.user.uid ?? "Error"
                    self.userID.name = result?.user.displayName ?? "Error"
                    print("Created user")
                    completion($0)
                })
            }
            else{
                self.userID.isSignedIn = true
                self.userID.uid = result?.user.uid ?? "Error"
                self.userID.name = result?.user.displayName ?? "Error"
                completion(true)
            }
        }
      }
    }
    
    func signIn() {
        print("Sign in function")
        loadingSignIn = true
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                print("User already logged in")
                authenticateUser(for: user, with: error){c in
                    //Get role here
                    print("Authenticated, trying to handle role")
                    self.handle_get_role(should_continue: c)
                    
                }
            }
        } else {
            print("openning page for logged in")
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            let configuration = GIDConfiguration(clientID: clientID)
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in authenticateUser(for: user, with: error){ c in
                //Get role here
                print("Authenticated, trying to handle role")
                self.handle_get_role(should_continue: c)
            }}
        }
    }
    
    func signOut() {
        print("Signed out")
        userID.isSignedIn = false
        // 1
        GIDSignIn.sharedInstance.signOut()

        do {
        // 2
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        self.loadingSignIn = false
    }
    private func handle_get_role(should_continue: Bool){
        if should_continue{
            //Everything worked
            self.loadedCheckSignIn = true
            self.getRole()
        }
        else{
            //Some kind of error, alert the user and try to do it again
            print("Should not continue")
            show_alert.toggle()
            self.signOut()
        }
    }
    
    //MARK: Get role
    func getRole(){
        print("getting role")
        let docRef = db.collection("users").document(self.userID.uid)
        docRef.getDocument{ [self] (document, error) in
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
                        self.loadingSignIn = false
                    }
                }
                else{
                    print("Document does not exist")
                    self.show_alert = true
                    self.signOut()
                }

            } else {
                //If did not find document creates a new one
                print("Error in role model")
                print(error as Any)
                self.show_alert = true
                self.signOut()
            }
        }
    }
}

