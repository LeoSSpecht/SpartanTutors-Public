import SwiftUI

struct StudentViewAdmin: View {
    @ObservedObject var AllStudents: StudentsAdminViewModel
    @EnvironmentObject var sessionModel: AdminAllSessions
    @EnvironmentObject var tab_manager: AdminTabManager
    var body: some View {
        VStack(spacing: 0){
            Header_end()
            ScrollView{
                VStack(alignment: .leading, spacing: 0){
                    HStack{
                        Text("Students")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding()
                        Spacer()
                        Text("No. of students: \(AllStudents.students.count)")
                            .font(.callout)
                            .padding()
                    }
                    
                    TextField("Student", text: $AllStudents.filter_names)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    ForEach(AllStudents.students){student in
                        StudentRow(student:student,
                                 filter_function: {
                                    sessionModel.filtered_id = student.id
                                    tab_manager.tab = .sessions
                                 })
                            .aspectRatio(3,contentMode: .fill)
                            .padding([.top, .leading, .trailing],6)
                    }
                }
            }
            
        }
        
    }
}
