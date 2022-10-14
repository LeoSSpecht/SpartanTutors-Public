//
//  NotesViewModels.swift
//  SpartanTutors
//
//  Created by Leo on 9/8/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class NotesViewModel: ObservableObject{
    private var db = Firestore.firestore()
    
    @Published var model = AllNotesModel()
    @Published var loading_notes = false
    
    init(){
        self.fetch_all_notes()
    }
    var count: Int{
        model.allNotes_original.count
    }
    
    func fetch_all_notes(){
        let ref = db.collection("notes")
        ref.getDocuments{(querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("No notes to load")
                return
            }
            var temp_array = [[String:Any]]()
            documents.forEach({ doc in
                temp_array.append(
                    [
                        "id": doc.documentID,
                        "text":doc["text"] ?? "",
                        "title":doc["title"] ?? "",
                        "order":doc["order"] ?? ""
                    ]
                )
            })
            self.model.create_notes(temp_array)
        }
    }
    
    func upload_note(newNote: Note){
        let ref = db.collection("notes")
        var note = newNote
        
        if newNote.id == ""{
            let id = ref.document().documentID
            note.id = id
        }
        
        model.edit_note(new: note)
        
        ref.document(note.id).setData(note.to_dict(), merge: true){(err) in
            if let err = err {
                print("Error updating note: \(err)")
                
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func delete_note(note: Note){
        let ref = db.collection("notes")
        ref.document(note.id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                self.model.delete(note: note)
                print("Document successfully removed!")
            }
        }
    }
}
