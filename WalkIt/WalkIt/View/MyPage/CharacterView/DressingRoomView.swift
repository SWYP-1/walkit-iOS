//
//  CharacterView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import PhotosUI
import Kingfisher

struct DressingRoomView: View {
    @ObservedObject var vm: DressingRoomViewModel
    @Binding var selection: TabType
    var selectionType: TabType = .CHARACTER
    init(vm: DressingRoomViewModel, selection: Binding<TabType>) {
        self.vm = vm
        self._selection = selection
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                characterCard
                    .padding(.bottom, -80)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("아이템 목록")
                            .font(.system(size: 20)).bold()
                            .foregroundStyle(Color(hex: "#191919"))
                        
                        Spacer()
                        
                        Text("보유한 아이템만 보기")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: "#818185"))
                        
                        Toggle("", isOn: $vm.isShowOwnedItem)
                            .labelsHidden()
                        
                    }
                    .padding(20)
                    
                    
                    
                    ScrollView {
                        if(vm.isShowOwnedItem) {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                                let ownedItems = vm.items.filter{ $0.owned == true }
                                ForEach(ownedItems.indices, id: \.self) { idx in
                                    itemCard(item: ownedItems[idx])
                                        .onTapGesture {
                                            debugPrint("selecItem")
                                            vm.selecItem(item: ownedItems[idx])
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                        } else {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                                ForEach(vm.items.indices, id: \.self) { idx in
                                    itemCard(item: vm.items[idx])
                                        .onTapGesture {
                                            debugPrint("selecItem")
                                            vm.selecItem(item: vm.items[idx])
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                        }
                    }
                    
                    // 하단 버튼
                    
                    HStack {
                        Button {
                            Task { @MainActor in
                                vm.lottieJson = await vm.removeAllItem(json: vm.lottieJson)
                            }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color(hex: "#52CE4B"))
                                .padding(5)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "#52CE4B"), lineWidth: 1)
                                )
                        }
                        
                        Button {
                            Task {
                                vm.saveItem()
                            }
                        } label: {
                            Text("저장하기")
                                .font(.headline)
                                .foregroundStyle(vm.isChangedItem() ? Color(hex: "#FFFFFF") : Color(hex: "#818185"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(vm.isChangedItem() ? Color(hex: "#52CE4B") : Color(hex: "#EBEBEE"))
                                )
                        }
                        .disabled(!vm.isChangedItem())
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .padding(.bottom, 20)
                    .background(
                        Color(hex: "#FFFFFF")
                            .shadow(color:Color(hex: "#000000", alpha: 0.05), radius: 2, y: -10)
                    )
                    
                }
                .background(
                    TopRoundedShape(radius: 28)
                        .fill(Color(.systemBackground))
                )
                .clipShape(TopRoundedShape(radius: 28))
            }
            if(vm.isShowBuy) {
                Color(hex: "#000000").opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        vm.isShowBuy = false
                    }
                
                VStack {
                    Spacer()
                    VStack {
                        HStack {
                            Text("구매할 아이템을 확인해주세요!")
                                .font(.title2)
                                .foregroundStyle(Color(hex: "#191919"))
                            
                            Spacer()
                            
                            Button {
                                vm.isShowBuy = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.title2).bold()
                                    .foregroundStyle(Color(hex: "#191919"))
                            }
                        }
                        
                        HStack {
                            Text("보유 포인트")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(hex: "#818185"))
                            Spacer()
                            Text("\(vm.point)P")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(hex: "#818185"))
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "#EBEBEE"))
                        )
                        .padding(.vertical)
                        
                        let buyItems = [vm.headItem, vm.bodyItem, vm.feetItem].compactMap{$0}.filter { $0.owned == false }
                        let sumPoints = buyItems.reduce(0) { $0 + $1.point}
                        let canBuy = sumPoints <= vm.point
                        ForEach(buyItems, id: \.self) { item in
                            let style = vm.categoryStyle(for: item.position)
                            HStack {
                                Text(style.text)
                                    .foregroundStyle(style.foreground)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Capsule().fill(style.background))
                                Text(item.name)
                                Spacer()
                                Text(String(item.point) + "P").font(.body).bold()
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 20)
                        
                        HStack {
                            Text("총 사용 포인트")
                            Spacer()
                            Text(String(-sumPoints))
                                .font(.title2).bold()
                                .foregroundStyle(Color(hex: "#FF3B21"))
                        }
                        .padding(.bottom, 20)
                        
                        if(!canBuy) {
                            HStack {
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color(hex: "#FF3B21"))
                                Text("보유 포인트를 초과해 구매가 어렵습니다.")
                                    .foregroundStyle(Color(hex: "#FF3B21"))
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#FFF0EE"))
                                    .stroke(Color(hex: "#FFD0C9"), lineWidth: 1)
                            )
                        }
                        
                        Button {
                            Task { @MainActor in
                                await vm.buyItems()
                                await vm.fetchItemst()
                                await vm.getPoint()
                            }
                        } label: {
                            HStack {
                                Text("구매하기")
                                    .foregroundStyle(canBuy ? Color(hex: "#FFFFFF") : Color(hex: "#818185"))
                                    .font(.body)
                                if(canBuy) {
                                    Text(String(buyItems.count))
                                        .font(.system(size: 12))
                                        .padding(6)
                                        .foregroundStyle(Color(hex: "#22A04C"))
                                        .background(Circle().fill(Color(hex: "#FFFFFF")))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(canBuy ? Color(hex: "#52CE4B") : Color(hex: "#EBEBEE"))
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!canBuy)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#FFFFFF"))
                    )
                    .padding(20)
                }
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
                            selection = selectionType
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
                                vm.saveItem()
                                selection = selectionType
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
            
            
            if(vm.isShowInfo) {
                Color(hex: "#000000").opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        vm.isShowInfo = false
                    }
                VStack(spacing: 20) {
                    HStack {
                        Text("캐릭터 레벨")
                            .font(.title).bold()
                        Spacer()
                        
                        Button {
                            vm.isShowInfo = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title).bold()
                                .foregroundStyle(Color(hex: "#191919"))
                        }
                    }
                    HStack {
                        VStack {
                            Image("SeedInfo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 70)
                            Text("씨앗")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(hex: "#6EB3BF"))
                                .capsuleTagStyle(backgroundColor: Color(hex: "#F0FCFF"))
                                .frame(height: 30)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#EBEBEE"), lineWidth: 1)
                        )
                        .frame(width: 100, height: 140)
                        
                        VStack {
                            Spacer()
                            HStack {
                                Text("Lv.01").font(.system(size: 14)).bold()
                                Text("누적 주간 목표 1주 달성").font(.system(size: 12))
                            }
                            .frame(maxHeight: .infinity)
                            Divider()
                            HStack {
                                Text("Lv.02").font(.system(size: 14)).bold()
                                Text("누적 주간 목표 4주 달성").font(.system(size: 12))
                            }
                            .frame(maxHeight: .infinity)
                            Divider()
                            HStack {
                                Text("Lv.02").font(.system(size: 14)).bold()
                                Text("누적 주간 목표 6주 달성").font(.system(size: 12))
                            }
                            .frame(maxHeight: .infinity)
                            Spacer()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "#F5F5F5"))
                        )
                    }
                    .frame(maxHeight: 140)
                    
                    HStack {
                        VStack {
                            Image("SproutInfo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 70)

                            Text("새싹")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(hex: "#6EB3BF"))
                                .capsuleTagStyle(backgroundColor: Color(hex: "#F0FCFF"))
                                .frame(height: 30)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#EBEBEE"), lineWidth: 1)
                        )
                        .frame(width: 100, height: 140)
                        
                        VStack {
                            Spacer()
                            HStack {
                                Text("Lv.04").font(.system(size: 14)).bold()
                                Text("누적 주간 목표 8주 달성").font(.system(size: 12))
                            }
                            .frame(maxHeight: .infinity)
                            Divider()
                            HStack {
                                Text("Lv.05").bold().font(.system(size: 14))
                                Text("누적 주간 목표 10주 달성").font(.system(size: 12))
                            }
                            .frame(maxHeight: .infinity)
                            Divider()
                            HStack {
                                Text("Lv.06").font(.system(size: 14)).bold()
                                Text("누적 주간 목표 2주 달성").font(.system(size: 12))
                            }
                            .frame(maxHeight: .infinity)
                            Divider()
                            HStack {
                                Text("Lv.07").font(.system(size: 14)).bold()
                                Text("누적 주간 목표 4주 달성").font(.system(size: 12))
                            }
                            .frame(maxHeight: .infinity)
                            Spacer()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "#F5F5F5"))
                        )
                        
                    }
                    .frame(maxHeight: 140)
                    Text("* 새싹 Lv.06부터 레벨업 달성 시 이전 기록이 초기화 됩니다")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "#C2C3CA"))
                        .padding(.top, 0)
                    
                    HStack {
                        VStack {
                            Image("TreeInfo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 70)
                            Text("나무")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(hex: "#6EB3BF"))
                                .capsuleTagStyle(backgroundColor: Color(hex: "#F0FCFF"))
                                .frame(height: 30)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#EBEBEE"), lineWidth: 1)
                        )
                        .frame(width: 100, height: 140)
                        
                        VStack {
                            Spacer()
                            HStack {
                                Text("Lv.08").font(.system(size: 14)).bold()
                                Text("누적 주간 목표 6주 달성").font(.system(size: 12))
                            }
                            .frame(maxHeight: .infinity)
                            Divider()
                            HStack {
                                Text("Lv.09").bold().font(.system(size: 14))
                                Text("누적 주간 목표 8주 달성").font(.system(size: 12))
                            }
                            .frame(maxHeight: .infinity)
                            Divider()
                            HStack {
                                Text("Lv.10").bold().font(.system(size: 14))
                                Text("누적 주간 목표 10주 달성").font(.system(size: 12))
                            }
                            .frame(maxHeight: .infinity)
                            Spacer()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "#F5F5F5"))
                        )
                    }
                    .frame(maxHeight: 140)
                    
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "#FFFFFF"))
                )
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            if !vm.didLoad {
                vm.loadView()
            }
        }
        .ignoresSafeArea(.all)
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

