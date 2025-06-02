//
//  CommonReviewCard.swift
//  PocketMovie
//
//  Created by 서준일 on 6/2/25.
//

import SwiftUI

struct CommonReviewCard: View {
    let cardData: CardDisplayData
    let cardSize: CardSize
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cardSize.cornerRadius)
                .fill(Color.black.opacity(0.8))
                .frame(width: cardSize.width, height: cardSize.height)
            
            VStack(spacing: spacingValue) {
                Text(cardData.title)
                    .font(titleFont)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(titleLineLimit)
                
                Divider()
                    .background(Color.white)
                    .frame(width: cardSize.width * 0.8)
                
                Text(cardData.review.isEmpty ? "리뷰가 없습니다" : cardData.review)
                    .font(reviewFont)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(reviewLineLimit)
                    .padding(.horizontal, cardSize == .small ? 4 : 8)
                
                Spacer()
                
                HStack(spacing: starSpacing) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= Int(cardData.rating) ? "star.fill" : "star")
                            .font(starFont)
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.bottom, bottomPadding)
            }
            .padding(paddingValue)
            .frame(width: cardSize.width, height: cardSize.height)
            .rotation3DEffect(
                .degrees(180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .clipShape(.rect(cornerRadius: cardSize.cornerRadius))
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: cardSize.backgroundCornerRadius)
                .fill(.background)
        }
    }
    
    private var titleFont: Font {
        switch cardSize {
        case .small: return .caption
        case .medium: return .subheadline
        case .large: return .headline
        }
    }
    
    private var reviewFont: Font {
        switch cardSize {
        case .small: return .caption2
        case .medium: return .caption
        case .large: return .body
        }
    }
    
    private var starFont: Font {
        switch cardSize {
        case .small: return .caption2
        case .medium: return .caption
        case .large: return .body
        }
    }
    
    private var titleLineLimit: Int {
        cardSize == .small ? 1 : 2
    }
    
    private var reviewLineLimit: Int {
        switch cardSize {
        case .small: return 3
        case .medium: return 5
        case .large: return 6
        }
    }
    
    private var spacingValue: CGFloat {
        switch cardSize {
        case .small: return 4
        case .medium: return 8
        case .large: return 20
        }
    }
    
    private var starSpacing: CGFloat {
        cardSize == .small ? 1 : 2
    }
    
    private var paddingValue: CGFloat {
        switch cardSize {
        case .small: return 4
        case .medium: return 8
        case .large: return 16
        }
    }
    
    private var bottomPadding: CGFloat {
        switch cardSize {
        case .small: return 2
        case .medium: return 4
        case .large: return 8
        }
    }
}

#Preview {
    //CommonReviewCard(cardData: <#T##CardDisplayData#>, cardSize: <#T##CardSize#>)
}
