//
//  CapsuleTag.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//
import SwiftUI

struct EnableNavigationLink<Destination: View>: View {
    @Binding var isEnable: Bool
    let text: String
    let isRightChevron: Bool
    let destination: Destination
    
    init(
        isEnable: Binding<Bool>,
        text: String,
        isRightChevron: Bool,
        @ViewBuilder destination: () -> Destination
    ) {
        self._isEnable = isEnable
        self.text = text
        self.isRightChevron = isRightChevron
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                Text(text)
                    .font(.headline)
                    .foregroundColor(isEnable ? Color(hex: "#FFFFFF") : Color(hex: "#818185"))
                    
                if(isRightChevron) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(isEnable ? Color(hex: "#FFFFFF") : Color(hex: "#818185"))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .disabled(!isEnable)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(isEnable ? Color(hex: "#52CE4B") : Color(hex: "#F3F3F5"))
        }
    }
}

#Preview {
    EnableNavigationLink(isEnable: .constant(true), text: "회원가입", isRightChevron: true) {
        Text("DestinationView")
    }
}
