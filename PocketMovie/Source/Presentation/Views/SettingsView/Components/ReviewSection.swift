//
//  ReviewSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI

struct ReviewSection: View {
    var body: some View {
        Button {
            showReviewPage()
        } label: {
            HStack {
                Image(systemName: "star.bubble")
                    .foregroundColor(.yellow)
                Text("앱 리뷰 작성")
                    .foregroundColor(.yellow)
            }
        }
    }
    
    private func showReviewPage() {
        let urlString = "itms-apps://itunes.apple.com/app/id6745817964"
        guard let url = URL(string: urlString) else { return }
        
        UIApplication.shared.open(url)
    }
}

#Preview {
    ReviewSection()
}
