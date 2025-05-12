//
//  SearchView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/8/25.
//

import SwiftUI
import Kingfisher

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var progress: CGFloat = 0
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 15) {
                if !viewModel.searchKeyword.isEmpty {
                    
                    SearchResultsGridView(
                        searchResults: viewModel.searchResults,
                        isLoading: viewModel.isLoading,
                        error: viewModel.error
                    )
                } else {
                    
                    // 일간 박스오피스
                    BoxOfficeView(
                        title: "일간 박스오피스",
                        items: viewModel.dailyBoxOfficeList.map { $0.movieNm },
                        isLoading: viewModel.isLoadingBoxOffice,
                        error: viewModel.boxOfficeError,
                        getPosterURL: viewModel.getPosterURL
                    )
                    
                    // 주간 박스오피스
                    BoxOfficeView(
                        title: "주간 박스오피스",
                        items: viewModel.weeklyBoxOfficeList.map { $0.movieNm },
                        isLoading: viewModel.isLoadingBoxOffice,
                        error: viewModel.boxOfficeError,
                        getPosterURL: viewModel.getPosterURL
                    )
                }
            }
            .padding(15)
            .offset(y: isFocused ? 0 : progress * 75)
            .safeAreaInset(edge: .top, spacing: 0) {
                SearchHeaderView(
                    searchKeyword: $viewModel.searchKeyword,
                    isFocused: $isFocused,
                    progress: progress,
                    onSubmit: {
                        viewModel.searchMovies()
                    },
                    onClear: {
                        viewModel.searchKeyword = ""
                    }
                )
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(CustomScrollTarget())
        .animation(.snappy(duration: 0.3, extraBounce: 0), value: isFocused)
        .onScrollGeometryChange(for: CGFloat.self) {
            $0.contentOffset.y + $0.contentInsets.top
        } action: { oldValue, newValue in
            progress = max(min(newValue / 75, 1), 0)
        }
        .onAppear {
            if viewModel.dailyBoxOfficeList.isEmpty || viewModel.weeklyBoxOfficeList.isEmpty {
                viewModel.loadBoxOfficeData()
            }
        }
    }
}

struct CustomScrollTarget: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        let endPoint = target.rect.minY
        
        if endPoint < 75 {
            if endPoint > 40 {
                target.rect.origin = .init(x: 0, y: 75)
            } else {
                target.rect.origin = .zero
            }
        }
    }
}

#Preview {
    SearchView()
}
