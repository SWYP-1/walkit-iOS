//
//  WalkRecordRootView.swift
//  WalkIt
//
//  Created by 조석진 on 1/3/26.

import SwiftUI
import Kingfisher

struct WalkRecordRootView: View {
    @ObservedObject var vm: WalkViewModel
    init(vm: WalkViewModel) { self.vm = vm }

    var body: some View {
        ZStack {
            VStack {
                if(vm.walkRootViewIndex != .checkRecordingView) {
                    HStack(spacing: 10) {
                        Capsule()
                            .foregroundStyle(Color(hex: "#52CE4B"))
                            .frame(maxWidth: .infinity, maxHeight: 5)
                        Capsule()
                            .foregroundStyle(vm.walkRootViewIndex != .emotionAfterWalkView ? Color(hex: "#52CE4B") : Color(hex: "#F3F3F5"))
                            .frame(maxWidth: .infinity, maxHeight: 5)
                        Capsule()
                            .foregroundStyle(Color(hex: "#F3F3F5"))
                            .frame(maxWidth: .infinity, maxHeight: 5)
                    }
                    .padding(.horizontal, 25)
                }
                
                ZStack {
                    VStack {
                        ScrollView {
                            HStack(spacing: 10) {
                                Capsule()
                                    .foregroundStyle(Color(hex: "#52CE4B"))
                                    .frame(maxWidth: .infinity, maxHeight: 5)
                                Capsule()
                                    .foregroundStyle(Color(hex: "#52CE4B"))
                                    .frame(maxWidth: .infinity, maxHeight: 5)
                                Capsule()
                                    .foregroundStyle(Color(hex: "#52CE4B"))
                                    .frame(maxWidth: .infinity, maxHeight: 5)
                            }
                            .padding(.horizontal, 25)
                            
                            Text("오늘도 산책 완료!")
                                .font(.title).bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 0) {
                                Text("이번주")
                                    .font(.title3)
                                    .foregroundColor(Color(hex: "#818185"))
                                Text(" \(vm.weekWalkCount)번째 ")
                                    .font(.title3)
                                    .foregroundColor(Color(hex: "#76BFCC"))
                                Text("산책을 완료했어요")
                                    .font(.title3)
                                    .foregroundColor(Color(hex: "#818185"))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            ZStack {
                                KakaoMapView(walkRoutes: vm.getWalkRoutes(points: vm.points), onCoordinatorReady: { coordinator in
                                    vm.kakaoCoordinator = coordinator
                                })
                                    .frame(width: vm.width, height: vm.width)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .opacity((vm.walkRootViewIndex == .checkRecordingView) && (vm.savedImage == nil) ? 1 : 0.01)
                                if let uiImage = vm.savedImage, vm.walkRootViewIndex == .checkRecordingView {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: vm.width, height: vm.width)
                                        .clipShape( RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            
                            if vm.walkRootViewIndex == .checkRecordingView {
                                CheckRecordingView(vm: vm)
                            }
                        }
                        .opacity(vm.walkRootViewIndex == .checkRecordingView ? 1 : 0.01)
                    }
                    
                    if vm.walkRootViewIndex == .emotionAfterWalkView {
                        EmotionAfterWalkView(vm: vm)
                    }
                    
                    if vm.walkRootViewIndex == .walkRecordView {
                        WalkRecordView(vm: vm)
                    }
                    
                    if(vm.showSavingProgress) {
                        Color(hex: "#000000").opacity(0.5).ignoresSafeArea()
                        ProgressView()
                    }
                    
                    if(vm.showSavingSuccess) {
                        Color(hex: "#000000").opacity(0.5).ignoresSafeArea()
                        VStack {
                            HStack {
                                Text("산책 감정 기록이")
                                    .font(.title2)
                                    .foregroundStyle(Color(hex: "#191919"))
                                +
                                Text(" 완료")
                                    .font(.title2)
                                    .foregroundStyle(Color(hex: "#2ABB42"))
                                +
                                Text("되었습니다!")
                                    .font(.title2)
                                    .foregroundStyle(Color(hex: "#191919"))
                            }
                            
                            Text("완료된 산책 기록을 친구들에게 공유할 수 있어요")
                                .foregroundStyle(Color(hex: "#818185"))
                                .multilineTextAlignment(.center)
                            
                            Button {
                                vm.emotionBeforeWalk = ""
                                vm.reset()
                                vm.goHome()
                            } label: {
                                Text("확인")
                                    .foregroundStyle(Color(hex: "#FFFFFF"))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: "#52CE4B"))
                                    )
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        .background(
                            Color(hex: "#FFFFFF")
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.vertical, 20)
            
            if(vm.showingAlertExit) {
                Color(hex: "#000000").opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        vm.showingAlertExit = false
                    }
                
                VStack {
                    HStack(spacing: 0) {
                        Text("산책 기록을")
                            .font(.title2).bold()
                            .foregroundStyle(Color(hex: "#191919"))
                        Text(" 중단")
                            .font(.title2).bold()
                            .foregroundStyle(Color(hex: "#FF3B21"))
                        Text("하시겠습니까?")
                            .font(.title2).bold()
                            .foregroundStyle(Color(hex: "#191919"))
                    }
                    .padding(.bottom, 10)

                    Text("이대로 종료하시면 작성한 산책 기록이 모두 사라져요!")
                        .foregroundStyle(Color(hex: "#818185"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                    
                    HStack {
                        Button {
                            vm.emotionBeforeWalk = ""
                            vm.reset()
                            vm.goHome()
                        } label: {
                            Text("중단하기")
                                .foregroundStyle(Color(hex: "#191919"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "#191919"), lineWidth: 1)
                                )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#191919"), lineWidth: 1)
                        )
                        
                        Button {
                            vm.showingAlertExit = false
                        } label: {
                            Text("계속하기")
                                .foregroundStyle(Color(hex: "#FFFFFF"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "#191919"))
                                )
                        }
                        .background( Color(hex: "#191919") )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 20)
                .background(
                    Color(hex: "#FFFFFF")
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                )
                .padding(.horizontal, 20)
            }
        }
        .background(vm.walkRootViewIndex == .checkRecordingView ? Color(hex: "#F5F5F5") : Color(hex: "#FFFFFF"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}
#Preview {
    WalkRecordRootView(vm: WalkViewModel())
}
