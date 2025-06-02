//
//  CardPreview.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI
import Kingfisher

struct PreviewCard: View {
    let movie: TMDBMovie
    let rating: Int
    let review: String
    @Binding var isFlipped: Bool
    
    var body: some View {
        CommonMovieCard(
            cardData: CardDisplayData(from: movie, rating: Double(rating), review: review),
            isFlipped: isFlipped,
            cardSize: .medium,
            showSelection: false,
            isSelected: false,
            onTap: { isFlipped.toggle() }
        )
    }
}

#Preview {
    //CardPreview()
}
