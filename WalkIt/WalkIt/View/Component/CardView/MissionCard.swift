//
//  MissionCard.swift
//  WalkIt
//
//  Created by 조석진 on 12/27/25.
//

import SwiftUI

struct MissionCard: View {
    let mission: Mission
    let action: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(borderColor, lineWidth: 1.5)
                )
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text(categoryText)
                            .font(.footnote).bold()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(categoryBackgroundColor))
                            .foregroundStyle(categoryColor)
                        
                        if(mission.status == .inProgress || mission.status == .completed) {
                            Text(monthWeekString(from: Int(mission.weekStart) ?? 0))
                                .font(.footnote).bold()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color(hex: "#F6F4FF")))
                                .foregroundStyle(Color(hex: "#6E5DC6"))
                        }
                    }
                    
                    Text(mission.title)
                        .font(.title3).bold()
                        .foregroundStyle(titleColor)
                    
                    Text("\(mission.rewardPoints) P")
                        .font(.subheadline)
                        .foregroundStyle(expColor)
                }
                
                Spacer()
                
                rightButton
                    .disabled(mission.status != .inProgress)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var rightButton: some View {
        let missions = [3, 5, 7, 5000, 20000, 30000, 50000, 100000]
        var status = false
        switch mission.status {
        case .inProgress:
            if(mission.type == MissionType.steps.rawValue) {
                if(missions.count < mission.missionId) {
                    status = RealmManager.shared.hasContinuousAttendanceThisWeek(requiredDays: missions[mission.missionId])
                }
            } else {
                if(missions.count < mission.missionId) {
                    status = RealmManager.shared.hasExceededWeeklySteps(targetSteps: missions[mission.missionId])
                }
            }
            if(status) {
                return Button(action: action, label: {
                    Text("보상받기")
                        .font(.headline)
                        .foregroundStyle(buttonTextColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8).fill(buttonColor)
                        )
                })
            } else {
                return Button(action: action, label: {
                    Text("도전하기")
                        .font(.headline)
                        .foregroundStyle(buttonTextColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8).fill(buttonColor)
                        )
                })
            }
        case .completed:
            return Button(action: action, label: {
                Text("완료")
                    .font(.headline)
                    .foregroundStyle(buttonTextColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(buttonColor)
                    )
            })
        default:
            return Button(action: action, label: {
                Text("도전하기")
                    .font(.headline)
                    .foregroundStyle(buttonTextColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(buttonColor)
                    )
            })

        }
    }
    
    private var backgroundColor: Color {
        switch mission.status {
        case .inProgress:
            return Color(hex: "#FFFFFF")
        case .completed:
            return Color(hex: "#FFFFFF")
        default:
            return Color(hex: "#F5F5F5")
        }
    }
    
    private var buttonTextColor: Color {
        switch mission.status {
        case .inProgress:
            return Color(hex: "#FFFFFF")
        case .completed:
            return Color(hex: "#818185")
        default:
            return Color(hex: "#818185")
        }
    }
    
    private var borderColor: Color {
        switch mission.status {
        case .inProgress:
            return Color(hex: "#191919")
        case .completed:
            return Color(hex: "#191919")
        default:
            return Color(hex: "#EBEBEE")
        }
    }
    
    private var titleColor: Color {
        switch mission.status {
        case .inProgress:
            return Color(hex: "#191919")
        case .completed:
            return Color(hex: "#191919")
        default:
            return Color(hex: "#818185")
        }
    }
    
    private var expColor: Color {
        switch mission.status {
        case .inProgress:
            return Color(hex: "#2ABB42")
        case .completed:
            return Color(hex: "#2ABB42")
        default:
            return Color(hex: "#C2C3CA")
        }
    }
    
    private var buttonColor: Color {
        switch mission.status {
        case .inProgress:
            return Color(hex: "#191919")
        case .completed:
            return Color(hex: "#EBEBEE")
        default:
            return Color(hex: "#EBEBEE")
        }
    }
    
    private var categoryText: String {
        switch mission.type {
        case "CHALLENGE_STEPS": "걸음 수"
        case "CHALLENGE_ATTENDANCE": "연속 출석"
        default: "걸음 수"
        }
    }
    
    private var categoryColor: Color {
        switch mission.status {
        case .inProgress:
            return Color(hex: "#1D7AFC")
        case .completed:
            return Color(hex: "#1D7AFC")
        default:
            return Color(hex: "#818185")
        }
    }
    
    private var categoryBackgroundColor: Color {
        switch mission.status {
        case .inProgress:
            return Color(hex: "#E9F2FF")
        case .completed:
            return Color(hex: "#E9F2FF")
        default:
            return Color(hex: "#EBEBEE")
        }
    }
    
    func monthWeekString(from unixTimeMillis: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimeMillis) / 1000)

        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.firstWeekday = 1

        let month = calendar.component(.month, from: date)
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!

        let weekOfYearForDate = calendar.component(.weekOfYear, from: date)
        let weekOfYearForFirstDay = calendar.component(.weekOfYear, from: firstDayOfMonth)

        let weekOfMonth = weekOfYearForDate - weekOfYearForFirstDay + 1

        return String(format: "%d월 %d주차", month, weekOfMonth)
    }

}

