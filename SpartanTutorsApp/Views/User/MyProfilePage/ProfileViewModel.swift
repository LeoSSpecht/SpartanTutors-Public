//
//  ProfileViewModel.swift
//  SpartanTutors
//
//  Created by Leo on 7/26/22.
//

import Foundation
class ProfileViewModel: ObservableObject{
    private (set) var id: String
    private (set) var name: String

    @Published var show_safari = false
    @Published var isFAQActive = false
    
    init(id: String, name:String){
        self.id = id
        self.name = name
    }
    
    //Update info
}

//struct ViewAgregator
