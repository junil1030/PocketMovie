//
//  HorizontalScrollSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import SwiftUI

struct HorizontalScrollSection<Content: View>: View {
    let title: String
    let showsIndicators: Bool
    let spacing: CGFloat
    let horizontalPadding: CGFloat
    @ViewBuilder let content: Content
    
    init(
        title: String,
        showsIndicators: Bool = false,
        spacing: CGFloat = 12,
        horizontalPadding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.showsIndicators = showsIndicators
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, horizontalPadding)
            
            ScrollView(.horizontal, showsIndicators: showsIndicators) {
                HStack(spacing: spacing) {
                    content
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
    }
}

#Preview {
    HorizontalScrollSection(title: "테스트 섹션") {
        ForEach(1...5, id: \.self) { index in
            Rectangle()
                .fill(Color.blue)
                .frame(width: 100, height: 150)
                .cornerRadius(8)
        }
    }
}
