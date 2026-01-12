//
//  Untitled.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//

import SwiftUI

struct BirthYearView: View {
    @ObservedObject var vm: SignUpViewModel
    @FocusState private var yearTextFieldFocused: Bool
    @FocusState private var monthTextFieldFocused: Bool
    @FocusState private var dayTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(vm: SignUpViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    vm.goNext(.GoalSettingView)
                } label: {
                    Text("건너뛰기")
                        .underline()
                        .foregroundStyle(Color(hex: "#818185"))
                        .padding()
                }
            }
            .padding(.bottom, 40)
            
            Text("연령 확인")
                .padding(.vertical, 5)
                .foregroundStyle(.white)
                .modifier(CapsuleBackground(backgroundColor: Color(hex: "#191919")))
            
            Text("\(vm.nickname)님,\n생년월일을 입력해주세요")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding(.bottom, 20)
            
            HStack {
                Text("생년월일")
                Text("*")
                    .foregroundColor(Color(hex: "#FF0000"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("생년월일 8자리를 입력해주세요")
                .foregroundColor(Color(hex: "#818185"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                TextField("YYYY", text: $vm.year)
                    .keyboardType(.numberPad)
                    .focused($yearTextFieldFocused)
                    .padding()
                    .background { Color(hex: "#FFFFFF")}
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        if(!vm.isInvalidBirthDateText) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#FF3B21"))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(yearTextFieldFocused ? Color(hex: "#191919") : Color(hex: "#EBEBEE"), lineWidth: 1)
                        }
                    }
                    .onChange(of: vm.year) { oldValue, newValue in
                        if(newValue.count > 4) { vm.year = oldValue }
                        vm.setBirthDateEnable()
                    }

                
                TextField("MM", text: $vm.month)
                    .keyboardType(.numberPad)
                    .focused($monthTextFieldFocused)
                    .padding()
                    .background { Color(hex: "#FFFFFF")}
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        if(!vm.isInvalidBirthDateText) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#FF3B21"))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(monthTextFieldFocused ? Color(hex: "#191919") : Color(hex: "#EBEBEE"), lineWidth: 1)
                        }
                    }
                    .onChange(of: vm.month) { oldValue, newValue in
                        if(newValue.count > 2) { vm.month = oldValue }
                        vm.setBirthDateEnable()
                    }
                    
                
                TextField("DD", text: $vm.day)
                    .keyboardType(.numberPad)
                    .focused($dayTextFieldFocused)
                    .padding()
                    .background { Color(hex: "#FFFFFF")}
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        if(!vm.isInvalidBirthDateText) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#FF3B21"))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(dayTextFieldFocused ? Color(hex: "#191919") : Color(hex: "#EBEBEE"), lineWidth: 1)
                        }
                    }
                    .onChange(of: vm.day) { oldValue, newValue in
                        if(newValue.count > 2) { vm.day = oldValue }
                        vm.setBirthDateEnable()
                    }
            }
            if(!vm.isInvalidBirthDateText) {
                HStack {
                    Text("올바른 날짜를 입력해주세요")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "#E65C4A"))
                    Spacer()
                }
            }
            
            Spacer()
            
            HStack {
                OutlineActionButton(title: "이전으로") { dismiss() }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.3)
                
                FilledActionButton(title: "다음으로", isEnable: $vm.birthDateEnable, isRightChevron: true) {
                    Task {
                        if(vm.isVaildBirthDate()) {
                            vm.isInvalidBirthDateText = true
                            let result = vm.checkBirthDate()
                            if(result) { await vm.postUsersBirthDate() }
                        } else {
                            vm.isInvalidBirthDateText = false
                        }
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
        .onTapGesture {
            yearTextFieldFocused = false
            monthTextFieldFocused = false
            dayTextFieldFocused = false
        }
    }
}


#Preview {
    BirthYearView(vm: SignUpViewModel())
}
