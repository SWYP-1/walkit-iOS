//
//  MyPageView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import PhotosUI

struct EditUserInfoView: View {
    @StateObject var vm: EditUserInfoViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    @Binding var path: NavigationPath
    init(vm: EditUserInfoViewModel, path: Binding<NavigationPath>) {
        _vm = StateObject(wrappedValue: EditUserInfoViewModel())
        self._path = path
    }
    
    private let years = Array(1900...Calendar.current.component(.year, from: .now)).reversed()
    private let months = Array(1...12)
    private var daysInSelectedMonth: [Int] {
        var comps = DateComponents()
        comps.year = vm.birthYear
        comps.month = vm.birthMonth
        let cal = Calendar.current
        let date = cal.date(from: comps) ?? .now
        let range = cal.range(of: .day, in: .month, for: date) ?? (1..<31)
        return Array(range)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        if(vm.isChangedData()) {
                            vm.showSaveAlert = true
                        } else {
                            path = NavigationPath()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.black)
                            .padding(.trailing, 10)
                    }
                    Spacer()
                    Text("내 정보 관리")
                        .font(.headline)
                    Spacer()
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Avatar + Upload
                        HStack(alignment: .center, spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 84, height: 84)
                                if let img = vm.selectedImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 84, height: 84)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundStyle(Color.white.opacity(0.9))
                                }
                            }
                            
                            Button {
                                vm.showUploadSheet.toggle()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                    Text("이미지 업로드")
                                }
                                .font(.headline)
                                .foregroundStyle(Color(.systemGreen))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Color(.systemGreen), lineWidth: 1)
                                )
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                        // Birthday
//                        VStack(alignment: .leading, spacing: 8) {
//                            requiredLabel("생년월일")
//                            HStack(spacing: 12) {
//                                // Year
//                                Menu {
//                                    Picker("", selection: $vm.birthYear) {
//                                        ForEach(years, id: \.self) { y in
//                                            Text("\(y)").tag(y)
//                                        }
//                                    }
//                                } label: {
//                                    dropdownField("\(vm.birthYear)")
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
//                                                .stroke(vm.birthDateEnable ? Color(hex: "#EBEBEE") : Color(hex: "#FF3B21"), lineWidth: 1)
//                                        )
//                                }
//                                .onChange(of: vm.birthYear) { vm.birthDateEnable = vm.isVaildBirthDate() }
//                                
//                                // Month
//                                Menu {
//                                    Picker("", selection: $vm.birthMonth) {
//                                        ForEach(months, id: \.self) { m in
//                                            Text("\(m)").tag(m)
//                                        }
//                                    }
//                                } label: {
//                                    dropdownField("\(vm.birthMonth)")
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
//                                                .stroke(vm.birthDateEnable ? Color(hex: "#EBEBEE") : Color(hex: "#FF3B21"), lineWidth: 1)
//                                        )
//                                }
//                                .onChange(of: vm.birthMonth) { vm.birthDateEnable = vm.isVaildBirthDate() }
//                                
//                                // Day
//                                Menu {
//                                    Picker("", selection: $vm.birthDay) {
//                                        ForEach(daysInSelectedMonth, id: \.self) { d in
//                                            Text("\(d)").tag(d)
//                                        }
//                                    }
//                                } label: {
//                                    dropdownField("\(vm.birthDay)")
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
//                                                .stroke(vm.birthDateEnable ? Color(hex: "#EBEBEE") : Color(hex: "#FF3B21"), lineWidth: 1)
//                                        )
//                                }
//                                .onChange(of: vm.birthDay) { vm.birthDateEnable = vm.isVaildBirthDate() }
//                            }
//                        }
                        
