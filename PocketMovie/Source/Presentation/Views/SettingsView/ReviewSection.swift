//
//  ReviewSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI

struct ReviewSection: View {
    @State private var showReviewForm = false
    
    var body: some View {
        Button {
            showReviewForm = true
        } label: {
            HStack {
                Image(systemName: "star.bubble")
                    .foregroundColor(.yellow)
                Text("앱 리뷰 작성")
            }
        }
        .sheet(isPresented: $showReviewForm) {
            // 앱 올라가면 링크 넣어서 리뷰 창 띄우기
        }
    }
}

#Preview {
    ReviewSection()
}
