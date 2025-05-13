//
//  HomeView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/6/25.
//

import SwiftUI
import Kingfisher

struct HomeView: View {
    @StateObject private var viewModel = DIContainer.shared.container.resolve(HomeViewModel.self)!
    
    @State private var isSelectionMode: Bool = false
    @State private var selectedMovies: Set<String> = []
    @State private var flippedCards: Set<String> = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.movies.isEmpty {
                    EmptyStateView()
                } else {
                    CardStackView(
                        movies: viewModel.movies,
                        isSelecteionMode: isSelectionMode,
                        selectedMovies: $selectedMovies,
                        flippedCards: $flippedCards
                    )
                }
                
                if isSelectionMode && !selectedMovies.isEmpty {
                    DeleteButtonView(action: deleteSelectedMovies)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("PocketMovie")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    SelectionModeButton(
                        isSelectionMode: $isSelectionMode) {
                            if !isSelectionMode {
                                selectedMovies.removeAll()
                            }
                        }
                }
            }
        }
        .onAppear {
            viewModel.fetchMovies()
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

#Preview {
    //HomeView()
}
