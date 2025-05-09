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
    
    // 그리드 레이아웃 설정
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 15) {
                if !viewModel.searchKeyword.isEmpty {
                    // 검색 결과 표시
                    searchResultsGrid
                } else {
                    // 일간 박스오피스
                    boxOfficeSection(title: "일간 박스오피스", items: viewModel.dailyBoxOfficeList.map { $0.movieNm })
                    
                    // 주간 박스오피스
                    boxOfficeSection(title: "주간 박스오피스", items: viewModel.weeklyBoxOfficeList.map { $0.movieNm })
                }
            }
            .padding(15)
            .offset(y: isFocused ? 0 : progress * 75)
            .safeAreaInset(edge: .top, spacing: 0) {
                ResizableHeader()
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
    }
    
    // 헤더 뷰
    @ViewBuilder
    func ResizableHeader() -> some View {
        let progress = isFocused ? 1 : self.progress
        let currentFocus = isFocused
        
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("영화 검색")
                        .font(.title.bold())
                }
                Spacer(minLength: 0)
            }
            .frame(height: 60 - (60 * progress), alignment: .bottom)
            .padding(.horizontal, 15)
            .padding(.top, 15)
            .padding(.bottom, 15 - (15 * progress))
            .opacity(1 - progress)
            .offset(y: -10 * progress)
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                
                TextField("영화 제목 검색", text: $viewModel.searchKeyword)
                    .focused($isFocused)
                    .onSubmit {
                        viewModel.searchMovies()
                    }
                
                if !viewModel.searchKeyword.isEmpty {
                    Button {
                        viewModel.searchKeyword = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background {
                RoundedRectangle(cornerRadius: isFocused ? 0 : 30)
                    .fill(.background
                        .shadow(.drop(color: .black.opacity(0.08), radius: 5, x: 5, y: 5))
                        .shadow(.drop(color: .black.opacity(0.05), radius: 5, x: -5, y: -5))
                    )
                    .padding(.top, isFocused ? -100 : 0)
            }
            .padding(.horizontal, isFocused ? 0 : 15)
            .padding(.bottom, 10)
            .padding(.top, 5)
        }
        .background {
            ProgressiveBlurView()
                .blur(radius: isFocused ? 0 : 10)
                .padding(.horizontal, -15)
                .padding(.bottom, -10)
                .padding(.top, -100)
        }
        .visualEffect { content, proxy in
            content
                .offset(y: offsetY(proxy, isFocused: currentFocus))
        }
    }
    
    // 검색 결과 그리드 뷰
    private var searchResultsGrid: some View {
        VStack(alignment: .leading) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let error = viewModel.error {
                Text("오류 발생: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.searchResults.isEmpty {
                Text("검색 결과가 없습니다.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Text("검색 결과: \(viewModel.searchResults.count)개")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.searchResults) { movie in
                        NavigationLink(destination: Text("영화 카드 생성 화면")) {
                            MoviePosterView(movie: movie)
                        }
                    }
                }
            }
        }
    }
    
    // 박스오피스 섹션
    @ViewBuilder
    func boxOfficeSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            
            if viewModel.isLoadingBoxOffice {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let error = viewModel.boxOfficeError {
                Text("데이터 로드 오류: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else if items.isEmpty {
                Text("데이터가 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(zip(items.indices, items)), id: \.0) { index, title in
                            BoxOfficeItemView(rank: index + 1, title: title)
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // 스크롤 오프셋 계산 함수
    nonisolated private
    func offsetY(_ proxy: GeometryProxy, isFocused: Bool) -> CGFloat {
        let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
        return minY > 0 ? (isFocused ? -minY : 0) : -minY
    }
}

// 영화 포스터 뷰
struct MoviePosterView: View {
    let movie: KMDBMovie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 포스터 이미지
            if let posterURL = movie.firstPosterURL {
                KFImage(URL(string: posterURL))
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                            )
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        Text("포스터 없음")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    )
            }
            
            // 영화 제목
            Text(movie.cleanTitle)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 100, alignment: .leading)
        }
    }
}

// 박스오피스 아이템 뷰
struct BoxOfficeItemView: View {
    let rank: Int
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        Text(title)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(4)
                    )
                
                Text("\(rank)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.blue)
                            .shadow(radius: 2)
                    )
                    .padding(4)
            }
            
            Text(title)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 120, alignment: .leading)
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
