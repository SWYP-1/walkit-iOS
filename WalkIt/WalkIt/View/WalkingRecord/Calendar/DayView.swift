//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import CoreLocation
import Kingfisher

struct DayView: View {
    @ObservedObject var vm: WalkingRecordViewModel
    @FocusState private var isTextFieldFocused: Bool
    init(vm: WalkingRecordViewModel) { self.vm = vm }

    private var title: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy년 M월 d일"
        return fmt.string(from: vm.currentDay)
    }
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack(spacing: 10) {
                        HStack {
                            Button {
                                if(vm.isChangedData()) {
                                    vm.isDismissAlert = true
                                    vm.showSaveAlert = true
                                } else {
                                    vm.dismiss()
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(Color(hex: "#191919"))
                                    .padding(.trailing, 10)
                            }
                            Spacer()
                            Text("일일 산책 기록")
                            Spacer()
                            Color.clear.frame(width: 24, height: 24)
                        }
                        .padding(.vertical, 10)
                        .background(Color(hex: "#FFFFFF"))
                        
                        VStack(spacing: 0) {
                            HStack {
                                ScrollView(.horizontal) {
                                    HStack(spacing: -5) {
                                        ForEach(0..<vm.dayWalks.count, id: \.self) { idx in
                                            Button(vm.koreanOrdinalWord(index: idx)) {
                                                if(vm.isChangedData()) {
                                                    vm.isDismissAlert = false
                                                    vm.showSaveAlert = true
                                                } else {
                                                    vm.selectedIndex = idx
                                                    vm.dayWalk = vm.dayWalks[idx]
                                                    vm.note = vm.dayWalk.note ?? ""
                                                    vm.savedNote = vm.note
                                                    vm.isTextEditor = false
                                                }
                                            }
                                            .foregroundStyle(vm.selectedIndex == idx ? Color(hex: "#818185") : Color(hex: "#C2C3CA") )
                                            .padding(10)
                                            .background(FolderTabShape().fill(vm.selectedIndex == idx ? Color(hex: "#FFFFFF") : Color(hex: "#555555") ) )
                                            .zIndex(vm.selectedIndex == idx ? 1 : 0)
                                        }
                                    }
                                }
                                .scrollIndicators(.hidden)
                            }
                            
                            VStack {
                                HStack {
                                    Text(title)
                                        .font(.title3).bold()
                                    Spacer()
                                    Button {
                                        vm.isShowSavingView = true
                                    } label : {
                                        Image("SHARE")
                                    }
                                }
                                
                                if(vm.dayWalks.count > 0) {
                                    ZStack(alignment: .bottomTrailing) {
                                        DayDiaryCard(walk: vm.dayWalk)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        Text(vm.unixMsToHourMinute(walk: vm.dayWalk))
                                            .foregroundStyle( Color(hex: "#FFFFFF") )
                                            .font(.subheadline).bold()
                                            .padding()
                                    }
                                }
                            }
                            .padding()
                            .background(Color(hex: "#FFFFFF"))
                            .clipShape(RoundedCorners())
                            
                            WalkItCountView(leftTitle: "걸음 수", rightTitle: "산책 시간", avgSteps: $vm.dayWalk.stepCount, walkTime: $vm.dayWalk.totalTime)
                                .padding(.vertical, 10)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                VStack {
                                    HStack {
                                        Text("감정 기록")
                                        Spacer()
                                        
                                        Button {
                                            vm.showingEditMenu.toggle()
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .foregroundStyle(.black)
                                                .padding(8)
                                        }
                                    }
                                    .font(.headline)
                                    HStack(spacing: 8) {
                                        Image("\(vm.dayWalk.preWalkEmotion ?? "")Circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                        Image("\(vm.dayWalk.postWalkEmotion ?? "")Circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                        Spacer()
                                    }
                                }
                                
                                if(!vm.note.isEmpty || vm.isTextEditor) {
                                    Divider()
                                    VStack(alignment: .leading) {
                                        TextEditor(text: $vm.note)
                                            .focused($isTextFieldFocused)
                                            .padding(.horizontal, 10)
                                            .background{ Color(hex: "#F3F3F5") }
                                            .frame(height: 150)
                                            .scrollContentBackground(.hidden)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .disabled(!vm.isTextEditor)
                                    }
                                }
                                
                                HStack {
                                    OutlineActionButton(title: "이전으로") {
                                        if(vm.isChangedData()) {
                                            vm.isDismissAlert = true
                                            vm.showSaveAlert = true
                                        } else {
                                            vm.dismiss()
                                        }
                                    }
                                    
                                    Button {
                                        Task {
                                            await vm.fetchWalk()
                                        }
                                    } label: {
                                        HStack {
                                            Text("저장하기")
                                                .font(.title3)
                                                .foregroundStyle(Color(hex: "#FFFFFF"))
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(Color(hex: "#FFFFFF"))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical)
                                        .background { Color(hex: "#52CE4B") }
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(hex: "##FFFFFF"))
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                            )
                            .overlay(alignment: .topTrailing) {
                                if(vm.showingEditMenu) {
                                    VStack(spacing: 5) {
                                        Button {
                                            vm.editNote()
                                        } label: {
                                            HStack {
                                                Image(systemName: "pencil")
                                                    .foregroundStyle(Color(hex: "#52CE4B"))
                                                Text("수정하기")
                                                    .foregroundStyle(Color(hex: "#52CE4B"))
                                            }
                                            .padding(10)
                                            .padding(.trailing, 40)
                                            .background(Color(hex: "#F3FFF8"))
                                        }
                                        
                                        Button {
                                            vm.deleteNote()
                                        } label: {
                                            HStack {
                                                Image(systemName: "trash")
                                                    .foregroundStyle(Color(hex: "#191919"))
                                                Text("삭제하기")
                                                    .foregroundStyle(Color(hex: "#191919"))
                                            }
                                            
                                        }
                                        .padding(10)
                                        .padding(.trailing, 40)
                                    }
                                    .background{Color(hex: "#FFFFFF")}
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(hex: "#EBEBEE"), lineWidth: 1)
                                            .shadow(color: .black.opacity(0.15), radius: 4, x: 1, y: 1)
                                    }
                                    .offset(y: 45)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .background(Color(hex: "#F5F5F5"))
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
                            if(vm.isDismissAlert) {
                                vm.showSaveAlert = false
                                vm.dismiss()
                            } else {
                                vm.showSaveAlert = false
                            }
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
                                if(vm.isDismissAlert) {
                                    _ = await vm.fetchWalk()
                                    vm.showSaveAlert = false
                                    vm.dismiss()
                                } else {
                                    _ = await vm.fetchWalk()
                                    vm.showSaveAlert = false
                                }
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
            if(vm.isShowSavingView) {
                DaySavingView(walk: vm.dayWalk, vm: vm)
            }
            
        }
        .padding(.vertical, 12)
        .background(Color(hex: "#FFFFFF"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbar(.hidden)
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

// MARK: - Sections
private struct DayDiaryCard: View {
    let walk: WalkRecordEntity
    
    var body: some View {
        VStack(spacing: 16) {
            if let imageURL = walk.imageUrl {
                KFImage(URL(string: imageURL))
                    .placeholder { ProgressView() }
                    .retry(maxCount: 3)
                    .resizable()
                    .scaledToFill()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#FFFFFF"))
        )
    }
}

private struct DaySavingView: View {
    let walk: WalkRecordEntity
    let vm: WalkingRecordViewModel
    @State private var isSavingProgress = false
    @State private var saveSuccess: Bool? = nil
    @State private var loadedImage: UIImage? = nil

    var walkHours: String { String(walk.totalTime / 3_600_000) }
    var walkMinute: String { String((walk.totalTime % 3_600_000) / 60_000) }
    let width = UIScreen.main.bounds.width - 60
    
    var body: some View {
        ZStack {
            Color(hex: "#000000").opacity(0.6).ignoresSafeArea()
                .onTapGesture {
                    vm.isShowSavingView = false
                }
            VStack(spacing: 10) {
                Text("기록 공유하기")
                    .font(.title2).bold()
                    .foregroundStyle(Color(hex: "#191919"))
                Text("오늘의 산책 기록을 공유하시겟습니까?")
                    .font(.body)
                    .foregroundStyle(Color(hex: "#818185"))
                
                let savingView = ZStack {
                    if let image = loadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: width, height: width)
                    } else {
                        if let urlString = walk.imageUrl, let url = URL(string: urlString) {
                            KFImage(url)
                                .retry(maxCount: 3)
                                .onSuccess { result in
                                    loadedImage = result.image
                                }
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .frame(width: width, height: width)
                        }
                    }
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#000000").opacity(0.3))
                        .frame(width: width, height: width)
                    
                    
                    VStack {
                        HStack(spacing: 2) {
                            Image("WAL")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                            Image("KIT")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            Image("\(walk.preWalkEmotion ?? "")Circle")
                            Image("\(walk.postWalkEmotion ?? "")Circle")
                            Spacer()
                            VStack {
                                HStack {
                                    Spacer()
                                    (
                                        Text(String(walk.stepCount))
                                            .font(.system(size: 24))
                                        + Text("걸음")
                                            .font(.callout)
                                    )
                                    .foregroundStyle(Color(hex: "#FFFFFF"))
                                }
                                HStack {
                                    Spacer()
                                    if(walkHours != "0") {
                                        (
                                            Text(walkHours)
                                                .font(.system(size: 24))
                                            + Text("시간 ")
                                                .font(.callout)
                                            + Text(walkMinute)
                                                .font(.system(size: 24))
                                            + Text("분")
                                                .font(.callout)
                                        )
                                        .foregroundStyle(Color(hex: "#FFFFFF"))
                                    } else {
                                        (
                                            Text(walkMinute)
                                                .font(.system(size: 24))
                                            + Text("분")
                                                .font(.callout)
                                        )
                                        .foregroundStyle(Color(hex: "#FFFFFF"))
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: width)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(10)
                    
                    
                    
                }
                savingView
                    .padding(10)
                
                if let saveSuccess = saveSuccess {
                    HStack {
                        Image(systemName: saveSuccess ? "checkmark" : "xmark")
                            .foregroundStyle(saveSuccess ? Color(hex: "#FFFFFF") : Color(hex: "#FF3B21"))
                        Text(saveSuccess ? "이미지 저장이 완료 되었습니다." : "이미지 저장이 실패했습니다")
                            .foregroundStyle(saveSuccess ? Color(hex: "#FFFFFF") : Color(hex: "#FF3B21"))
                        Spacer()
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(saveSuccess ? Color(hex: "#555555") : Color(hex: "#FFF0EE"))
                            .stroke(saveSuccess ? Color(hex: "#555555") : Color(hex: "#FFD0C9"), lineWidth: 1)
                    )
                }
                
                HStack {
                    OutlineActionButton(title: "뒤로가기") {
                        vm.isShowSavingView = false
                    }
                    
                    FilledActionButton(title: "저장하기", isEnable: .constant(true), isRightChevron: false) {
                        isSavingProgress = true
                        vm.requestPhotoPermission { granted in
                            if granted {
                                Task { @MainActor in
                                    if let image = savingView.snapshot() {
                                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                        saveSuccess = true
                                    }
                                }
                            } else {
                                saveSuccess = false
                                vm.openAppSettings()
                            }
                            isSavingProgress = false
                        }
                        
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#FFFFFF"))
            )
            .padding(.horizontal, 10)
            
            if(isSavingProgress) {
                Color(hex: "#0000000").opacity(0.6).ignoresSafeArea()
                ProgressView()
            }
            
        }
    }
}

#Preview {
    DayView(vm: WalkingRecordViewModel())
}
