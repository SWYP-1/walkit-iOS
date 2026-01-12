//
//  OutlineActionButton.swift
//  WalkIt
//
//  Created by 조석진 on 12/27/25.
//

import SwiftUI


struct FilledActionButton: View {
    let title: String
    @Binding var isEnable: Bool
    let isRightChevron: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.title3)
                    .foregroundStyle(isEnable ? Color(hex: "#FFFFFF") : Color(hex: "#818185"))
                
                if(isRightChevron) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundStyle(isEnable ? Color(hex: "#FFFFFF") : Color(hex: "#818185"))
                }   
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isEnable ? Color(hex: "#52CE4B") : Color(hex: "#F3F3F5"))
            )
        }
        
        .disabled(!isEnable)
    }
}

#Preview {
    FilledActionButton(title: "테스트", isEnable: .constant(true), isRightChevron: true) {}
}
