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
    let onTap: () -> Void
    
    var body: some View {
        CommonMovieCard(
            cardData: CardDisplayData(from: movie),
            isFlipped: isFlipped,
            cardSize: .large,
            showSelection: true,
            isSelected: isSelected,
            onTap: onTap
        )
    }
}

#Preview {
    //MovieCardView()
}
