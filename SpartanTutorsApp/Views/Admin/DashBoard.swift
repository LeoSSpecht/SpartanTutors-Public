//
//  DashBoard.swift
//  SpartanTutors
//
//  Created by Leo on 8/16/22.
//

import SwiftUI

struct AdminDashBoard: View {
    @ObservedObject var viewModel:calendarVM
    @Binding var date: Date
    @EnvironmentObject var sessionsModel: AdminAllSessions
    
    static var graph_size: CGFloat = 200
    var box_size: CGFloat = graph_size + 150
    var body: some View {
        VStack{
            Header_end()
            Spacer()
           
            let sessions_on_week = sessionsModel.get_data_points(dates: viewModel.week_days, session_status: "Approved")
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.horizontal,15)
                    .padding(.top,15)
                    .padding(.bottom,5)
                
                VStack(spacing: 15){
                    BarGraph(data_points: sessions_on_week, color: Color.green, title: "Sessions on week")
                        .padding(.horizontal,50)
                        .frame(maxHeight: AdminDashBoard.graph_size)
                    CalendarView(calendarViewModel:viewModel, selected_date: $date, weekly_schedule: Binding.constant(nil),is_month_bottom: true)
                        
                }
            }
            .frame(maxHeight: box_size)

            let total_sessions_week = sessions_on_week.sum_sessions()
            let size: CGFloat = 100
            HStack{
                CardView(size: CGSize(width: size, height: size), text: "Sessions this week", number: Double(total_sessions_week))
                Spacer()
                CardView(size: CGSize(width: size, height: size), text: "Sessions today", number: Double(sessionsModel.sessions_today(date: date, status: "Approved")))
                Spacer()
                CardView(size: CGSize(width: size, height: size), text: "Pending sessions", number: Double(sessionsModel.pending_future.count))
            }
            .animation(nil, value: viewModel.startingIndex)
            .frame(maxHeight:105)
            .padding(.horizontal,45)
            .padding(.top,20)
            HStack(spacing:0){
                TabView{
                    CardView(size: CGSize(width: size, height: size), text: "Sessions this month", number: Double(sessionsModel.session_on_month(date: date, status: "Approved")))
                    CardView(size: CGSize(width: size, height: size), text: "Total sessions", number: Double(sessionsModel.all_sessions.filter({$0.status == "Approved"}).count))
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//                .frame(maxWidth: 105)
                
                
                TabView{
                    CardView(size: CGSize(width: 210, height: size), text: "Week's profit", number: sessionsModel.profit_on_period(date: date,component: .weekOfYear), format: .money)
                    CardView(size: CGSize(width: 210, height: size), text: "Day's profit", number: sessionsModel.profit_on_period(date: date, component: .day), format: .money)
                    CardView(size: CGSize(width: 210, height: size), text: "Month's profit", number: sessionsModel.profit_on_period(date: date,component: .month), format: .money)
                    CardView(size: CGSize(width: 210, height: size), text: "Year's profit", number: sessionsModel.profit_on_period(date: date,component: .year), format: .money)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(minWidth:225)
            }
            .animation(nil, value: viewModel.startingIndex)
            .frame(maxHeight:105)
            .padding(.horizontal,40)
            .padding(.top,10)
            Spacer()
        }
    }
}
