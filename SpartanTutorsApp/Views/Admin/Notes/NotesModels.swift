//
//  NotesModels.swift
//  SpartanTutors
//
//  Created by Leo on 9/8/22.
//

import Foundation

struct AllNotesModel{
    var allNotes_original: Array<Note> = []
    var editMode: [String:Bool] = [:]
    
    var allNotes: Array<Note>{
        allNotes_original.sorted(by: {$0.order < $1.order})
    }
    
    mutating func create_notes(_ new_notes: Array<[String:Any]>){
        var temp:Array<Note> = []
        for note in new_notes{
            let note = Note(note: note)
            temp.append(note)
            editMode[note.id] = false
        }
        self.allNotes_original = temp
        
    }
    
    mutating func edit_note(new: Note){
        if let i = allNotes_original.firstIndex(where: {$0.id == new.id}){
            //Note already exists
            allNotes_original[i] = new
        }
        else{
            //New note
            allNotes_original.append(new)
        }
    }
    
    mutating func delete(note: Note){
        if let i = allNotes_original.firstIndex(where: {$0.id == note.id}){
            //Note already exists
            allNotes_original.remove(at: i)
        }
    }
    
}

struct Note: Identifiable{
    var id: String
    var title: String
    var text: String
    var order: Int
    
    init(note: [String:Any]){
        self.id = note["id"]! as! String
        self.text = note["text"] as? String ?? ""
        self.title = note["title"] as? String ?? ""
        self.order = note["order"] as? Int ?? 0
    }
    
    init(order: Int){
        self.id = ""
        self.text = ""
        self.title = ""
        self.order = order
    }
    
    func to_dict() -> [String:Any]{
        return [
            "id": id,
            "title": title,
            "text": text,
            "order": order
        ]
    }
}
