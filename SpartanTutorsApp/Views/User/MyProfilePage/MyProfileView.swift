
import SwiftUI
//
//struct BorderedView<Content: View>: View {
//    let content: Content
//
//    init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }


struct MyProfile<Content: View>: View {
    @EnvironmentObject var signOut: AuthenticationViewModel
    @ObservedObject var viewModel: ProfileViewModel
    var id:String
    let content: (Binding<Bool>, String) -> Content
    
    @State var link = "https://www.apple.com/"
    @State var show_edit_info = false
    
    init(viewModel:ProfileViewModel,id:String, @ViewBuilder content: @escaping (Binding<Bool>, String) -> Content){
        self.viewModel = viewModel
        self.id = id
        self.content = content
    }
    
    var body: some View {
        NavigationView{
            VStack(spacing: 0){
                //Title
                title
                    .ignoresSafeArea(edges:.top)
                    .frame(maxHeight: 120)
                    .padding(.bottom)
                
                NavigationLink(
//                    destination:EditInfoView(show_edit_view: $show_edit_info, id: self.id),
                    destination:content($show_edit_info, self.id),
                    isActive:$show_edit_info){
                    EmptyView()
                }
                
                //Contact us
                
                profile_row(
                    text: "FAQ",
                    tap_function: {
                        link = "https://spartantutorsmsu.com/faq/"
                        viewModel.show_safari.toggle()
                    })
                
                
                Divider()
                    .padding(.horizontal)
                //FAQ
                
                profile_row(
                    text: "Cancellation Policy",
                    tap_function: {
                        link = "https://spartantutorsmsu.com/cancellation/"
                        viewModel.show_safari.toggle()
                    })
                Divider()
                    .padding(.horizontal)
                
                profile_row(
                    text: "Privacy Policy",
                    tap_function: {
                        link = "https://spartantutorsmsu.com/privacy/"
                        viewModel.show_safari.toggle()
                    })
                
                Spacer()
                
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $viewModel.show_safari, content: {
            SFSafariViewWrapper(url: URL(string: link)!)
        })
         
    }
    
    var title: some View{
        ZStack(alignment: .bottomLeading){
            Rectangle()
                .foregroundColor(Color(red: 0.08, green: 0.35, blue: 0.08))
            VStack(alignment: .leading,spacing: 0){
                Spacer()
                Text("\(viewModel.name)")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                    .foregroundColor(.white)
                
                HStack{
                    Text("Edit my info")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top,5)
                        .padding(.bottom,10)
                        .onTapGesture {
                            show_edit_info.toggle()
                        }
                    Spacer()
                    Button(action: signOut.signOut) {
                      Text("Sign out")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top,5)
                        .padding(.bottom,10)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color(.systemIndigo))
//                        .cornerRadius(12)
//                        .padding()
                    }
                }
                
            }
        }
    }
}

struct profile_row: View{
    var text: String
    var tap_function: () -> Void
    var body: some View{
        HStack{
            Text(text)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .onTapGesture {
            tap_function()
        }
    }
}


