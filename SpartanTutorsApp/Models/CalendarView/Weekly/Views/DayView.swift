import SwiftUI

struct CalendarView: View {
    @ObservedObject var calendarViewModel: calendarVM
    @Binding var selected_date: Date
    var is_availability_possible = false
    var tutor_availability: [String: Bool]?
    @Binding var weekly_schedule: Int?
    var is_month_bottom = false
    
    static let size:CGFloat = 45
    static let column = GridItem(.fixed(size),spacing: 0)
    let columns = [
        column,
        column,
        column,
        column,
        column,
        column,
        column
    ]
    
    let days = [
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat",
    ]
    
    var body: some View {
        
        VStack{
            if !is_month_bottom{
                Text(calendarViewModel.month_selected)
                    .fontWeight(.bold)
                    
            }
            HStack(alignment: .top, spacing: 10){
                Button(action: {
                    withAnimation{
                        calendarViewModel.change_week(to: -1)
                    }
                }, label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.small)
                        .opacity(calendarViewModel.is_there_previous_week ? 1 : 0)
                        .foregroundColor(.black)
                    })
                VStack(spacing:0){
                    LazyVGrid(columns:columns){
                        ForEach(0...6, id: \.self){d in
                            Text("\(days[d%7])")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    .animation(nil)
                    
                    TabView(selection: $calendarViewModel.startingIndex){
                        ForEach(0...calendarViewModel.max_week_index, id:\.self){ week in
                            LazyVGrid(columns:columns){
                                ForEach(
                                    (week*7...calendarViewModel.ind_end_func(week_index: week)),
                                    id: \.self)
                                { i in
                                    let day = calendarViewModel.model.days_list[i]
                                   
                                    dayView(day: day.day_number,
                                            isValid: day.isValid,
                                            isSelected: day.isSelected,
                                            isDayAvailable: tutor_availability?[day.date.to_int_format()],
                                            is_availability_possible: is_availability_possible)
                                        .onTapGesture{
                                            if day.isValid{
                                                if calendarViewModel.choose(day.index){
                                                    selected_date = day.date
                                                }
                                            }
                                        }
                                }
                            }
                            
                            .tag(week)
                        }
                    }
                    
                    .frame(maxWidth: 315)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                }
                .frame(maxHeight: 80)
                
                Button(action: {
                    withAnimation{
                        calendarViewModel.change_week(to: 1)
                    }
                }, label: {
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .opacity(calendarViewModel.is_there_next_week ? 1 : 0)
                        .foregroundColor(.black)
                    })
                
            }
            .animation(.easeIn(duration: 0.5), value: calendarViewModel.startingIndex)
            
            if is_month_bottom{
                Text(calendarViewModel.month_selected)
                    .fontWeight(.bold)
            }
            
            if weekly_schedule != nil{
                HStack{
                    Text("No. of session/week")
                        .font(.caption)
                    HStack{
                        Button(action: {
                                if weekly_schedule! > 0{
                                    weekly_schedule! -= 1
                                }
                            }, label: {
                            Text("-").bold()
                        })
                        .opacity(weekly_schedule! > 0 ? 1 : 0)
                        
                        Text("\(weekly_schedule!)")
                            .font(.subheadline)
                        
                        Button(action: {
                                weekly_schedule! += 1
                        }, label: {
                            Text("+").bold()
                        })
                    }
                    .foregroundColor(.black)
                    .padding(5)
                    .overlay(
                        Capsule()
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
            }
            
        }
 
    }
}

struct dayView: View{
    var day: String
    var isValid: Bool
    var isSelected: Bool
    
    var isDayAvailable: Bool?
    var is_availability_possible: Bool
    var padding:CGFloat = 8
    
    var body: some View{
        GeometryReader{ geometry in
            ZStack{
                RoundedRectangle(cornerRadius: 13)
                    .stroke(isSelected ? .blue : Color.white, lineWidth: 2)
                if day == "0"{
                    Text("")
                        .font(.subheadline)
                        .foregroundColor(day_color)
                        .fontWeight(isSelected ? .bold : .regular)
                }
                else{
                    Text(day)
                        .font(.subheadline)
                        .foregroundColor(day_color)
                        .fontWeight(isSelected ? .bold : .regular)
                }
            }
        }
        .padding(5)
        .aspectRatio(1,contentMode: .fit)
    }
    
    var day_color: Color{
        let red:Color = Color(red: 220/256, green: 100/256, blue: 100/256)
        let green: Color = Color(red: 3/256, green: 20/256, blue: 3/256)
        
        if isValid{
            if is_availability_possible{
                //Make colors
                if isDayAvailable != nil{
                    return isDayAvailable! ? green : red
                }
                return red
            }
            return .black
        }
        return .gray
    }
}