//                        if(!vm.birthDateEnable) {
//                            HStack {
//                                Text("올바른 날짜를 선택해주세요")
//                                    .font(.subheadline)
//                                    .foregroundStyle(Color(hex: "#E65C4A"))
//                                Spacer()
//                            }
//                        }
                        
                        // Nickname
                        VStack(alignment: .leading, spacing: 8) {
                            requiredLabel("닉네임")
                            TextField("입력해주세요", text: $vm.nickname)
                                .padding(14)
                                .focused($isTextFieldFocused)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(Color(hex: "#EBEBEE"), lineWidth: 1)
                                )
                                .overlay {
                                    Text("\(vm.nickname.count)/20자")
                                        .foregroundStyle(Color(hex: "#818185"))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding(.horizontal, 20)
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
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("이메일")
                                .font(.subheadline)
                            Text(vm.email)
                                .foregroundStyle(Color(hex: "#C2C3CA"))
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(hex: "#F5F5F5"))
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("연동된 계정")
                                .font(.subheadline)
                            Text(vm.authType)
                                .foregroundStyle(Color(hex: "#C2C3CA"))
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(hex: "#F5F5F5"))
                                )
                        }
                        
                        HStack(spacing: 12) {
                            Button {
                                if(vm.isChangedData()) {
                                    vm.showSaveAlert = true
                                } else {
                                    path = NavigationPath()
                                }
                            } label: {
                                Text("뒤로가기")
                                    .font(.headline)
                                    .foregroundStyle(Color(.systemGreen))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(Color(.systemGreen), lineWidth: 2)
                                    )
                            }
                            
                            Button {
                                Task {
                                    vm.isSavingProgress = true
                                    await vm.saveUserInfo()
                                    vm.isSavingProgress = false
                                }
                            } label: {
                                Text("저장하기")
                                    .font(.headline)
                                    .foregroundStyle((!vm.isDuplicate && vm.birthDateEnable && !vm.nickname.isEmpty && vm.saveNickname != vm.nickname) ? Color(hex: "#FFFFFF") : Color(hex: "#818185"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill((!vm.isDuplicate && vm.birthDateEnable && !vm.nickname.isEmpty && vm.saveNickname != vm.nickname) ? Color(hex: "#52CE4B") : Color(hex: "#EBEBEE"))
                                    )
                            }
                            .disabled(!(!vm.isDuplicate && vm.birthDateEnable && !vm.nickname.isEmpty && vm.saveNickname != vm.nickname))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .overlay(alignment: .topTrailing) {
                        if(vm.showUploadSheet) {
                            VStack(spacing: 0) {
                                Button {
                                    vm.showCamera = true
                                    vm.showUploadSheet = false
                                } label: {
                                    HStack {
                                        Image(systemName: "camera")
                                            .foregroundStyle(Color(hex: "#191919"))
                                        Text("사진 촬영하기")
                                            .foregroundStyle(Color(hex: "#191919"))
                                    }
                                    .padding(10)
                                    .padding(.trailing, 40)
                                    .frame(width: 200, alignment: .leading)
                                    .background(Color(hex: "#FFFFFF"))
                                }
                                
                                Button {
                                    vm.showPhotoPicker = true
                                    vm.showUploadSheet = false
                                } label: {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle")
                                            .foregroundStyle(Color(hex: "#191919"))
                                        Text("갤러리에서 선택")
                                            .foregroundStyle(Color(hex: "#191919"))
                                    }
                                    .padding(10)
                                    .padding(.trailing, 40)
                                    .frame(width: 200, alignment: .leading)
                                    .background(Color(hex: "#FFFFFF"))
                                }
                                
                                Button {
                                    vm.selectedImage = nil
                                    vm.showUploadSheet = false
                                } label: {
                                    HStack {
                                        Image(systemName: "minus")
                                            .foregroundStyle(Color(hex: "#52CE4B"))
                                        Text("이미지 삭제")
                                            .foregroundStyle(Color(hex: "#52CE4B"))
                                    }
                                    .padding(10)
                                    .padding(.trailing, 40)
                                    .frame(width: 200, alignment: .leading)
                                    .background(Color(hex: "#F3FFF8"))
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "#EBEBEE"), lineWidth: 1)
                                    .shadow(color: .black.opacity(0.15), radius: 4, x: 1, y: 1)
                            }
                            .offset(x: -100, y: 90)
                        }
                    }
                }
            }
            
            if(vm.isSavingProgress) {
                Color(hex: "#000000").opacity(0.5).ignoresSafeArea()
                ProgressView()
            }
            
            if(vm.showSaveAlert) {
                Color(hex: "#000000").opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        vm.showSaveAlert = false
                    }
                VStack(spacing: 10) {
                    Text("변경된 사항이 있습니다")
                        .font(.title2).bold()
                    Text("저장하시겠습니까?")
                        .foregroundStyle(Color(hex: "#818185"))
                    HStack {
                        Button {
                            path = NavigationPath()
                        } label: {
                            Text("아니요")
                                .font(.title3)
                                .foregroundStyle(Color(hex: "#52CE4B"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "#52CE4B"), lineWidth: 1)
                                )
                        }
                        
                        Button {
                            Task {
                                vm.isSavingProgress = true
                                await vm.saveUserInfo()
                                vm.isSavingProgress = false
                                path = NavigationPath()
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
                                        .fill(Color(hex: "#52CE4B"))
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
        .background(Color(hex: "#FFFFFF"))
        .navigationTitle("")
        .navigationBarHidden(true)
        .onTapGesture { isTextFieldFocused = false }
        .photosPicker(isPresented: $vm.showPhotoPicker, selection: $vm.selectedItem)
        .onChange(of: vm.selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run { vm.selectedImage = image }
                }
            }
        }
        .sheet(isPresented: $vm.showCamera) {
            CameraPicker(image: $vm.selectedImage)
        }
        .onAppear {
            Task { @MainActor in
                await vm.loadView()
            }
        }
    }
}

// MARK: - Small UI helpers
private extension EditUserInfoView {
    @ViewBuilder
    func requiredLabel(_ text: String) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
            Text("*")
                .foregroundStyle(Color(.systemRed))
        }
    }
    
    @ViewBuilder
    func dropdownField(_ text: String) -> some View {
        HStack {
            Text(text)
                .foregroundStyle(.black)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundStyle(.black)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EditUserInfoView(vm: EditUserInfoViewModel(), path: .constant(NavigationPath()))
}
