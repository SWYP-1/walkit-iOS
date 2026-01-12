
import SwiftUI
import CoreLocation

struct CheckRecordingView: View {
    @ObservedObject var vm: WalkViewModel
    @FocusState private var isTextFieldFocused: Bool
    init(vm: WalkViewModel) { self.vm = vm }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 10) {
                WalkItCountView(leftTitle: "걸음 수", rightTitle: "산책 시간", avgSteps: $vm.steps, walkTime: $vm.elapsedTime)
                    .frame(height: 90)
                
                VStack(alignment: .leading) {
                    Text("목표 진행률")
                        .font(.title3).bold()
                    if(vm.updateGoalsPercent > 0) {
                        Text("오늘 산책으로 목표에 \(vm.updateGoalsPercent)% 가까워졌어요!")
                            .foregroundStyle(Color(hex: "#1D7AFC"))
                    }
                    GradientLinearSpinner(progress: vm.goalCountPercent, height: 15, firstColor: Color(hex: "#52CE4B"), lastColor: Color(hex: "#22A04C"), backgroundColor: Color(hex: "#F5F5F5"))
                }
                .padding(20)
                .background { Color(hex: "#FFFFFF") }
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                
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
                    
                    HStack(spacing: 8) {
                        Image("\(vm.emotionBeforeWalk)Circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        Image("\(vm.emotionAfterWalk)Circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        Spacer()
                    }
                    
                    if(!vm.note.isEmpty || vm.isTextEditor) {
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
                                vm.note = ""
                                vm.isTextEditor = false
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
                
                VStack {
                    GeometryReader { geo in
                        HStack {
                            OutlineActionButton(title: "이전으로") {
                                vm.walkRecordGoPrev()
                            }
                            .frame(width: geo.size.width / 3.5)
                            
                            Button(action: {
                                Task {
                                    vm.showSavingProgress = true
                                    if(vm.savedImage == nil) {
                                        vm.captureMapImage()
                                    } else {
                                        let result = await vm.saveWalk()
                                        if(result) { vm.showSavingSuccess = true }
                                        vm.showSavingProgress = false
                                    }
                                }
                            }, label: {
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
                            })
                        }
                    }
                }
                .padding(.bottom, 50)
            }
            
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .background(Color(hex: "#F3F3F5"))
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    CheckRecordingView(vm: WalkViewModel())
}

