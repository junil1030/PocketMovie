//
//  CardStackView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct CardStackView: View {
    let movies: [Movie]
    let isSelecteionMode: Bool
    @Binding var selectedMovies: Set<String>
    @Binding var flippedCards: Set<String>
    
    // 카드 크기 설정을 위한 상수
    private let cardWidth: CGFloat = 250
    private let cardHeight: CGFloat = 400
    private let cardCornerRadius: CGFloat = 30
    private let cardBackgroundCornerRadius: CGFloat = 35
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            LoopingStack(maxTranslationWidth: width) {
                ForEach(movies) { movie in
                    MovieCardView(
                        movie: movie,
                        isSelected: selectedMovies.contains(String(movie.id.hashValue)),
                        isFlipped: flippedCards.contains(String(movie.id.hashValue)),
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                        cardCornerRadius: cardCornerRadius,
                        cardBackgroundCornerRadius: cardBackgroundCornerRadius,
                        onTap: {
                            if isSelecteionMode {
                                toggleMovieSelection(id: String(movie.id.hashValue))
                            } else {
                                toggleCardFlip(id: String(movie.id.hashValue))
                            }
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 420)
    }
    
    private func toggleMovieSelection(id: String) {
        if selectedMovies.contains(id) {
            selectedMovies.remove(id)
        } else {
            selectedMovies.insert(id)
        }
    }
    
    private func toggleCardFlip(id: String) {
        if flippedCards.contains(id) {
            flippedCards.remove(id)
        } else {
            flippedCards.insert(id)
        }
    }
}

#Preview {
//    let mockMovie: [Movie] = [
//        Movie(title: "인터스텔라", movieCode: "01", releaseDate: "2014-11-06", rating: 5.0, review: "재밌는 우주 영화", watchedDate: Date()),
//        Movie(title: "어벤져스: 엔드게임", movieCode: "02", releaseDate: "2019-04-24", rating: 5.0, review: "재밌는 마블 영화", watchedDate: Date()),
//        Movie(title: "듄", movieCode: "03", releaseDate: "2021-10-20", rating: 5.0, review: "재밌는 우주 영화", watchedDate: Date()),
//    ]
//    
//    CardStackView(movies: mockMovie, isSelecteionMode: false, selectedMovies: , flippedCards: )
}
