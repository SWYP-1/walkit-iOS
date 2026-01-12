
//
//  MyPageView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI

struct MyPageView: View {
    @ObservedObject var vm: MyPageViewModel
    let userManager = UserManager.shared
    let authManager = AuthManager.shared
    
    init(vm: MyPageViewModel) { self.vm = vm }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                ScrollView {
                    VStack {
                        HStack(alignment: .center) {
                            Text("마이 페이지")
                                .font(.title)
                        }
                        
                        Divider()
                        
                        VStack {
                            HStack {
                                Text("\(userManager.nickname) 님")
                                    .font(.largeTitle)
                                Text("Lv.\(userManager.level) \(userManager.getGrade())")
                                    .font(.title3)
                                    .foregroundStyle(Color(hex: "#6EB3BF"))
                                    .modifier(CapsuleBackground(backgroundColor: Color(hex: "#F0FCFF")))
                                Spacer()
                            }
                            
                            HStack(spacing: 0) {
                                Text("지금까지")
                                Text(" \(authManager.continuousAttendance)일 ")
                                    .foregroundStyle(Color(hex: "#52CE4B"))
                                Text("연속 출석 중!")
                                Spacer()
                            }
                            
                            if let profileImage = userManager.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            } else {
                                Image("DefaultImage")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            }
                            
                            Button {
                                vm.goNext(.editUserInfoView)
                            } label: {
                                Text("내 정보 수정")
                                    .foregroundStyle(.white)
                                    .font(.title2)
                                    .padding()
                                    .frame(width: 300)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(.green)
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Rectangle()
                            .frame(height: 10)
                            .foregroundStyle(Color(hex: "#EBEBEE"))
                        
                        VStack(spacing: 20) {
                            WalkItCountView(leftTitle: "누적 걸음 수", rightTitle: "함께 걸은 시간", avgSteps: $vm.toalSteps, walkTime: $vm.totalWalkHours)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                Text("설정")
                                    .font(.body)
                                    .bold()
                                
                                Button {
                                    vm.goNext(.alimManagerView)
                                } label: {
                                    HStack {
                                        Text("알림 설정")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.black)
                                    }
                                }
                                .foregroundStyle(.black)
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(Color(hex: "#F5F5F5"))
                            }
                            
                            VStack(alignment: .leading, spacing: 20) {
                                Text("산책 관리")
                                    .font(.body)
                                    .bold()
                                
                                Button {
                                    vm.goNext(.goalsManagerView)
                                } label: {
                                    HStack {
                                        Text("목표 관리")
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.black)
                                    }
                                }
                                .foregroundStyle(.black)
                                
                                Button {
                                    vm.goNext(.missionManagerView)
                                } label: {
                                    HStack {
                                        Text("미션")
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.black)
                                    }
                                }
                                .foregroundStyle(.black)
                                
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(Color(hex: "#F5F5F5"))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        HStack {
                            Button {
                                Task {
                                    await userManager.logOut()
                                }
                            } label: {
                                Text("로그아웃")
                                    .foregroundStyle(Color(hex: "#818185"))
                            }
                            .padding(.vertical, 20)
                            
                            Text("|")
                                .foregroundStyle(Color(hex: "#818185"))
                            
                            Button {
                                Task {
                                    vm.deleteUserAlert = true
                                }
                            } label: {
                                Text("탈퇴하기")
                                    .foregroundStyle(Color(hex: "#818185"))
                            }
                            .padding(.vertical, 20)
                        }
                        
                        VStack {
                            HStack {
                                Link("서비스 이용 약관", destination: URL(string: "https://rhetorical-bike-845.notion.site/2d59b82980b98027b91ccde7032ce622?pvs=74")!)
                                    .foregroundColor(Color(hex: "#818185"))
                                    .font(.system(size: 14))
                                
                                Divider()
                                
                                Link("개인정보처리 방침 보기", destination: URL(string: "https://rhetorical-bike-845.notion.site/2d59b82980b9805f9f4df589697a27c5")!)
                                    .foregroundColor(Color(hex: "#818185"))
                                    .font(.system(size: 14))
                                
                                Divider()
                                
                                Link("마케팅 수신 동의", destination: URL(string: "https://rhetorical-bike-845.notion.site/2d59b82980b9802cb0e2c7f58ec65ec1?pvs=74")!)
                                    .foregroundColor(Color(hex: "#818185"))
                                    .font(.system(size: 14))
                            }
                            HStack {
                                Button{
                                    let email = "walk0it2025@gmail.com"
                                    let subject = "앱 문의"
                                    let body = "안녕하세요, 앱 관련 문의드립니다."
                                    
                                    let emailString = "mailto:\(email)?subject=\(subject)&body=\(body)"
                                    if let urlString = emailString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                       let url = URL(string: urlString) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack {
                                        Text("문의하기")
                                            .foregroundColor(Color(hex: "#818185"))
                                            .font(.system(size: 14))
                                        Text("  CS 채널 안내")
                                            .foregroundStyle(Color(hex: "#C2C3CA"))
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(hex: "#F5F5F5"))
                    }
                }
                
                if(vm.deleteUserAlert) {
                    Color(hex: "#000000").opacity(0.5).ignoresSafeArea()
                        .onTapGesture { vm.deleteUserAlert = false }
                    VStack {
                        HStack(spacing: 0) {
                            Text("정말 ")
                                .font(.title2).bold()
                            Text("탈퇴")
                                .font(.title2).bold()
                                .foregroundStyle(Color(hex: "#FF3B21"))
                            Text("하시겠습니까?")
                                .font(.title2).bold()
                        }
                        .padding(.bottom, 5)
                        
                        Text("탈퇴 시 모든 정보는 6개월 간 보관됩니다\n탈퇴한 계정은 다시 복구되지 않습니다")
                            .foregroundStyle(Color(hex: "#818185"))
                            .padding(.bottom, 10)
                        
                        HStack {
                            Button {
                                vm.deleteUserAlert = false
                            } label: {
                                Text("아니요")
                                    .font(.title3)
                                    .foregroundStyle(Color(hex: "#191919"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(hex: "#191919"), lineWidth: 1)
                                    )
                                
                            }
                            
                            Button {
                                Task {
                                    await userManager.cancelMembership()
                                }
                            } label: {
                                Text("예")
                                    .font(.title3)
                                    .foregroundStyle(Color(hex: "#FFFFFF"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: "#191919"))
                                    )
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#FFFFFF"))
                    )
                    .padding(20)
                }
            }
            .background(Color.white)
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                vm.getWalkSummary()
            }
        }
    }
}

#Preview {
    MyPageView(vm: MyPageViewModel())
}

