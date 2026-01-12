//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import Kingfisher

struct FollowListView: View {
    @StateObject var vm: FollowListViewModel
    @FocusState private var isTextFieldFocused: Bool
    @Binding var path: NavigationPath
    init(vm: FollowListViewModel, path: Binding<NavigationPath>) {
        _vm = StateObject(wrappedValue: vm)
        self._path = path
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        if(!path.isEmpty) {
                            path.removeLast()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color(hex: "#191919"))
                            .padding(.trailing, 10)
                    }
                    
                    Spacer()
                    
                    Text("친구 목록")
                        .font(.system(size: 20)).bold()
                    
                    Spacer()
                    
                    Button {
                        path.append(WalkingRecordRoute.followRequestView)
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color(hex: "#191919"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, 10)
                
                Divider()
                
                TextField("친구의 닉네임을 검색해보세요", text: $vm.followNickname)
                    .focused($isTextFieldFocused)
                    .foregroundStyle(Color(hex: "#D7D9E0"))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#F5F5F5"))
                    )
                    .padding(20)
                    .padding(.bottom, -10)
                
                    .overlay(alignment: .trailing) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color(hex: "#D7D9E0"))
                            .padding(.trailing, 40)
                    }

                HStack {
                    Text("\(vm.follows.count)")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#2ABB42"))
                    Text("명").font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#818185"))
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                if(vm.follows.filter{ $0.nickname.contains(vm.followNickname) }.isEmpty && !vm.followNickname.isEmpty) {
                        VStack(spacing: 10) {
                            Image("NotSearch")
                            Text("검색 결과가 없어요")
                                .font(.system(size: 20)).bold()
                                .foregroundStyle(Color(hex: "#191919"))
                            Text("다른 검색어를 입력하세요")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(hex: "#818185"))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#F5F5F5"))
                        )
                        .padding(20)

                    } else {
                        ScrollView {
                            let followUsers = vm.follows.filter{ $0.nickname.contains(vm.followNickname) || vm.followNickname.isEmpty }
                            ForEach(followUsers, id: \.self) { users in
                                FollowCard(users: users) {
                                    Task { @MainActor in
                                        vm.selectedNickname = users.nickname
                                    }
                                }
                                .background(vm.selectedNickname == users.nickname ? Color(hex: "#EBEBEE") : Color(hex: "#FFFF"))
                                .overlay(alignment: .trailing) {
                                    if(vm.selectedNickname == users.nickname) {
                                        Button {
                                            vm.isShowDeleteAlert = true
                                        } label: {
                                            HStack {
                                                Image(systemName: "xmark")
                                                    .foregroundStyle(vm.isShowDeleteAlert ? Color(hex: "#2ABB42") : Color(hex: "#191919"))
                                                Text("차단하기")
                                                    .foregroundStyle(vm.isShowDeleteAlert ? Color(hex: "#2ABB42") : Color(hex: "#191919"))
                                            }
                                            .padding(.horizontal, 5)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(vm.isShowDeleteAlert ? Color(hex: "#52CE4B") : Color(hex: "#FFFFFF"))
                                                    .shadow(radius: 1)
                                            )
                                            .padding(.trailing, 40)
                                        }
                                        
                                    }
                                }
                                Divider()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
            }
            if(vm.isShowDeleteAlert) {
                Color(hex: "#000000").opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        vm.isShowDeleteAlert = false
                    }
                VStack {
                    Text("친구 차단하기")
                    Text("\(vm.selectedNickname)을(를) 정말 차단하시겠습니까?")
                    HStack {
                        Button {
                            vm.isShowDeleteAlert = false
                        } label: {
                            Text("아니요")
                                .foregroundStyle(Color(hex: "#191919"))
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "#FFFFFF"))
                                        .stroke(Color(hex: "#191919"), lineWidth: 1)
                                )
                        }
                        
                        Button {
                            Task {
                                await vm.deleteFollows(nickname: vm.selectedNickname)
                            }
                        } label: {
                            Text("예")
                                .foregroundStyle(Color(hex: "#FFFFFF"))
                                .padding(20)
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
        .onAppear {
            vm.loadView()
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)

    }
}

struct FollowCard: View {
    let users: Follow
    let action: () -> Void
    var body: some View {
        HStack {
            KFImage(URL(string: users.imageName))
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 26)
                .clipShape(Circle())
            
            Text(users.nickname)
                .font(.system(size: 15))
            
            Spacer()
            
            Button(action: action, label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(Color(hex: "#818185"))
            })
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(hex: "#FFFFFF"))
    }
}


#Preview {
    FollowListView(vm: FollowListViewModel(), path: .constant(NavigationPath()))
}
