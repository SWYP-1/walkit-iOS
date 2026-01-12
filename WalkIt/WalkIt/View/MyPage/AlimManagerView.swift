//
//  MyPageView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import PhotosUI

struct AlimManagerView: View {
    @Binding var path: NavigationPath
    @StateObject var vm: AlimManagerViewModel
    
    init(vm: AlimManagerViewModel, path: Binding<NavigationPath>) {
        _vm = StateObject(wrappedValue: vm)
        self._path = path
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button{
                    path = NavigationPath()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                        .padding(.trailing, 10)
                }
                Spacer()
                Text("알림 설정")
                    .font(.title3)
                    .bold()
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Divider()
            
            VStack {
                HStack {
                    Text("전체 알림")
                    Spacer()
                    Button {
                        if(!vm.notificationEnabled) {
                            vm.notificationEnabled = true
                            vm.goalNotificationEnabled = true
                            vm.missionNotificationEnabled = true
                            vm.friendNotificationEnabled = true
                            vm.marketingPushEnabled = true
                            NotificationManager.shared.requestAuthorizationIfNeeded()
                        } else {
                            vm.notificationEnabled = false
                            vm.goalNotificationEnabled = false
                            vm.missionNotificationEnabled = false
                            vm.friendNotificationEnabled = false
                            vm.marketingPushEnabled = false
                        }
                    } label: {
                        Toggle("", isOn: .constant(vm.notificationEnabled))
                            .labelsHidden()
                            .allowsHitTesting(false)
                    }
                }
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(hex: "#F5F5F5"))
            }

            VStack(alignment: .leading) {
                Text("앱 정보 알림")
                    .font(.title3)
                    .bold()
                
                Toggle("목표 알림", isOn: $vm.goalNotificationEnabled)
                    .onChange(of: vm.goalNotificationEnabled) { _, newValue in
                        if(!newValue) { vm.notificationEnabled = false }
                        if(newValue) { NotificationManager.shared.requestAuthorizationIfNeeded() }
                    }
                
                Toggle("새로운 미션 오픈 알림 알림", isOn: $vm.missionNotificationEnabled)
                    .onChange(of: vm.missionNotificationEnabled) { _, newValue in
                        if(!newValue) { vm.notificationEnabled = false }
                        if(newValue) { NotificationManager.shared.requestAuthorizationIfNeeded() }
                    }
                
                Toggle("친구 요청 알림", isOn: $vm.friendNotificationEnabled)
                    .onChange(of: vm.friendNotificationEnabled) { _, newValue in
                        if(!newValue) { vm.notificationEnabled = false }
                        if(newValue) { NotificationManager.shared.requestAuthorizationIfNeeded() }
                    }
                
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(hex: "#F5F5F5"))
            }

            VStack(alignment: .leading) {
                Toggle("마케팅 푸시 동의", isOn: $vm.marketingPushEnabled)
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(hex: "#F5F5F5"))
            }
            .onChange(of: vm.marketingPushEnabled) { _, newValue in
                if(!newValue) { vm.notificationEnabled = false }
                if(newValue) { NotificationManager.shared.requestAuthorizationIfNeeded() }
            }
            
            Spacer()
            
            infoBanner
            
            
            HStack {
                OutlineActionButton(title: "뒤로가기", action: {
                    path = NavigationPath()
                })
                
                FilledActionButton(title: "저장하기", isEnable: .constant(true), isRightChevron: false) {
                    Task {
                        await vm.patchNotificationSetting()
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            Task { @MainActor in
                await vm.loadView()
            }
        }
    }
    
    var infoBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(.systemBlue))
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("기기 알림을 켜주세요.")
                    .font(.subheadline).bold()
                    .foregroundStyle(Color(.systemBlue))
                Text("정보 알림을 받기 위해 기기 알림을 켜주세요")
                    .font(.footnote)
                    .foregroundStyle(Color(.systemBlue))
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBlue).opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.systemBlue).opacity(0.35), lineWidth: 1)
        )
    }
}

#Preview {
    AlimManagerView(vm: AlimManagerViewModel(), path: .constant(NavigationPath()))
}
