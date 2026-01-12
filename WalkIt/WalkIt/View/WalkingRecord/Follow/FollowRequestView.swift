//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import Kingfisher

struct FollowRequestView: View {
    @StateObject var vm: FollowRequestViewModel
    @FocusState private var isTextFieldFocused: Bool
    @Binding var path: NavigationPath
    init(vm: FollowRequestViewModel, path: Binding<NavigationPath>) {
        _vm = StateObject(wrappedValue: vm)
        self._path = path
    }
    
    var body: some View {
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
                
                Text("친구 추가")
                    .font(.system(size: 20)).bold()
                
                Spacer()
                
                Image(systemName: "plus")
                    .foregroundStyle(Color(hex: "#FFFFFF"))
                
                
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

                .overlay(alignment: .trailing) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color(hex: "#D7D9E0"))
                        .padding(.trailing, 40)
                }
                .onChange(of: vm.followNickname) { oldValue, newValue in
                    Task { @MainActor in
                        if(vm.isValidText(newValue)) {
                            await vm.searchUsers(nickname: vm.followNickname)
                        }
                    }
                    
                }
            
            HStack {
                Text("\(vm.searchUsers.filter{ ($0.followStatus != .ACCEPTED) && ($0.followStatus != .MYSELF) }.count)")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "#2ABB42"))
                Text("명").font(.system(size: 14))
                    .foregroundStyle(Color(hex: "#818185"))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 0)
            
            
            if(vm.searchUsers.isEmpty) {
                VStack(spacing: 10) {
                    Spacer()
                    Image("NotSearch")
                    Text("검색 결과가 없어요")
                        .font(.system(size: 20)).bold()
                        .foregroundStyle(Color(hex: "#191919"))
                    Text("다른 검색어를 입력하세요")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#818185"))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#F5F5F5"))
                )
                .padding(20)
                .padding(.top, -10)

            } else {
                ScrollView {
                    let followUsers = vm.searchUsers.filter {
                        $0.followStatus == .EMPTY || $0.followStatus == .REJECTED
                    }
                    ForEach(followUsers, id: \.self) { users in
                        FriendCard(users: users) {
                            Task { @MainActor in
                                await vm.postFollowing(nickname: users.nickName)
                            }
                        }
                        Divider()
                    }
                    
                    let pendingUsers = vm.searchUsers.filter { $0.followStatus == .PENDING }
                    ForEach(pendingUsers, id: \.self) { users in
                        FriendCard(users: users) {}
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        
    }
}
struct FriendCard: View {
    let users: SearchUsers
    let action: () -> Void
    var body: some View {
        HStack {
            KFImage(URL(string: users.imageName))
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 26)
                .clipShape(Circle())
            
            Text(users.nickName)
                .font(.system(size: 15))
            
            Spacer()
            
            if(users.followStatus == .ACCEPTED) {
                Button(action: action, label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color(hex: "#818185"))
                })
            } else if(users.followStatus == .PENDING) {
                Button(action: action, label: {
                    Text("요청중")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#FFFFFF"))
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "#818185"))
                        )
                })
                .disabled(true)
            } else if(users.followStatus != .MYSELF) {
                Button(action: action, label: {
                    Text("팔로우")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#FFFFFF"))
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "#52CE4B"))
                        )
                })
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(hex: "#FFFFFF"))
    }
}

#Preview {
    FollowRequestView(vm: FollowRequestViewModel(), path: .constant(NavigationPath()))
}
