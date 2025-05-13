//
//  CardPreview.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI
import Kingfisher

struct PreviewCard: View {
    let movie: KMDBMovie
    let rating: Int
    let review: String
    
    @Binding var isFlipped: Bool
    
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    var body: some View {
        ZStack {
            if isFlipped {
                PreviewReviewCardView(
                    movie: movie,
                    rating: rating,
                    review: review,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight
                )
            } else {
                PreviewPosterCardView(
                    movie: movie,
                    rating: rating,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight
                )
            }
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(duration: 0.5), value: isFlipped)
        .onTapGesture {
            isFlipped.toggle()
        }
    }
}

#Preview {
    //CardPreview()
}
