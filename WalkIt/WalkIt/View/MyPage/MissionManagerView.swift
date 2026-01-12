//
//  MissionManagerView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI

struct MissionManagerView: View {
    @ObservedObject var vm: MissionManagerViewModel
    @Binding var path: NavigationPath
    init(vm: MissionManagerViewModel, path: Binding<NavigationPath>) {
        self.vm = vm
        self._path = path
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    banner
                    
                    VStack(alignment: .leading) {
                        Text("오늘의 미션")
                            .font(.title3).bold()
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 20)
                        
                        Text("미션은 한 주에 최대 1개씩 수행할 수 있어요")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 20)
                    }
                    
                    categoryChips
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 14) {
                        if let weeklyMission = vm.weeklyMission {
                            if(weeklyMission.active.type == vm.selected.rawValue) {
                                MissionCard(mission: weeklyMission.active, action: {
                                    Task {
                                        let result = await vm.postVerifyMission(missionId: weeklyMission.active.userWeeklyMissionId ?? 0)
                                        if(result) { await vm.getWeeklyMission() }
                                    }
                                })
                                .padding(.horizontal, 20)
                            }
                            
                            ForEach(weeklyMission.others, id: \.self.missionId) { mission in
                                if(mission.type == vm.selected.rawValue) {
                                    MissionCard(mission: mission, action: {})
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                }
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
        .onAppear {
            vm.loadView()
        }
    }
}

// MARK: - Subviews
private extension MissionManagerView {
    var topBar: some View {
        HStack {
            Button {
                path = NavigationPath()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.black)
                    .padding(.trailing, 10)
            }
            Spacer()
            Text("미션")
                .font(.headline)
            Spacer()
            Color.clear.frame(width: 24, height: 24)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    var banner: some View {
        VStack {
            Image("MissionBanner")
                .resizable()
                .scaledToFit()
        }
        .frame(maxWidth: .infinity)
    }
    
    var categoryChips: some View {
        HStack(spacing: 10) {
            ForEach(MissionType.allCases) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        vm.selected = type
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(getTypeKOR(type))
                            .font(.headline)
                            .foregroundStyle(vm.selected == type ? Color(.systemGreen) : .primary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(vm.selected == type ? Color(.systemGreen) : Color(.systemGray4), lineWidth: 2)
                            .background {
                                if(vm.selected == type) {
                                    Capsule()
                                        .fill(Color(.systemGreen).opacity(0.1))
                                }
                            }
                    )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
    func getTypeKOR(_ categoty: MissionType) -> String {
        switch(categoty) {
        case .steps: "걸음 수"
        case .attendance: "연속 출석"
        }
    }
}

#Preview {
    MissionManagerView(vm: MissionManagerViewModel(), path: .constant(NavigationPath()))
}
