//  checkBoxTextView.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//
import SwiftUI

struct OutlineActionButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3)
                .foregroundStyle(Color(hex: "#52CE4B"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "#52CE4B"), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(hex: "#FFFFFF"))
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OutlineActionButton(title: "테스트", action: {})
}
