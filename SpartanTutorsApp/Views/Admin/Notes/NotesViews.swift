//
//  NotesViews.swift
//  SpartanTutors
//
//  Created by Leo on 9/8/22.
//

import SwiftUI

struct NotesViews: View {
    @ObservedObject var viewModel = NotesViewModel()
    @State var show_sheet = false
    @State var show_sheet_edit = false
    var body: some View {
        if viewModel.loading_notes{
            VStack{
                LoadingCircle()
            }
        }
        else{
            VStack{
                HStack{
                    Text("Notes")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {show_sheet.toggle()}){
                        Image(systemName: "plus.circle")
                            .foregroundColor(.black)
                    }
                    .sheet(
                        isPresented: $show_sheet){
                            EditNote(note: Note(order: viewModel.count + 1), upload_function:viewModel.upload_note)
                        }
                }
                .padding()
                
                ScrollView{
                    ForEach(viewModel.model.allNotes){ note in
                        NoteRowView(
                            note: note,
                            edit_function: viewModel.upload_note,
                            delete_function: {
                                viewModel.delete_note(note: note)
                            })
                        .padding(.horizontal)
                        

                    }
                }
            }
        }
    }
}

struct EditNote: View{
    @State var note: Note
    var upload_function: (Note) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View{
        
        VStack{
            HStack{
                Button(action: {presentationMode.wrappedValue.dismiss()}){
                    Image(systemName: "xmark")
                        .imageScale(.large)
                }
                Spacer()
                Button(action: {
                    upload_function(note)
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("Save")
                }
            }
            .padding()
            Spacer()
            HStack{
                Text("Order: ")
                Button(action: {note.order -= 1}){
                    Text("-")
                }
                Text("\(note.order)")
                Button(action: {note.order += 1}){
                    Text("+")
                }
            }
            .padding()
            TextField("Title", text: $note.title)
                .font(.largeTitle)
//                .padding()
                
            
            TextEditor(text: $note.text)
                .padding(4)
                .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray, lineWidth: 2)
                    )
//                .padding()
            
            Spacer()
        }
        .padding()
        
    }
    
}

struct NoteRowView: View{
    var note: Note
    var edit_function: (Note) -> Void
    var delete_function: () -> Void
    @State var tab = 1
    @State var show_detail = false
    
    var main_tab: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Colors.tutor_gray_row)
            
            HStack{
                VStack(alignment: .leading){
                    Text(note.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(note.text)
                        .lineLimit(2)
                }
                .padding()
                
                Spacer()
                
                VStack(spacing: 20){
                    
                    Button(action: {UIPasteboard.general.string = note.text}){
                        Image(systemName: "doc.on.clipboard")
                            .foregroundColor(.black)
                    }
                    
                    
                    Button(action:{
//                        edit_function()
                        show_detail.toggle()
                    }){
                        Image(systemName: "pencil.circle")
                            .foregroundColor(.black)
                    }
                    
                    
                }
                .imageScale(.large)
                .padding()
                .padding(.trailing,25)
                
            }
            .sheet(
                isPresented: $show_detail){
                    EditNote(note: note, upload_function:edit_function)
                }
        }
    }
    
    var cancel_tab: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Colors.tutor_gray_row)
            Button(action: {delete_function()}){
                VStack{
                    Text("Delete note")
                        .foregroundColor(.black)
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(red: 0.82, green: 0.1, blue: 0.1))
                        .imageScale(.medium)
                }
            }
        }
    }
    
    var body: some View{
        
        TabView(selection: $tab){
            main_tab
                .tag(1)
            cancel_tab
                .tag(2)
        }
        .background(Colors.tutor_gray_row)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .aspectRatio(3, contentMode: .fit)
        .animation(.easeIn(duration: 0.6), value: tab)
    }
}


//struct NotesViews_Previews: PreviewProvider {
//    static var previews: some View {
//        NoteRowView(note: Note(note: ["id": "123", "title": "Test note", "text": "test 123", "order": 1]))
//    }
//}
