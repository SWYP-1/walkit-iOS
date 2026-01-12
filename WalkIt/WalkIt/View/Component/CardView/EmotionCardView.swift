

import SwiftUI


struct EmotionCardView: View {
    @Binding var emotion: String
    @Binding var count: String
    let day: String
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("이번주 나의 주요 감정은?")
                        .font(.subheadline)
                        .foregroundStyle(getTextColor(emotion: emotion))
                    Text(emotionKOR(emotion: emotion))
                        .font(.title).bold()
                        .foregroundStyle(Color(.black))
                    Text(getText(emotion: emotion))
                        .font(.footnote)
                        .foregroundStyle(getTextColor(emotion: emotion))
                }
                Spacer()
            }
            HStack(alignment: .top) {
                Spacer()
                if(emotion == "") {
                    Image("EMPTYCard")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 40)
                } else {
                    Image("\(emotion)Card")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 40)
                }
            }
        }
        .padding(16)
        .background { getBackgroundColor(emotion: emotion) }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    func emotionKOR(emotion: String) -> String {
        switch(emotion) {
        case "DELIGHTED": return "기쁨"
        case "JOYFUL": return "즐거움"
        case "HAPPY": return "행복"
        case "DEPRESSED": return "우울"
        case "TIRED": return  "지침"
        case "IRRITATED": return "짜증남"
        default : return "기록이 없어요"
        }
    }
    
    func getText(emotion: String) -> String {
        switch(emotion) {
        case "DELIGHTED": return "기쁜 감정을 \(self.day) \(self.count)회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?"
        case "JOYFUL": return "즐거운 감정을 \(self.day) \(self.count)회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?"
        case "HAPPY": return "행복한 감정을 \(self.day) \(self.count)회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?"
        case "DEPRESSED": return "우울한 감정을 \(self.day) \(self.count)회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?"
        case "TIRED": return "지친 감정을 \(self.day) \(self.count)회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?"
        case "IRRITATED": return "짜증난 감정을 \(self.day) \(self.count)회 경험했어요!\n남은 일상도 워킷과 함께 즐겁게 보내볼까요?"
        default: return "아직 산책 기록이 없어요!\n남은 일상을 워킷과 함께 보내볼까요?"

        }
    }
    
    func getTextColor(emotion: String) -> Color {
        switch(emotion) {
        case "DELIGHTED": return Color(hex: "#A67D03")
        case "JOYFUL": return Color(hex: "#2ABB42")
        case "HAPPY": return Color(hex: "#F76476")
        case "DEPRESSED": return Color(hex: "#1D7AFC")
        case "TIRED": return Color(hex: "#6E5DC6")
        case "IRRITATED": return Color(hex: "#FFF0EE")
        default: return Color(hex: "#818185")
        }
    }
    
    func getBackgroundColor(emotion: String) -> Color {
        switch(emotion) {
        case "DELIGHTED": return Color(hex: "#FBE574")
        case "JOYFUL": return Color(hex: "#86E27E")
        case "HAPPY": return Color(hex: "#FDD0D5")
        case "DEPRESSED": return Color(hex: "#84B8FF")
        case "TIRED": return Color(hex: "#B8ACF6")
        case "IRRITATED": return Color(hex: "#E65C4A")
        default: return Color(hex: "#F5F5F5")
        }
    }
    
}
