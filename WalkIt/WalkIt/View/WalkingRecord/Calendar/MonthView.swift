//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import CoreLocation

struct MonthView: View {
    @ObservedObject var vm: WalkingRecordViewModel
    init(vm: WalkingRecordViewModel) { self.vm = vm }
    
    var walk: [WalkRecordEntity] = []
    var body: some View {
        VStack(spacing: 16) {
            calendarCard
            WalkItCountView(leftTitle: "평균 걸음", rightTitle: "누적 산책 시간", avgSteps: $vm.monthAvgSteps, walkTime: $vm.monthWalkTime)
            EmotionCardView(emotion: $vm.emotionMonth, count: $vm.emotionMonthCount, day: "이번 달에")
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $vm.showingPicker) {
            YearMonthWheelPicker(monthAnchor: $vm.currentMonthAnchor) {
                vm.showingPicker = false
            }
            .presentationDetents([.height(280)])
        }
        .onChange(of: vm.currentMonthAnchor) {
            vm.setMothView()
            Task {
                await vm.getMissionCompletedMonthly()
            }
        }
    }
}

// MARK: - Sections
private extension MonthView {
    // MARK: Month
    var calendarCard: some View {
        VStack(spacing: 12) {
            CalendarHeader(currentMonth: $vm.currentMonthAnchor, showingPicker: $vm.showingPicker)
            
            MonthGrid(
                monthAnchor: vm.currentMonthAnchor,
                selected: $vm.selectedDate,
                stampedDays: vm.monthStampedDays,
                stampedMissionDays: vm.monthMissionStampedDays,
                onDaySelected: { day in
                    vm.currentDay = day
                    vm.getDayView(date: day)
                    vm.goNext(.dayView)
                }
            )
            .padding(.horizontal, 8)
            
            HStack {
                Circle().fill(Color(hex: "#52CE4B")).frame(width: 9, height: 9)
                Text("산책")
                Circle().fill(Color(hex: "#B2F2FF")).frame(width: 9, height: 9)
                Text("미션")
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

private struct CalendarHeader: View {
    @Binding var currentMonth: Date
    @Binding var showingPicker: Bool
    let weekdays = ["일","월","화","수","목","금","토"]

    private var title: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy년 M월"
        return fmt.string(from: currentMonth)
    }
    
    var body: some View {
        HStack {
            Button {
                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
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
                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color(hex: "#818185"))
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        
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
}

private struct MonthGrid: View {
    let monthAnchor: Date
    @Binding var selected: Date?
    let stampedDays: Set<Int>
    let stampedMissionDays: Set<Int>
    var onDaySelected: ((Date) -> Void)? = nil
    
    private var days: [Date] {
        let cal = Calendar.current
        guard let monthInterval = cal.dateInterval(of: .month, for: monthAnchor) else {
            return []
        }
        let firstWeekStart = cal.dateInterval(of: .weekOfMonth, for: monthInterval.start)?.start ?? monthInterval.start
        let lastWeekEnd = cal.dateInterval(of: .weekOfMonth, for: monthInterval.end.addingTimeInterval(-1))?.end ?? monthInterval.end
        
        var result: [Date] = []
        var cursor = firstWeekStart
        while cursor < lastWeekEnd {
            result.append(cursor)
            cursor = cal.date(byAdding: .day, value: 1, to: cursor) ?? cursor
            if cursor == result.last { break }
        }
        return result
    }
    
    private func isInCurrentMonth(_ date: Date) -> Bool {
        let cal = Calendar.current
        return cal.isDate(date, equalTo: monthAnchor, toGranularity: .month)
    }
    
    private func dayNumber(_ date: Date) -> Int {
        Calendar.current.component(.day, from: date)
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
            ForEach(days, id: \.self) { day in
                let inMonth = isInCurrentMonth(day)
                let number = dayNumber(day)
                let isSelected = selected.map { Calendar.current.isDate($0, inSameDayAs: day) } ?? false
                let isWalkStamped = stampedDays.contains(number) && inMonth
                let isMissionStamped = stampedMissionDays.contains(number) && inMonth
                
                VStack {
                    Text("\(number)")
                        .font(.body)
                        .foregroundStyle(inMonth ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                    
                    HStack {
                        if isWalkStamped {
                            Circle().fill(Color(hex: "#52CE4B")).frame(width: 7, height: 7)
                        }
                        if isMissionStamped {
                            Circle().fill(Color(hex: "#B2F2FF")).frame(width: 7, height: 7)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 6)
                .frame(height: 60)
                .background {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(isSelected ? Color(hex: "#76BFCC") : .clear, lineWidth: 1)
                        .background {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(isSelected ? Color(Color(hex: "#F0FCFF")) : .clear)
                        }
                }
                .onTapGesture {
                    guard inMonth else { return }
                    selected = day
                    if(isWalkStamped) {
                        onDaySelected?(day)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
