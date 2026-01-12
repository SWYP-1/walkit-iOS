//
//  Untitled.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//

import SwiftUI

struct CreateCharacterView: View {
    @ObservedObject var vm: SignUpViewModel
    @FocusState private var isTextFieldFocused: Bool

    init(vm: SignUpViewModel) { self.vm = vm }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    vm.goHome()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color(hex: "#191919"))
                }
            }
            .padding(.bottom, 40)
            
            
            Text("준비 단계")
                .foregroundStyle(Color(hex: "#FFFFFF"))
                .padding(.vertical, 4)
                .modifier(CapsuleBackground(backgroundColor: Color(hex: "#191919")))
            
            Text("캐릭터의 닉네임을 만들어주세요")
                .font(.title)
            
            Spacer()
            
            Image("NickNameCharacter")
                .resizable()
                .scaledToFit()
                .frame(width: 204)
            
            Spacer()
            
            TextField("입력해주세요", text: $vm.nickname)
                .focused($isTextFieldFocused)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color(hex: "#191919"))
                .padding()
                .overlay {
                    Text("\(vm.nickname.count)/20자")
                        .foregroundStyle(Color(hex: "#818185"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 20)
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#FFFFFF"))
                        .overlay {
                            if(vm.isDuplicate) {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "#E65C4A"), lineWidth: 1)
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isTextFieldFocused ? Color(hex: "#818185") : Color(hex: "#191919"), lineWidth: 1)
                            }
                        }
                }
                .onChange(of: vm.nickname) { oldValue, newValue in
                    if(newValue.count > 20) { vm.nickname = oldValue }
                    if(!vm.isValidText(vm.nickname)) {
                        vm.isDuplicateString = "*한글 또는 영어만 가능합니다\n숫자 또는 특수문자는 불가능합니다"
                        vm.isDuplicate = true
                    } else {
                        vm.isDuplicate = false
                    }
                }
            
            if(vm.isDuplicate) {
                HStack {
                    Text(vm.isDuplicateString)
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "#E65C4A"))
                    Spacer()
                }
            }
            
            Spacer()
            
            FilledActionButton(title: "다음으로", isEnable: .constant(true), isRightChevron: true) {
                Task {
                    if(vm.isValidText(vm.nickname)) {
                        vm.isShowingProgress = true
                        await vm.postUsersNickname()
                        vm.isShowingProgress = false
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
        .background(Color(hex: "#F9F9FA"))
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { isTextFieldFocused = true }
        .onTapGesture { isTextFieldFocused = false }
    }
}


#Preview {
    CreateCharacterView(vm: SignUpViewModel())
}

