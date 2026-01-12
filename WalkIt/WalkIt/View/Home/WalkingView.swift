

import SwiftUI
import Kingfisher

struct WalkingView: View {
    @ObservedObject var vm: WalkViewModel
    @State private var endWalk = false
    init(vm: WalkViewModel) { self.vm = vm }
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ZStack {
                    if(vm.useDefaultImage) {
                        Image("WalkBackGround")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height)
                    } else {
                        KFImage(URL(string: vm.backgroundImageName))
                            .retry(maxCount: 3)
                            .cacheOriginalImage()
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height)
                    }
                    
                    if(!vm.lottieJson.isEmpty) {
                        LottieCharacterView(json: vm.lottieJson)
                            .frame(width: UIScreen.main.bounds.width * 0.48)
                            .offset(y: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth) * 0.04)
                    } else {
                        ProgressView()
                    }

                    if(endWalk) {
                        VStack {
                            Spacer()
                            Spacer()
                            
                            Text("산책 종료")
                                .font(.title).bold()
                            
                            Text("산책후 감정을 기록하시겠습니까?")
                                .foregroundStyle(Color.gray)
                            
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            
                            Button(action: {
                                vm.goNext(.walkRecordRootView)
                            }, label: {
                                Text("감정 기록하기")
                                    .font(.title3)
                                    .foregroundStyle(Color(hex: "#FFFFFF"))
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity)
                                    .background { Color(hex: "#52CE4B") }
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .padding(.horizontal, 20)
                            })
                            
                            Spacer()
                        }
                    } else {
                        if(vm.weekGoalCount <= UserManager.shared.targetWalkCount) {
                            ZStack {
                                Capsule()
                                    .fill(Color(hex: "#FEF7D7"))
                                    .frame(width: 180, height: 36)
                                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                                
                                Triangle()
                                    .fill(Color(hex: "#FEF7D7"))
                                    .frame(width: 14, height: 8)
                                    .offset(y: -22)
                                
                                Text("\(vm.weekGoalCount)번째 목표 진행중")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "#D7A204"))
                                    .padding(.horizontal, 20)
                            }
                            .position(x: geo.size.width * 0.5, y: geo.size.height * 0.66)
                        }
                        VStack {
                            Text(vm.timeString(from: vm.elapsedTime))
                                .font(.title3).bold()
                                .foregroundColor(Color(hex: "#FFFFFF"))
                                .monospacedDigit()
                                .modifier(CapsuleBackground(backgroundColor: Color(hex: "#0000001A", alpha: 0.1)))
                                .padding(.top, 60)
                                .onReceive(vm.timer) { _ in
                                    guard vm.isRunning else { return }
                                    vm.elapsedTime += 1
                                }
                            
                            Spacer()
                            
                            Text("현재 걸음 수")
                                .foregroundStyle(Color(hex: "#818185"))
                            
                            Text(vm.steps.formatted(.number))
                                .font(.largeTitle, ).bold()
                                .foregroundColor(Color(hex: "#174F2A"))
                            
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            
                            HStack {
                                Spacer()
                                Button {
                                    vm.isRunning.toggle()
                                    if(vm.isRunning) {
                                        vm.reStartWalk()
                                    } else {
                                        vm.stopWalk()
                                    }
                                } label: {
                                    Image(vm.isRunning ? "StopWalk" : "ReStartWalk")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                }

                                Spacer()
                                
                                Button {
                                    vm.endTime = Int(Date().timeIntervalSince1970 * 1000)
                                    vm.elapsedTime = vm.endTime - vm.startTime
                                    vm.stopWalk()
                                    endWalk = true
                                } label: {
                                    Image("FinishWalk")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                }
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { vm.loadWalkingView() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            vm.startBackroundTime = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            vm.endBackroundTime = Date()
            vm.refreshStepHistory()
        }
    }
}
#Preview {
    WalkingView(vm: WalkViewModel())
}
