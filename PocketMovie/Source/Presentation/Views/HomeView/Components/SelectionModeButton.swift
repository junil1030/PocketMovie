//
//  SelectionModeButton.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct SelectionModeButton: View {
    @Binding var isSelectionMode: Bool
    var onToggle: () -> Void
    
    var body: some View {
        Button {
            isSelectionMode.toggle()
            onToggle()
        } label: {
            Image(systemName: isSelectionMode ? "checkmark.circle.fill" : "ellipsis")
        }
    }
}

#Preview {
    //SelectionModeButton()
}
