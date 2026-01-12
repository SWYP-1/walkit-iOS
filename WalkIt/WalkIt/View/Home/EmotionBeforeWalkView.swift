
import SwiftUI

struct EmotionBeforeWalkView: View {
    @ObservedObject var vm: WalkViewModel
    @State var isEnableNext = false
    @State var isFirst: Bool = true
    
    init(vm: WalkViewModel) { self.vm = vm }
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                VStack {
                    HStack {
                        Button { vm.dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Color(hex: "#191919"))
                                .padding(.trailing, 10)
                        }
                        Spacer()
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    
                    VStack {
                        Text("산책 전 나의 마음은 어떤가요?")
                            .font(.title).bold()
                        
                        Text("산책하기 전 지금 어떤 감정을 느끼는지 선택해주세요")
                            .font(.subheadline)
                            .lineLimit(1)
                            .foregroundStyle(Color.gray)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "#F5F5F5"))
                            .stroke(Color(hex: "#EBEBEE"), lineWidth: 1)
                    }
                    .padding(.top, 30)
                    
                    EmotionSlelectView(emotion: $vm.emotionBeforeWalk, value: $vm.valueBeforeWalk, isEnableNext: $isEnableNext, emosionsBadge: vm.emosionsBadge)
                    
                    HStack {
                        OutlineActionButton(title: "이전으로") {
                            vm.dismiss()
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.3)
                        
                        Button {
                            vm.startWalk()
                            vm.goNext(.walkingView)
                        } label: {
                            HStack {
                                Text("다음으로")
                                    .font(.title3)
                                    .foregroundStyle(vm.emotionBeforeWalk != "" ? Color(hex: "#FFFFFF") : Color(hex: "#818185"))
                                
                                Image(systemName: "chevron.right")
                                    .font(.title3)
                                    .foregroundStyle(vm.emotionBeforeWalk != "" ? Color(hex: "#FFFFFF") : Color(hex: "#818185"))
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(vm.emotionBeforeWalk != "" ? Color(hex: "#52CE4B") : Color(hex: "#F3F3F5"))
                            }
                        }
                        .disabled(vm.emotionBeforeWalk == "")
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            if(self.isFirst) {
                vm.reset()
                self.isFirst = false
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}





#Preview {
    EmotionBeforeWalkView(vm: WalkViewModel())
}
