//
//  CardPreviewSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct CardPreviewSection: View {
    let movie: KMDBMovie
    let rating: Int
    let review: String
    @Binding var isFlipped: Bool
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("카드 미리보기")
                .font(.headline)
                .padding(.horizontal)
            
            PreviewCard(
                movie: movie,
                rating: rating,
                review: review,
                isFlipped: $isFlipped,
                cardWidth: cardWidth,
                cardHeight: cardHeight
            )
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    //CardPreviewSection()
}
