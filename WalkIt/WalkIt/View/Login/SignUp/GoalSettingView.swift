//
//  Untitled.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//

import SwiftUI

struct GoalSettingView: View {
    @ObservedObject var vm: SignUpViewModel
    @Environment(\.dismiss) private var dismiss

    init(vm: SignUpViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            Text("목표 설정")
                .foregroundStyle(Color(hex: "#FFFFFF"))
                .padding(.vertical, 4)
                .modifier(CapsuleBackground(backgroundColor: Color(hex: "#191919")))
                .padding(.top, 44)
            
            Text("\(vm.nickname)님,\n워킷과 함께 걸어봐요!")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)

            VStack(alignment: .leading) {
                Text("주간 산책 횟수")
                    .font(.body)
                    .foregroundStyle(Color(hex: "#191919"))
                
                Text("최소 1회 ~ 최대 7회")
                    .font(.footnote)
                    .foregroundStyle(Color(hex: "#C2C3CA"))
                
                HStack(spacing: 5) {
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
            
            VStack(alignment: .leading) {
                Text("일일 걸음 수")
                    .font(.body)
                    .foregroundStyle(Color(hex: "#191919"))
                
                Text("최소 1,000보 ~ 최대 30,000보")
                    .font(.footnote)
                    .foregroundStyle(Color(hex: "#C2C3CA"))
                
                HStack(spacing: 5) {
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
            
            Spacer()
            
            
            HStack {
                OutlineActionButton(title: "이전으로") { dismiss() }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.3)
                
                FilledActionButton(title: "다음으로", isEnable: .constant(true), isRightChevron: false) {
                    Task {
                        vm.isShowingProgress = true
                        await vm.postGoals()
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
    GoalSettingView(vm: SignUpViewModel())
}
