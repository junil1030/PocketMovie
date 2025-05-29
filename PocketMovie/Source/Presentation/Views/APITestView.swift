//
//  APITestView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import SwiftUI
import Combine
import Kingfisher

struct APITestView: View {
    @StateObject private var viewModel = APITestViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                // 검색창
                SearchBarView(searchKeyword: $viewModel.searchKeyword, onSearch: {
                    viewModel.searchMovies()
                })
                
                // 로딩 인디케이터
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
                
                // 검색 결과 목록
                MovieListView(
                    searchResults: viewModel.searchResults,
                    error: viewModel.error,
                    isLoading: viewModel.isLoading,
                    searchKeyword: viewModel.searchKeyword
                )
            }
            .navigationTitle("영화 검색 테스트")
        }
    }
}

// 검색바 뷰 컴포넌트
struct SearchBarView: View {
    @Binding var searchKeyword: String
    let onSearch: () -> Void
    
    var body: some View {
        HStack {
            TextField("영화 제목 검색", text: $searchKeyword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("검색") {
                onSearch()
            }
            .padding(.trailing)
        }
        .padding(.top)
    }
}

// 영화 목록 뷰 컴포넌트
struct MovieListView: View {
    let searchResults: [TMDBMovie]
    let error: Error?
    let isLoading: Bool
    let searchKeyword: String
    
    var body: some View {
        List {
            if let error = error {
                Text("오류 발생: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else if !searchResults.isEmpty {
                ForEach(searchResults) { movie in
                    MovieRowView(movie: movie)
                }
            } else if !isLoading && !searchKeyword.isEmpty {
                Text("검색 결과가 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
}

// 개별 영화 행 컴포넌트
struct MovieRowView: View {
    let movie: TMDBMovie
    
    var body: some View {
        HStack {
            // 포스터 이미지
            PosterImageView(url: movie.fullPosterURL)
            
            // 영화 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                if !movie.releaseDate.isEmpty {
                    Text("개봉일: \(movie.releaseDate)")
                        .font(.caption)
                }
            }
            .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// 포스터 이미지 컴포넌트
struct PosterImageView: View {
    let url: String?
    
    var body: some View {
        Group {
            if let posterURL = url, !posterURL.isEmpty {
                KFImage(URL(string: posterURL))
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 120)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 120)
                    .cornerRadius(8)
                    .overlay(
                        Text("포스터 없음")
                            .font(.caption)
                            .foregroundColor(.gray)
                    )
            }
        }
    }
}

class APITestViewModel: ObservableObject {
    private let movieAPIService: MovieAPIService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var searchKeyword = ""
    @Published var searchResults: [TMDBMovie] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    init() {
        let container = DIContainer.shared
        self.movieAPIService = container.container.resolve(MovieAPIService.self)!
    }
    
    func searchMovies() {
        guard !searchKeyword.isEmpty else { return }
        
        isLoading = true
        error = nil
        searchResults.removeAll()
        
        movieAPIService.searchMovies(keyword: searchKeyword)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                self?.searchResults = response.results
            }
            .store(in: &cancellables)
    }
}

#Preview {
    APITestView()
}
