//
//  FAQView.swift
//  SpartanTutors
//
//  Created by Leo on 7/26/22.
//

import SwiftUI

struct FAQView: View {
    @ObservedObject var questions = FAQQuestions()
    var body: some View {
        VStack(alignment:.leading){
            List(1...questions.questions.count, id: \.self){ n in
                VStack(alignment:.leading){
                    HStack{
                        Text("\(n).")
                            .bold()
                        Text(questions.questions[n]!.question)
                    }
                    .padding(7)
                    .onTapGesture {
                            questions.questions[n]!.toggle()
                    }
                    if questions.questions[n]!.showing {
                        Text(questions.questions[n]!.answer)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .padding(.leading,25)
                    }
                }
            }
        }
        .navigationBarTitle("FAQ")
    }
}

struct Question{
    var question:String
    var answer: String
    var showing: Bool = false
    
    mutating func toggle(){
        showing.toggle()
    }
}
