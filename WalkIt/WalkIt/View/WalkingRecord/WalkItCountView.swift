//
//  WalkCard.swift
//  WalkIt
//
//  Created by 조석진 on 12/14/25.
//

import SwiftUI
import CoreLocation

struct WalkItCountView: View {
    var leftTitle: String
    var rightTitle: String
    @Binding var avgSteps: Int
    @Binding var walkTime: Int
    var walkHours: String { String(walkTime / 3_600_000) }
    var walkMinute: String { String((walkTime % 3_600_000) / 60_000) }
    var body: some View {
        HStack(spacing: 4) {
            StatTile(title: leftTitle, value: "\(avgSteps.formatted())", unit: "걸음")
            Divider()
                .frame(width: 1)
                .padding(.vertical, 10)
            TimeTile(title: rightTitle, time: walkHours, minute: walkMinute)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    private struct StatTile: View {
        let title: String
        let value: String
        let unit: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color(hex: "#191919"))
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    (
                    Text(value)
                        .font(.system(size: 24, weight: .bold))
                    + Text(" " + unit)
                        .font(.callout)
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color(hex: "#191919"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
    }
    private struct TimeTile: View {
        let title: String
        
        let time: String
        let minute: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color(hex: "#191919"))
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    if(time != "0") {
                        (
                            Text(time)
                                .font(.system(size: 24, weight: .bold))
                            + Text("시간 ")
                                .font(.callout)
                            + Text(minute)
                                .font(.system(size: 24, weight: .bold))
                            + Text("분")
                                .font(.callout)
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color(hex: "#191919"))
                    } else {
                        (
                            Text(minute)
                                .font(.system(size: 24, weight: .bold))
                            + Text("분")
                                .font(.callout)
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color(hex: "#191919"))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
    }
}

#Preview {
    WalkItCountView(leftTitle: "", rightTitle: "", avgSteps: .constant(8000), walkTime: .constant(123124214123123))
}
