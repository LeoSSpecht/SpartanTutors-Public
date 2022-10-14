//
//  classSelectionView.swift
//  SpartanTutors
//
//  Created by Leo on 6/30/22.
//

import SwiftUI

struct classSelectionView: View {
    @ObservedObject var allClassesViewModel:classSelectionViewModel
    var body: some View {
        NavigationLink(destination: classSelectionNavigationView(allClassesViewModel: allClassesViewModel)){
            ZStack(alignment: .center){
                HStack{
                    Text("Select classes you will teach")
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.gray)
                RoundedRectangle(cornerRadius:10)
                    .stroke(lineWidth: 3)
                    .fill(allClassesViewModel.onlySelected.isEmpty ? Color.gray : Color.green)

            }
            .frame(maxHeight: 50)
            .padding(3)
        }
    }
}

struct classSelectionNavigationView: View{
    @ObservedObject var allClassesViewModel: classSelectionViewModel
    var body: some View{
        VStack{
            List(
                allClassesViewModel.class_dict.keys.sorted(by: {$0 < $1}),
                id: \.self
            ) { key in
                Button(action: {withAnimation{allClassesViewModel.select_group(key)}}){
                    HStack{
                        Text(key)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(allClassesViewModel.model.available_groups[key]! ? Angle(degrees: -180) : Angle(degrees: 0))
                    }
                    .foregroundColor(.black)
                    .animation(.easeInOut, value: allClassesViewModel.model.available_groups[key]!)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                
                if allClassesViewModel.model.available_groups[key]!{
                    let classes_in_group = allClassesViewModel.class_dict[key]!
                        ForEach(classes_in_group, id: \.id){ classObject in
                            Button(action: {
                                allClassesViewModel.update_selection(classObject)
                            }){
                                classSelectionRow(classObject: classObject)
                            }
                            .foregroundColor(.black)
                        }
                }
            }
        }
        .navigationBarTitle("Select classes")
        
        
    }
}
struct classSelectionRow: View{
    var classObject: classSelection
    var body: some View{
        HStack{
            Text(classObject.id)
            Spacer()
            if classObject.isSelected{
//                Spacer()
                Image(systemName: "checkmark.circle.fill")
            }
        }
//        .padding(.vertical,5)
        .padding(.horizontal)
        .padding(.leading, 20)
    }
}

struct EditClassSelectionView: View {
    @ObservedObject var allClassesViewModel:EditInfoTutorViewModel
    var body: some View {
        NavigationLink(destination: EditClassSelectionNavigationView(allClassesViewModel: allClassesViewModel)){
            ZStack(alignment: .center){
                HStack{
                    Text("Select classes you will teach")
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.gray)
                RoundedRectangle(cornerRadius:10)
                    .stroke(lineWidth: 3)
                    .fill(allClassesViewModel.onlySelected.isEmpty ? Color.gray : Color.green)

            }
            .frame(minHeight:50,maxHeight: 50)
            .padding(3)
        }
    }
}

struct EditClassSelectionNavigationView: View{
    @ObservedObject var allClassesViewModel: EditInfoTutorViewModel
    var body: some View{
        VStack{
            List(
                allClassesViewModel.class_dict.keys.sorted(by: {$0 < $1}),
                id: \.self
            ) { key in
                Button(action: {withAnimation{allClassesViewModel.select_group(key)}}){
                    HStack{
                        Text(key)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(allClassesViewModel.class_model.available_groups[key]! ? Angle(degrees: -180) : Angle(degrees: 0))
                    }
                    .foregroundColor(.black)
                    .animation(.easeInOut, value: allClassesViewModel.class_model.available_groups[key]!)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                if allClassesViewModel.class_model.available_groups[key]!{
                    let classes_in_group = allClassesViewModel.class_dict[key]!
                        ForEach(classes_in_group, id: \.id){ classObject in
                            Button(action: {
                                allClassesViewModel.update_selection(classObject)
                            }){
                                classSelectionRow(classObject: classObject)
                            }
                            .foregroundColor(.black)
                        }
                }
                
            }
        }
        .navigationBarTitle("Select classes")
        
        
    }
}


