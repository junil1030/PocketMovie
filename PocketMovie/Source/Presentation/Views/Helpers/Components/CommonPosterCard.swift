//
//  CommonPosterCard.swift
//  PocketMovie
//
//  Created by 서준일 on 6/2/25.
//

import SwiftUI
import Kingfisher

struct CommonPosterCard: View {
    let cardData: CardDisplayData
    let cardSize: CardSize
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let posterURL = cardData.posterURL, let url = URL(string: posterURL) {
                KFImage(url)
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(ProgressView())
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardSize.width, height: cardSize.height)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: cardSize.width, height: cardSize.height)
                    .overlay(
                        Text(cardData.title)
                            .font(titleFont)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    )
            }
            
            VStack(alignment: .leading) {
                Spacer()
                
                Text(cardData.title)
                    .font(titleFont)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.bottom, 4)
                
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= Int(cardData.rating) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(starFont)
                    }
                    
                    Spacer()
                    
                    Text(cardData.releaseDate)
                        .font(dateFont)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(cardSize == .small ? 8 : 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: cardSize.width, height: cardSize.height, alignment: .bottom)
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
    
    private var starFont: Font {
        switch cardSize {
        case .small: return .caption2
        case .medium: return .caption
        case .large: return .body
        }
    }
    
    private var dateFont: Font {
        switch cardSize {
        case .small: return .caption2
        case .medium: return .caption
        case .large: return .caption
        }
    }
}

#Preview {
    //CommonPosterCard(cardData: <#T##CardDisplayData#>, cardSize: <#T##CardSize#>)
}
