//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import CoreLocation
import Kingfisher

struct WalkIngRecordView: View {
    @ObservedObject var vm: WalkingRecordViewModel
    init(vm: WalkingRecordViewModel) { self.vm = vm }
    
    var body: some View {
        NavigationStack {
            header
            Divider()
                .offset(y: 10)
                .padding(.vertical, -5)
                .foregroundStyle(Color(hex: "#EBEBEE"))
            ScrollView {
                profileRow
                VStack(spacing: 16) {
                    if(vm.selectedProfile == 0) {
                        VStack {
                            segmented
                                .padding(.vertical, 5)
                            switch vm.period {
                            case .month:
                                MonthView(vm: vm)
                            case .week:
                                WeekView(vm: vm)
                            }
                        }
                        .padding(.horizontal, 20)
                    } else {
                        FollowView(vm: vm)
                    }
                }
                .padding(.vertical, 12)
            }
            .frame(maxHeight: .infinity)
            .background(Color(hex: "#F5F5F5"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
        .background(Color(hex: "#FFFFFF"))
        .onAppear {
            Task { @MainActor in
                vm.setMothView()
                vm.setWeekView()
                await vm.setFollow()
            }
        }
    }
}

// MARK: - Sections
private extension WalkIngRecordView {
    var header: some View {
        HStack(spacing: 12) {
            Image("HomeLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 61)
            Spacer()
            
            Button {
                vm.goNext(.notificationView)
            } label: {
                Image(systemName: "bell")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(hex: "#191919"))
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
        .background(Color(hex: "#FFFFFF"))
    }
    
    var profileRow: some View {
        VStack(spacing: 0) {
            HStack {
                Text("친구 목록").font(.system(size: 12))
                Spacer()
            }
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if let uiImage = UserManager.shared.profileImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                .overlay {
                                    if(vm.selectedProfile == 0) {
                                        Circle().stroke(Color(hex: "#52CE4B"), lineWidth: 1)
                                    }
                                }
                                .padding(1)
                                .onTapGesture {
                                    Task { @MainActor in
                                        vm.selectedProfile = 0
                                        vm.followerWalk = nil
                                    }
                                }
                            Divider()
                        } else {
                            Image("DefaultImage")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                .overlay {
                                    if(vm.selectedProfile == 0) {
                                        Circle().stroke(Color(hex: "#52CE4B"), lineWidth: 1)
                                    }
                                }
                                .padding(1)
                                .onTapGesture {
                                    Task { @MainActor in
                                        vm.selectedProfile = 0
                                        vm.followerWalk = nil
                                    }
                                }
                        }
                        
                        ForEach(
                            Array(vm.follows.enumerated()),
                            id: \.offset
                        ) { item in
                            let idx = item.offset
                            let follow = item.element
                            
                            KFImage(URL(string: follow.imageName))
                                .retry(maxCount: 3)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                .overlay {
                                    if(vm.selectedProfile == idx + 1) {
                                        Circle().stroke(Color(hex: "#52CE4B"), lineWidth: 1)
                                    }
                                }
                                .padding(1)
                                .onTapGesture {
                                    Task { @MainActor in
                                        let result = await vm.getFollowWalk(nickname: vm.follows[idx].nickname)
                                        if (result) { vm.selectedProfile = idx + 1 }
                                    }
                                }
                        }
                    }
                }
                
                Button {
                    vm.goNext(.followListView)
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(hex: "#191919"))
                        .background { Color(hex: "#FFFFFF") }

                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Color(hex: "#FFFFFF")
        )
    }
    
    var segmented: some View {
        HStack(spacing: 8) {
            ForEach(WalkingRecordViewModel.Period.allCases, id: \.self) { p in
                Button {
                    vm.period = p
                } label: {
                    Text(p.rawValue)
                        .font(.headline)
                        .foregroundStyle(vm.period == p ? .white : .primary.opacity(0.7))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(vm.period == p ? Color(.systemTeal) : Color(hex: "#FFFFFF"))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    WalkIngRecordView(vm: WalkingRecordViewModel())
}
