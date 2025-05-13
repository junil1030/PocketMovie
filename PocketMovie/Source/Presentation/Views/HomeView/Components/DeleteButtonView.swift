//
//  DeleteButtonView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct DeleteButtonView: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "trash.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                        .background(Circle().fill(.ultraThinMaterial))
                        .shadow(radius: 3)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    //DeleteButtonView()
}
