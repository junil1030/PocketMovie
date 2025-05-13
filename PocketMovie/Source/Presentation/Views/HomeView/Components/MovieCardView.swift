//
//  MovieCardView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct MovieCardView: View {
    let movie: Movie
    let isSelected: Bool
    let isFlipped: Bool
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let cardCornerRadius: CGFloat
    let cardBackgroundCornerRadius: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            if isFlipped {
                ReviewCardView(
                    movie: movie,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    cardCornerRadius: cardCornerRadius,
                    cardBackgroundCornerRadius: cardBackgroundCornerRadius
                )
            } else {
                PosterCardView(
                    movie: movie,
                    isSelected: isSelected,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    cardCornerRadius: cardCornerRadius,
                    cardBackgroundCornerRadius: cardBackgroundCornerRadius
                )
            }
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(), value: isFlipped)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    //MovieCardView()
}
