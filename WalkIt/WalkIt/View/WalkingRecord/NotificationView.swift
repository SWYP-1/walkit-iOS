//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import Kingfisher

struct NotificationView: View {
    @StateObject var vm: NotificationViewModel
    @FocusState private var isTextFieldFocused: Bool
    @Binding var path: NavigationPath
    init(vm: NotificationViewModel, path: Binding<NavigationPath>) {
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
                Text("알림")
                    .font(.system(size: 20)).bold()
                Spacer()
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color(hex: "#FFFFFF"))
                    .padding(.trailing, 10)
                
            }
            .padding(20)
            ScrollView {
                ForEach(vm.notificationItems, id: \.self) { item in
                    NotificationItemView(vm: vm, notificationItem: item)
                        .padding(20)
                    Divider()
                        .foregroundStyle(Color(hex: "#EBEBEE"))
                }
            }
        }
        .onAppear {
            vm.loadView()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    NotificationView(vm: NotificationViewModel(), path: .constant(NavigationPath()))
}

struct NotificationItemView: View {
    let vm: NotificationViewModel
    let notificationItem: NotificationItem
    var body: some View {
        HStack(alignment: .center) {
            Image(notificationItem.type)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading) {
                Text(notificationItem.body)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.black)
                Text(getTime(time: notificationItem.createdAt))
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
            }
            
            Spacer()
            
            if( notificationItem.type == "FOLLOW" ) {
                HStack {
                    Button {
                        Task { @MainActor in
                            await vm.patchFollow(nserNickname: notificationItem.senderNickname ?? "")
                            await vm.getNotificationList()
                        }
                    } label: {
                        Text("확인")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: "#FFFFFF"))
                            .padding(6)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#52CE4B"))
                            )
                    }
                    
                    Button {
                        Task { @MainActor in
                            await vm.deleteNotificationList(notiId: notificationItem.notificationId)
                            await vm.getNotificationList()
                        }
                    } label: {
                        Text("삭제")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: "#818185"))
                            .padding(6)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray4))
                            )
                    }
                }
            }
        }
    }
    
    func getTime(time: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"  // 마이크로초 6자리
        
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "yyyy년 MM월 dd일"
            return formatter.string(from: date)
        }
        return ""
    }
}
