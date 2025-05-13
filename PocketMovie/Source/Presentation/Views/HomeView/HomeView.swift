//
//  HomeView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/6/25.
//

import SwiftUI
import Kingfisher
import SwiftData

struct HomeView: View {
    @StateObject private var viewModel = DIContainer.shared.container.resolve(HomeViewModel.self)!
    
    @State private var isSelectionMode: Bool = false
    @State private var selectedMovies: Set<String> = []
    @State private var flippedCards: Set<String> = []
    
    // 카드 크기 설정을 위한 상수
    private let cardWidth: CGFloat = 250
    private let cardHeight: CGFloat = 400
    private let cardCornerRadius: CGFloat = 30
    private let cardBackgroundCornerRadius: CGFloat = 35
    
    var body: some View {
        NavigationStack {
            ZStack {
                mainContent
                
                if isSelectionMode && !selectedMovies.isEmpty {
                    deleteButton
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Pocket Movie")
                        .font(.title)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    selectionModeButton
                }
            }
        }
        .onAppear {
            viewModel.fetchMovies()
        }
    }
    
    // MARK: - UI Components
    
    private var mainContent: some View {
        Group {
            if viewModel.movies.isEmpty {
                emptyStateView
            } else {
                cardStackView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "film")
                .font(.system(size: 70))
                .foregroundColor(.gray)
                .padding()
            
            Text("영화를 추가해보세요!")
                .font(.title2)
                .foregroundColor(.gray)
        }
    }
    
    private var cardStackView: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            LoopingStack(maxTranslationWidth: width) {
                ForEach(viewModel.movies) { movie in
                    createCardView(for: movie)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 420)
    }
    
    private var deleteButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    deleteSelectedMovies()
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                        .background(Circle().fill(.ultraThinMaterial))
                        .shadow(radius: 3)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    private var selectionModeButton: some View {
        Button {
            isSelectionMode.toggle()
            if !isSelectionMode {
                selectedMovies.removeAll()
            }
        } label: {
            Image(systemName: isSelectionMode ? "checkmark.circle.fill" : "ellipsis")
        }
    }
    
    private var searchButton: some View {
        NavigationLink(destination: Text("검색 화면으로 이동")) {
            Image(systemName: "magnifyingglass")
        }
    }
    
    // MARK: - Helper Functions
    
    private func createCardView(for movie: Movie) -> some View {
        MovieCardView(
            movie: movie,
            isSelected: selectedMovies.contains(String(movie.id.hashValue)),
            isFlipped: flippedCards.contains(String(movie.id.hashValue)),
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            cardCornerRadius: cardCornerRadius,
            cardBackgroundCornerRadius: cardBackgroundCornerRadius,
            onTap: {
                if isSelectionMode {
                    toggleMovieSelection(id: String(movie.id.hashValue))
                } else {
                    toggleCardFlip(id: String(movie.id.hashValue))
                }
            }
        )
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
    
    private func deleteSelectedMovies() {
        // 선택된 ID에 해당하는 영화 객체 찾기
        let moviesToDelete = viewModel.movies.filter { movie in
            selectedMovies.contains(String(movie.id.hashValue))
        }
        
        if !moviesToDelete.isEmpty {
            viewModel.deleteMovies(moviesToDelete)
        }
        
        // 선택 모드 종료 및 선택 초기화
        isSelectionMode = false
        selectedMovies.removeAll()
    }
}

// MARK: - MovieCardView
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

// MARK: - PosterCardView
struct PosterCardView: View {
    let movie: Movie
    let isSelected: Bool
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let cardCornerRadius: CGFloat
    let cardBackgroundCornerRadius: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 여기서 전체 카드 사이즈를 적용
            ZStack {
                // 포스터 이미지
                if let posterURL = movie.posterURL, let url = URL(string: posterURL) {
                    KFImage(url)
                        .resizable()
                        .placeholder {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    ProgressView()
                                )
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: cardWidth, height: cardHeight)
                        .overlay(
                            Text(movie.title)
                                .font(.headline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                        )
                }
                
                // 평점 그라데이션 마스크
                VStack(alignment: .leading) {
                    Spacer() // 이것이 내용을 카드 하단으로 밀어냅니다
                    
                    Text(movie.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(.bottom, 4)
                    
                    HStack {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= Int(movie.rating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        
                        Spacer()
                        
                        Text(movie.releaseDate)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: cardWidth, height: cardHeight, alignment: .bottom)
            }
        }
        .clipShape(.rect(cornerRadius: cardCornerRadius))
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: cardBackgroundCornerRadius)
                .fill(.background)
        }
        .overlay(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: cardCornerRadius)
                        .stroke(Color.blue, lineWidth: 3)
                        .padding(5)
                }
            }
        )
        .opacity(isSelected ? 0.7 : 1.0)
    }
}

// MARK: - ReviewCardView
struct ReviewCardView: View {
    let movie: Movie
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let cardCornerRadius: CGFloat
    let cardBackgroundCornerRadius: CGFloat
    
    var body: some View {
        ZStack {
            // 배경
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(Color.black.opacity(0.8))
                .frame(width: cardWidth, height: cardHeight)
            
            // 리뷰 텍스트
            VStack(spacing: 20) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Divider()
                    .background(Color.white)
                
                Text("\"" + movie.review + "\"")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= Int(movie.rating) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.bottom)
            }
            .padding()
            .frame(width: cardWidth, height: cardHeight)
            .rotation3DEffect(
                .degrees(180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .clipShape(.rect(cornerRadius: cardCornerRadius))
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: cardBackgroundCornerRadius)
                .fill(.background)
        }
    }
}

#Preview {
    HomeView()
}