// MARK: - Subviews
private extension DressingRoomView {
    var characterCard: some View {
        ZStack(alignment: .center) {
            if let backgroundImage = vm.character.backgroundImageName {
                KFImage(URL(string: backgroundImage))
                    .retry(maxCount: 3)
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth))
            } else {
                Image("BackGround")
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth))
            }
            
            if(!vm.lottieJson.isEmpty) {
                LottieCharacterView(json: vm.lottieJson)
                    .frame(width: UIScreen.main.bounds.width * 0.48)
                    .offset(y: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth) * 0.04)
            }
            
            VStack {
                HStack(spacing: 12) {
                    HStack {
                        Text("P")
                            .font(.body)
                            .foregroundStyle(Color(hex: "#D7A204"))
                            .padding(5)
                            .background(Circle().fill(Color(hex: "#FEF7D7"))
                            )
                        Text("\(vm.point)")
                            .font(.body)
                            .foregroundStyle(Color(hex: "#191919"))
                    }
                    
                    Spacer()
                    Text("Lv.\(vm.character.level) \(vm.getGrade(grade: vm.character.grade))")
                        .font(.system(size: 14)).bold()
                        .foregroundStyle(Color(hex: "#6EB3BF"))
                        .padding(.vertical, 5)
                        .capsuleTagStyle(backgroundColor: Color(hex: "#F0FCFF"))
                    
                    Spacer()
                    
                    Button {
                        vm.isShowInfo = true
                    } label : {
                        Image(systemName: "questionmark")
                            .foregroundStyle(Color(hex: "#FFFFFF"))
                            .padding(5)
                            .background(Circle().fill(Color(hex: "#191919")))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                Spacer()
            }
            VStack {
                Spacer()
                LinearGradient(
                    colors: [Color(hex: "#191919", alpha: 0.4), Color(hex: "#FFFFFF", alpha: 0)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 200)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func itemCard(item: CosmeticItem) -> some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#FFFFFF"))
                    .stroke(Color(hex: "#EBEBEE"))
                KFImage(URL(string: item.imageName))
                    .placeholder { ProgressView() }
                    .retry(maxCount: 3)
                    .resizable()
                    .cacheOriginalImage()
                    .scaledToFit()
                    .padding(10)
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 5)
            
            let style = vm.categoryStyle(for: item.position)
            Text(style.text)
                .foregroundStyle(style.foreground)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(style.background))
            
            HStack {
                Text("P")
                    .font(.body)
                    .foregroundStyle(Color(hex: "#D7A204"))
                    .padding(5)
                    .background(
                        Circle()
                            .fill(Color(hex: "#FEF7D7"))
                    )
                Text("\(item.point)")
                    .font(.body)
                    .foregroundStyle(Color(hex: "#191919"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(vm.isWearingItem(item: item) ? Color(hex: "#F3FFF8") : Color(hex: "#FFFFFF"))
                    .stroke(vm.isWearingItem(item: item) ? Color(hex: "#52CE4B") : Color(hex: "#EBEBEE"), lineWidth: 1)
                if(item.owned) {
                    MyCardShape()
                        .fill(vm.isWearingItem(item: item) ? Color(hex: "#52CE4B") : Color(hex: "#F5F5F5"))
                        .frame(width: 30, height: 40)
                    
                    Text("MY")
                        .font(.system(size: 12))
                        .foregroundStyle(vm.isWearingItem(item: item) ? Color(hex: "#FFFFFF") : Color(hex: "#C2C3CA"))
                        .frame(width: 30, height: 40)
                }
            }
        )
    }
}

private struct TopRoundedShape: Shape {
    var radius: CGFloat = 24

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    DressingRoomView(vm: DressingRoomViewModel(), selection: .constant(.CHARACTER))
}
