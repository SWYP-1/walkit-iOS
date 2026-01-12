//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import CoreLocation

struct WeekView: View {
    @ObservedObject var vm: WalkingRecordViewModel
    init(vm: WalkingRecordViewModel) { self.vm = vm }
    
    var body: some View {
        ScrollView {
            VStack {
                weeklyCard
                WalkItCountView(leftTitle: "평균 걸음", rightTitle: "누적 산책 시간", avgSteps: $vm.weeklyAvgSteps, walkTime: $vm.weeklyWalkTime)
                EmotionCardView(emotion: $vm.emotionWeek, count: $vm.emotionWeekCount,day: "이번 주에")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $vm.showingPicker) {
            YearMonthWheelPicker(monthAnchor: $vm.currentWeekAnchor) {
                vm.showingPicker = false
            }
            .presentationDetents([.height(280)])
        }
        .onChange(of: vm.currentWeekAnchor) { vm.setWeekView() }
    }
}

// MARK: - Sections
private extension WeekView {
    // MARK: Week
    var weeklyCard: some View {
        VStack(spacing: 12) {
            WeekHeader(currentWeek: $vm.currentWeekAnchor, showingPicker: $vm.showingPicker)
            WeekStrip(weekAnchor: vm.currentWeekAnchor,
                      selected: $vm.selectedWeekDay,
                      stampedDays: vm.weeklystampedDays)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}


// MARK: - Week Components
private struct WeekHeader: View {
    @Binding var currentWeek: Date
    @Binding var showingPicker: Bool
    
    private var title: String {
        let cal = Calendar.current
        let weekOfMonth = monthMondayIndex(for: currentWeek, calendar: cal)
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy년 M월"
        let ym = fmt.string(from: currentWeek)
        let ordinal = ["","첫","둘","셋","넷","다섯"]
        let label = weekOfMonth >= 1 && weekOfMonth < ordinal.count ? "\(ordinal[weekOfMonth])째주" : "\(weekOfMonth)째주"
        return "\(ym) \(label)"
    }
    
    var body: some View {
        HStack {
            Button {
                currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek) ?? currentWeek
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color(hex: "#818185"))
                    .padding(.trailing, 10)
            }
            Spacer()
            
            Button {
                showingPicker = true
            } label: {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color(hex: "#171717"))
            }
            
            Spacer()
            Button {
                currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? currentWeek
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color(hex: "#818185"))
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        
        let weekdays = ["일","월","화","수","목","금","토"]
        HStack {
            ForEach(weekdays, id: \.self) { w in
                Text(w)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
    }
    
    func monthMondayIndex(for date: Date, calendar: Calendar = Calendar(identifier: .gregorian)) -> Int {
        var cal = calendar
        cal.firstWeekday = 2 // 월요일 시작

        // 1️⃣ 해당 달의 첫 날
        guard let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: date)) else {
            return 1
        }

        // 2️⃣ 해당 달의 첫 월요일 찾기
        let firstWeekday = cal.component(.weekday, from: startOfMonth)
        // 월요일까지 이동 (1=일요일, 2=월요일,...)
        let offsetToMonday = (9 - firstWeekday) % 7
        guard let firstMonday = cal.date(byAdding: .day, value: offsetToMonday, to: startOfMonth) else {
            return 1
        }

        // 3️⃣ 해당 날짜가 몇 번째 월요일 이후인지 계산
        let daysDiff = cal.dateComponents([.day], from: firstMonday, to: date).day ?? 0
        let index = (daysDiff / 7) + 1 // 첫 번째 월요일 = 1

        return max(index, 1)
    }


}

private struct WeekStrip: View {
    let weekAnchor: Date
    @Binding var selected: Date?
    let stampedDays: Set<Int>
    
    private var daysOfWeek: [Date] {
        let cal = Calendar.current
        guard let weekInterval = cal.dateInterval(of: .weekOfYear, for: weekAnchor) else { return [] }
        var result: [Date] = []
        var cursor = weekInterval.start
        for _ in 0..<7 {
            result.append(cursor)
            cursor = cal.date(byAdding: .day, value: 1, to: cursor) ?? cursor
        }
        return result
    }
    
    private func dayNumber(_ date: Date) -> Int {
        Calendar.current.component(.day, from: date)
    }
    
    private func isSelected(_ date: Date) -> Bool {
        selected.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(daysOfWeek, id: \.self) { day in
                let number = dayNumber(day)
                let stamped = stampedDays.contains(number)
                
                VStack {
                    ZStack {
                        Text("\(number)")
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                        
                        Circle()
                            .fill(stamped ? Color(hex: "#76BFCC") : Color(hex: "#EBEBEE"))
                            .overlay {
                                if(stamped) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color(hex: " #FFFFFF"))
                                }
                            }
                    }
                }
                .frame(height: 46)
                .contentShape(Rectangle())
            }
        }
    }
}

#Preview {
    WeekView(vm: WalkingRecordViewModel())
}
