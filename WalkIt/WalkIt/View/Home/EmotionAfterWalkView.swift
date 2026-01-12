//
import SwiftUI

struct EmotionAfterWalkView: View {
    @ObservedObject var vm: WalkViewModel
    @State private var isEnableNext = false
    let width = UIScreen.main.bounds.width - 40
    
    init(vm: WalkViewModel) { self.vm = vm }
    
    @State private var emotionGrade: CGFloat = 1
    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geo in
                    VStack {
                        VStack {
                            Text("산책 후 나의 마음은 어떤가요?")
                                .font(.title).bold()
                            
                            Text("산책 후 감정이 어떻게 변했는지 기록해주세요")
                                .lineLimit(1)
                                .foregroundStyle(Color.gray)
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#F5F5F5"))
                                .stroke(Color(hex: "#EBEBEE"), lineWidth: 1)
                        }
                        
                        EmotionSlelectView(emotion: $vm.emotionAfterWalk, value: $vm.valueAfterWalk, isEnableNext: $isEnableNext, emosionsBadge: vm.emosionsBadge)
                        
                        HStack {
                            OutlineActionButton(title: "닫기") {
                                vm.showingAlertExit = true
                            }
                            .frame(width: geo.size.width / 3.5)
                            
                            Button {
//                                vm.goNext(.recordTextView)
                                vm.walkRecordGoNext()
                            } label: {
                                HStack {
                                    Text("다음으로")
                                        .font(.title3)
                                        .foregroundStyle(vm.emotionAfterWalk != "" ? Color(hex: "#FFFFFF") : Color(hex: "#818185"))
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.title3)
                                        .foregroundStyle(vm.emotionAfterWalk != "" ? Color(hex: "#FFFFFF") : Color(hex: "#818185"))
                                    
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                                .background {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(vm.emotionAfterWalk != "" ? Color(hex: "#52CE4B") : Color(hex: "#F3F3F5"))
                                }
                            }
                            .disabled(vm.emotionAfterWalk == "")
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .padding(.top, 52)
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}
#Preview {
    EmotionAfterWalkView(vm: WalkViewModel())
}
