//
//  CommonMovieCard.swift
//  PocketMovie
//
//  Created by 서준일 on 6/2/25.
//

import SwiftUI
import Kingfisher

struct CommonMovieCard: View {
    let cardData: CardDisplayData
    let isFlipped: Bool
    let cardSize: CardSize
    let showSelection: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    init(
        cardData: CardDisplayData,
        isFlipped: Bool = false,
        cardSize: CardSize = .large,
        showSelection: Bool = false,
        isSelected: Bool = false,
        onTap: @escaping () -> Void = {}
    ) {
        self.cardData = cardData
        self.isFlipped = isFlipped
        self.cardSize = cardSize
        self.showSelection = showSelection
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    var body: some View {
        ZStack {
            if isFlipped {
                CommonReviewCard(
                    cardData: cardData,
                    cardSize: cardSize
                )
            } else {
                CommonPosterCard(
                    cardData: cardData,
                    cardSize: cardSize
                )
            }
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(), value: isFlipped)
        .opacity(showSelection && isSelected ? 0.7 : 1.0)
        .overlay(
            Group {
                if showSelection && isSelected {
                    RoundedRectangle(cornerRadius: cardSize.cornerRadius)
                        .stroke(Color.blue, lineWidth: 3)
                        .padding(5)
                }
            }
        )
        .onTapGesture {
            onTap()
        }
    }
}

enum CardSize {
    case small
    case medium
    case large
    
    var width: CGFloat {
        switch self {
        case .small: return 120
        case .medium: return 200
        case .large: return 250
        }
    }
    
    var height: CGFloat {
        switch self {
        case .small: return 180
        case .medium: return 300
        case .large: return 400
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 12
        case .large: return 30
        }
    }
    
    var backgroundCornerRadius: CGFloat {
        return cornerRadius + 5
    }
}

#Preview {
    //CommonMovieCard(cardData: <#T##CardDisplayData#>, isFlipped: <#T##Bool#>, cardSize: <#T##CardSize#>, showSelection: <#T##Bool#>, isSelected: <#T##Bool#>, onTap: <#T##() -> Void#>)
}
