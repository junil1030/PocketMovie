//
//  EmptyStateView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Image(systemName: "film")
                .font(.system(size: 70))
                .foregroundStyle(Color("AppTextColor"))
                .padding()
            
            Text("영화를 추가해보세요!")
                .font(.title2)
                .foregroundStyle(Color("AppTextColor"))
        }
    }
}

#Preview {
    EmptyStateView()
}
