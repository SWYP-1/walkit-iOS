//
//  GoalManagerView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI

struct GoalsManagerView: View {
    @StateObject var vm: GoalsManagerViewModel
    
    @Binding var path: NavigationPath
    init(vm: GoalsManagerViewModel, path: Binding<NavigationPath>) {
        _vm = StateObject(wrappedValue: GoalsManagerViewModel())
        self._path = path
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { path = NavigationPath() } label: {
                    Image(systemName: "chevron.left")
                        .padding(.trailing, 10)
                }
                Spacer()
                Text("목표 관리")
                    .font(.headline)
                Spacer()
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    infoBanner
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("주간 산책 횟수")
                            .font(.headline)
                        Text("최소 1회 ~ 최대 7회")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 12) {
                            valueField(text: formatted(vm.targetWalkCount))
                            minusButton {
                                impact()
                                vm.targetWalkCount = max(vm.weeklyRange.lowerBound, vm.targetWalkCount - 1)
                            }
                            plusButton {
                                impact()
                                vm.targetWalkCount = min(vm.weeklyRange.upperBound, vm.targetWalkCount + 1)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Divider().padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("일일 걸음 수")
                            .font(.headline)
                        Text("최소 1,000보 ~ 최대 30,000보")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 12) {
                            valueField(text: formatted(vm.targetStepCount))
                            minusButton {
                                impact()
                                vm.targetStepCount = max(vm.stepsRange.lowerBound, vm.targetStepCount - 1000)
                            }
                            plusButton {
                                impact()
                                vm.targetStepCount = min(vm.stepsRange.upperBound, vm.targetStepCount + 1000)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 24)
                    
                    HStack(spacing: 16) {
                        OutlineActionButton(title: "초기화") {
                            vm.targetWalkCount = 1
                            vm.targetStepCount = 1000
                        }
                        FilledActionButton(title: "저장하기", isEnable: $vm.isEditEanble, isRightChevron: false) {
                            Task {
                                await vm.putGoals()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .padding(.top, 16)
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            Task { @MainActor in
                await vm.getGoals()
                vm.isEditEanble = !(vm.isSameMonthRecorded())
            }
        }
    }
}

// MARK: - Subviews
private extension GoalsManagerView {
    var infoBanner: some View {
        VStack {
            if(!vm.isEditEanble) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(hex: "#FF3B21"))
                        .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("이번 달 목표 수정이 불가능합니다")
                            .font(.subheadline).bold()
                            .foregroundStyle(Color(hex: "#FF3B21"))
                        Text("목표는 한 달에 한 번만 변경 가능합니다.")
                            .font(.footnote)
                            .foregroundStyle(Color(hex: "#FF3B21"))
                    }
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(hex: "#FFF0EE"))
                        .stroke(Color(hex: "#FFD0C9"), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            } else {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color(hex: "#1D7AFC"))
                        .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("목표는 설정일부터 1주일 기준으로 설정 가능합니다.")
                            .font(.subheadline).bold()
                            .foregroundStyle(Color(hex: "1D7AFC"))
                        Text("목표는 한 달에 한 번만 변경 가능합니다")
                            .font(.footnote)
                            .foregroundStyle(Color(hex: "1D7AFC"))
                        Text("변경된 목표는 목표 달성율과 캐릭터 레벨업에 영향을 미칩니다")
                            .font(.footnote)
                            .foregroundStyle(Color(hex: "1D7AFC"))
                    }
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(hex: "#E9F2FF"))
                        .stroke(Color(hex: "#84B8FF"), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    func valueField(text: String) -> some View {
        Text(text)
            .font(.title3)
            .foregroundStyle(Color(hex: "#191919"))
            .frame(maxWidth: .infinity, maxHeight: 46, alignment: .leading)
            .padding(.horizontal, 16)
        
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#FFFFFF"))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#191919"), lineWidth: 1)
                    }
            }
    }
    
    func minusButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "minus")
                .font(.headline)
                .foregroundStyle(Color(hex: "#191919"))
                .frame(width: 48, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(hex: "#191919"), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(hex: "FFFFFF"))
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("감소")
    }
    
    func plusButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.headline)
                .foregroundStyle(Color(hex: "#FFFFFF"))
                .frame(width: 48, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(hex: "#191919"))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("증가")
    }
    
    func formatted(_ value: Int) -> String {
        vm.numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    func impact() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
    }
}

#Preview {
    GoalsManagerView(vm: GoalsManagerViewModel(), path: .constant(NavigationPath()))
}
