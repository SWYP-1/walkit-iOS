//
//  TabBarButton.swift
//  WalkIt
//
//  Created by 조석진 on 1/2/26.
//

import SwiftUI

struct TabBarButton: View {
    let iconName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color(hex: "#52CE4B") : Color(hex: "#D7D9E0"))
                    .animation(.spring(), value: isSelected)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? Color(hex: "#52CE4B") : Color(hex: "#D7D9E0"))
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color(hex: "#F3FFF8") : Color(hex: "#FFFFFF"))
        }
    }
}
