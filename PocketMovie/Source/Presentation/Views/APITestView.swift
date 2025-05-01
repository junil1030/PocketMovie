//
//  APITestView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import SwiftUI
import Combine

struct APITestView: View {
    @StateObject private var viewModel = APITestViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                // 검색창
                HStack {
                    TextField("영화 제목 검색", text: $viewModel.searchKeyword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button("검색") {
                        viewModel.searchMovies()
                    }
                    .padding(.trailing)
                }
                .padding(.top)
                
                // 로딩 인디케이터
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
                
                // 검색 결과 목록
                List {
                    if let error = viewModel.error {
                        Text("오류 발생: \(error.localizedDescription)")
                            .foregroundColor(.red)
                    } else if let movies = viewModel.searchResults {
                        ForEach(movies, id: \.movieCd) { movie in
                            VStack(alignment: .leading) {
                                Text(movie.movieNm)
                                    .font(.headline)
                                Text("개봉일: \(movie.openDt)")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("영화 검색 테스트")
        }
    }
}

class APITestViewModel: ObservableObject {
    private let movieAPIService: MovieAPIService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var searchKeyword = ""
    @Published var searchResults: [KOBISMovie]?
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
        
        movieAPIService.searchMovies(keyword: searchKeyword)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                self?.searchResults = response.movieListResult.movieList
            }
            .store(in: &cancellables)
    }
}

#Preview {
    APITestView()
}
