

import SwiftUI
import Kingfisher

struct HomeView: View {
    private let userManager = UserManager.shared
    @ObservedObject var vm: HomeViewModel
    @Binding var path: NavigationPath
    @Binding var selection: TabType
    @State private var isFirst: Bool = true
    
    private let colorChip = [Color.orange, Color.pink, .green, .cyan, .blue,  .purple, .yellow]
    
    init(vm: HomeViewModel, path: Binding<NavigationPath>, selection: Binding<TabType>) {
        self.vm = vm
        self._path = path
        self._selection = selection
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ScrollView {
                    navigationBar // 네비게이션 바
                    VStack(alignment: .leading, spacing: 10) {
                        mascotArea  //마스코트 영역
                        missionSection // 추천 미션
                        weeklyWalkSection // 이번주 산책 기록(가로 스크롤)
                        emotionSection // 나의 감정 기록
                    }
                }
                .background(Color(hex: "#FFFFFF"))
                .navigationTitle("")
                .navigationBarHidden(true)
            }
            stepsArea // 산책하기 버튼
            if(!vm.isAgreeLocationService) {
                Color(hex: "#000000").opacity(0.5)
                VStack {
                    Spacer()
                    VStack {
                        Text("위치 서비스 사용 동의")
                            .font(.title).bold()
                        
                        Text("산책 중인 위치를 바탕으로 날씨 정보를\n알려주고 나만의 산책 경로를 기록해요")
                            .foregroundStyle(Color(hex: "#818185"))
                        
                        Button {
                            vm.openAppSettings()
                            vm.isAgreeLocationService = true
                        } label: {
                            Text("동의하고 시작하기")
                                .font(.title3)
                                .foregroundStyle(Color(hex: "#FFFFFF"))
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(hex: "#52CE4B"))
                        )
                        
                        Button("나중에 할게요") {
                            vm.isAgreeLocationService = true
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "#818185"))
                        .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#FFFFFF"))
                    )
                    Spacer()
                }
                .padding(.horizontal, 20)
                
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            vm.loadView()
            vm.loadViewWalkData()
            if(!path.isEmpty) { path = NavigationPath() }
        }
    }
    
    // MARK: - NavigationBar
    private var navigationBar: some View {
        HStack {
            Image("HomeLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 61)
            
            Spacer()
            
            Button {
                path.append(HomeRoute.notificationView)
            } label: {
                Image(systemName: "bell")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(hex: "#191919"))
            }
            
            if let img = userManager.profileImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .onTapGesture {
                        selection = .MYPAGE
                    }
            } else {
                Image("DefaultImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .onTapGesture {
                        selection = .MYPAGE
                    }
            }
        }
        .padding(.top, 50)
        .padding(.bottom, 10)
        .padding(.horizontal, 20)
    }
    
    private var mascotArea: some View {
        VStack {
            ZStack {
                if(vm.useDefaultImage) {
                    Image("BackGround")
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth))
                } else {
                    KFImage(URL(string: vm.backgroundImageName))
                        .retry(maxCount: 3)
                        .cacheOriginalImage()
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth))
                }
                
                if(!vm.lottieJson.isEmpty) {
                    LottieCharacterView(json: vm.lottieJson)
                        .frame(width: UIScreen.main.bounds.width * 0.48)
                        .offset(y: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth) * 0.04)
                        .onTapGesture {
                            selection = .CHARACTER
                        }
                } else {
                    ProgressView()
                }
            
                
                VStack {
                    HStack {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(String(vm.todaySteps))
                                .font(.largeTitle)
                                .bold()
                            Text("걸음")
                                .font(.body)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Image(vm.sky)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24)
                            
                            Text(String(vm.tempC))
                                .font(.title2)
                        }
                        .padding(.vertical, 4)
                        .foregroundStyle(.white)
                        .modifier(CapsuleBackground(backgroundColor: Color(hex: "#000000", alpha: 0.1)))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(userManager.nickname)
                            .font(.largeTitle).fontWeight(.bold)
                        
                        Text("Lv.\(vm.level) \(vm.getGrade(grade: vm.grade))")
                            .font(.title3)
                            .foregroundStyle(Color(hex: "#2ABB42"))
                            .modifier(CapsuleBackground(backgroundColor: Color(hex: "#D8FFD6")))
                        Spacer()
                    }
                    
                    GradientLinearSpinner(progress: ((Double(vm.walkProgressPercentage) ?? 0) / 100), height: 15, firstColor: Color(hex: "#52CE4B"), lastColor: Color(hex: "#22A04C"), backgroundColor: Color(hex: "#FFFFFF"))
                    
                    HStack {
                        Text("\(userManager.targetWalkCount)일 / \(userManager.targetStepCount)걸음")
                            .font(.title)
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Text("\(Int((Double(vm.walkProgressPercentage) ?? 0).rounded()))%")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
        }
        .frame(height: UIScreen.main.bounds.width * (vm.backGroundImageHeight / vm.backGroundImageWidth))
    }

    private var stepsArea: some View {
        HStack(alignment: .center) {
            Spacer()
            Button(action: {
                guard let locationStatus = LocationService.shared.checkLocationPermission()
                else { return }
                
                let pedometerStatus = PedometerManager.shared.checkMotionPermission()
                
                if(pedometerStatus && locationStatus) {
                    path.append(HomeRoute.emotionBeforeWalkView)
                }  else {
                    vm.isAgreeLocationService = false
                }
            }, label: {
                Image("WalkingImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            })
            .buttonStyle(.plain)
            .padding(.trailing, 10)
            .padding(.bottom, 10)
        }
        
    }
//
    
    private var missionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                Text("오늘의 추천 미션")
                    .font(.title).bold()
                
                Spacer()
                
                Button {
                    path.append(HomeRoute.missionManagerView)
                } label: {
                    Text("더보기")
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(Color(hex: "#818185"))
            }
            
            if let mission = vm.mission {
                MissionCard(mission: mission) {
                    Task {
                        let reuslt = await vm.postVerifyMission(missionId: mission.userWeeklyMissionId ?? 0)
                        if(reuslt) { vm.loadView() }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var weeklyWalkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("나의 산책 기록")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button {
                    selection = .WALKRECORD
                } label: {
                    Text("더보기")
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(Color(hex: "#818185"))
            }
            
            if(vm.recentlyWalk.isEmpty) {
                VStack(alignment: .center, spacing: 10) {
                    Image("EmptyWalk")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                    
                    Text("아직 산책 기록이 없어요")
                        .font(.title).bold()
                    Text("워킷과 함께 산책하고 나만의 산책 기록을 남겨보세요")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "#818185"))
                    
                    Button {
                        guard let locationStatus = LocationService.shared.checkLocationPermission() else {
                            LocationService.shared.requestLocation()
                            return
                        }
                        
                        let pedometerStatus = PedometerManager.shared.checkMotionPermission()
                        
                        if(pedometerStatus && locationStatus) {
                            path.append(HomeRoute.emotionBeforeWalkView)
                        }  else {
                            vm.isAgreeLocationService = false
                        }
                    } label: {
                        Text("산책하러 가기")
                            .foregroundStyle(Color(hex: "#FFFFFF"))
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#191919"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#F5F5F5"))
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(vm.recentlyWalk, id: \.self) { walkId in
                            WalkCard(walk: RealmManager.shared.getWalk(by: walkId) ?? WalkRecordEntity())
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var emotionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("나의 감정 기록")
                .font(.title).bold()
            
            EmotionCardView(emotion: $vm.maxEmotion, count: $vm.emotionCount, day: "이번 주")

            HStack(spacing: 4) {
                ForEach(vm.weekEmotion, id: \.self) { emotion in
                    Image("\(emotion)Rectangle")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 49)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    HomeView(vm: HomeViewModel(), path: .constant(NavigationPath()), selection: .constant(TabType.HOME))
}
