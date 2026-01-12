//
//  EmotionSlelectView.swift
//  WalkIt
//
//  Created by 조석진 on 12/28/25.
//
import SwiftUI

struct EmotionSlelectView: View {
    @Binding var emotion: String
    @Binding var value: Int
    @Binding var isEnableNext: Bool
    let emosionsBadge: [EmotionBadge]
    
    var body: some View {
        GeometryReader { geo in
            let badgeCount = emosionsBadge.count
            let totalHeight = geo.size.height - CGFloat(20 * (badgeCount - 1))
            let badgeHeight = totalHeight / CGFloat(badgeCount)
            
            VStack {
                HStack(alignment: .center) {
                    VStack {
                        EmotionSlider(emotion: $emotion, value: $value)
                            .padding(.vertical, ((badgeHeight / 2) - 20))
                    }
                    .frame(width: geo.size.width / 3.5, alignment: .trailing)
                    .onChange(of: value) { _, newValue in
                        emotion = getEmotion(valeu: newValue)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(emosionsBadge) { emotionbadge in
                            HStack(spacing: 20) {
                                Image("\(emotionbadge.emotion)Circle")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(emotion == emotionbadge.emotion ? 1.1 : 1.0)

                                Text(getEmotionKOR(emotion: emotionbadge.emotion))
                                    .padding(.vertical, 5)
                                    .foregroundStyle(Color(hex: emotionbadge.textColor))
                                    .modifier(CapsuleBackground(backgroundColor: Color(hex: emotionbadge.backgroundColor)))
                                    .scaleEffect(emotion == emotionbadge.emotion ? 1.1 : 1.0)
                            }
                            .opacity((emotion == emotionbadge.emotion || emotion == "") ? 1.0 : 0.6)
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: emotion)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 20)
                
                Spacer()
            }
        }
    }
    
    func getEmotionKOR(emotion: String) -> String {
        switch(emotion) {
        case "DELIGHTED": return "기쁘다"
        case "JOYFUL": return "즐겁다"
        case "HAPPY": return "행복하다"
        case "DEPRESSED": return "우울하다"
        case "TIRED": return "지친다"
        case "IRRITATED": return "짜증난다"
        default: return ""
        }
    }
    
    func getEmotion(valeu: Int) -> String {
        switch(valeu) {
        case 5: return "DELIGHTED"
        case 4: return "JOYFUL"
        case 3: return "HAPPY"
        case 2: return "DEPRESSED"
        case 1: return "TIRED"
        case 0: return "IRRITATED"
        default: return ""
        }
    }
}
