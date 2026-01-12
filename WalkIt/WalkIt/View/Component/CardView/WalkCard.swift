//
//  WalkCard.swift
//  WalkIt
//
//  Created by 조석진 on 12/14/25.
//

import SwiftUI
import CoreLocation
import KakaoMapsSDK
import Kingfisher

struct WalkCard: View {
    let walk: WalkRecordEntity
    var dateText: String {
        let date = Date(timeIntervalSince1970: Double(walk.startTime / 1000))
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    
    var walkHours: String { String(walk.totalTime / 3_600_000) }
    var walkMinute: String { String((walk.totalTime % 3_600_000) / 60_000) }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                if(walk.imageUrl != "") {
                    if let imageURL = walk.imageUrl {
                        KFImage(URL(string: imageURL))
                            .placeholder { ProgressView() }
                            .retry(maxCount: 3)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 230, height: 230)
                            .padding(.top, 1)
                    }
                } else {
                    Color.clear.frame(width: 230, height: 230)
                }
                
                Divider()
                VStack {
                    HStack {
                        Text(dateText)
                            .font(.body)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                    
                    HStack {
                        HStack(alignment: .firstTextBaseline) {
                            (
                            Text(walk.stepCount.formatted())
                                .font(.system(size: 20))
                            + Text("걸음")
                                .font(.system(size: 14))
                            )
                            .lineLimit(1)
                            .layoutPriority(1)
                            .minimumScaleFactor(0.9)
                            .foregroundStyle(Color(hex: "#191919"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Rectangle()
                            .frame(width: 1, height: 18)
                            .foregroundStyle(Color(hex: "#D7D9E0"))
                        
                        HStack(alignment: .firstTextBaseline) {
                            if(walkHours != "0") {
                                (
                                    Text(walkHours)
                                        .font(.system(size: 20))
                                    + Text("시간 ")
                                        .font(.system(size: 14))
                                    + Text(walkMinute)
                                        .font(.system(size: 20))
                                    + Text("분")
                                        .font(.system(size: 14))
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
                                .layoutPriority(1)
                                .foregroundStyle(Color(hex: "#191919"))
                                
                            } else {
                                (
                                    Text(walkMinute)
                                        .font(.system(size: 20))
                                    + Text("분")
                                        .font(.system(size: 14))
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(Color(hex: "#FFFFFF"))
            }
            Image("\(walk.postWalkEmotion ?? "")Circle")
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .padding(.bottom, 55)
                .padding(.trailing, 10)
        }
        .frame(width: 230, height: 290)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#D7D9E0"), lineWidth: 1)   
        }
    }
}

#Preview {
    WalkCard(walk: WalkRecordEntity())
}
