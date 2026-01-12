

import SwiftUI
import PhotosUI

struct WalkRecordView: View {
    @ObservedObject var vm: WalkViewModel
    init(vm: WalkViewModel) { self.vm = vm }
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("산책 기록하기")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("오늘의 산책을 사진과 함께 기록해보세요")
                .font(.title3)
                .foregroundColor(.gray)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack {
                Text("산책 사진")
                    .font(.title3)
                
                Text("(최대 1장)")
                    .font(.body)
                    .foregroundStyle(Color.gray)
            }
            
            Text("선택한 사진과 함께 산책 코스가 기록됩니다")
                .font(.subheadline)
            
            
            Button(action: {
                vm.showUploadSheet.toggle()
            }, label: {
                if let selectedImage = vm.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 30)
                } else {
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color(.systemGray4))
                            .overlay(alignment: .center) {
                                Image("Camera")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
                    }
                    .padding(.bottom, 30)
                }
            })
            
            
            VStack(alignment: .leading) {
                Text("산책 일기 작성하기")
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: $vm.note)
                        .focused($isTextFieldFocused)
                        .frame(height: 150)
                        .scrollContentBackground(.hidden)
                        .onChange(of: vm.note) { oldValue, newValue in
                            if(newValue.count > 500) { vm.note = oldValue }
                        }
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: 200, alignment: .leading)
                .background { Color(hex: "#FFFFFF") }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.top, 8)
                .overlay {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#C2C3CA"), lineWidth: 1)
                        
                        if(vm.note == "" && isTextFieldFocused == false) {
                            Text("작성한 산책 일기의 내용은 나만 볼 수 있어요")
                                .foregroundStyle(Color(hex: "#818185"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                    }
                }
                
                HStack {
                    Spacer()
                    Text("\(vm.note.count)/500자")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "#818185"))
                }
            }
            
            VStack {
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        
                        if(vm.isWalkInImageAlert) {
                            HStack(alignment: .top) {
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color(hex: "#FF3B21"))
                                VStack(alignment: .leading) {
                                    Text("산책 중 사진이 아닙니다")
                                        .foregroundStyle(Color(hex: "#FF3B21"))
                                    Text("산책 중 촬영한 사진을 업로드 해주세요")
                                        .font(.subheadline)
                                        .foregroundStyle(Color(hex: "#FF3B21"))
                                }
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#FFF0EE"))
                                    .stroke(Color(hex: "#FFD0C9"), lineWidth: 1)
                            }
                        } else {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundStyle(Color(hex: "#FFFFFF"))
                                Text("산책 중 촬영한 사진만 업로드 가능합니다")
                                    .foregroundStyle(Color(hex: "#FFFFFF"))
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#555555"))
                            }
                        }
                        HStack {
                            OutlineActionButton(title: "이전으로") {
//                                vm.dismiss()
                                vm.walkRecordGoPrev()
                            }
                            .frame(width: geo.size.width / 3)
                            
                            Button(action: {
                                Task {
                                    vm.saveImage()
//                                    vm.goNext(.checkRecordingView)
                                    vm.walkRecordGoNext()
                                }
                            }, label: {
                                HStack {
                                    Text("다음으로")
                                        .font(.title3)
                                        .foregroundStyle(Color(hex: "#FFFFFF"))
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color(hex: "#FFFFFF"))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                                .background { Color(hex: "#52CE4B") }
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            })
                        }
                    }
                }
            }
        }
        .padding(.top, 38)
        .padding(.horizontal, 20)
        .background(Color(hex: "#FFFFFF"))
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
                .offset(x: -120, y: 280)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .photosPicker(isPresented: $vm.showPhotoPicker, selection: $vm.selectedItem)
        .sheet(isPresented: $vm.showCamera) { CameraPicker(image: $vm.selectedImage) }
        .onChange(of: vm.selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        if let date = vm.extractExifDate(from: data) {
                            if(vm.isWithinWalk(date)) {
                                vm.isWalkInImageAlert = false
                                if let image = UIImage(data: data) {
                                    vm.selectedImage = image
                                }
                            } else {
                                vm.isWalkInImageAlert = true
                            }
                        }
                    }
                }
            }
        }
        .onTapGesture { isTextFieldFocused = false }
    }
}
#Preview {
    WalkRecordView(vm: WalkViewModel())
}
