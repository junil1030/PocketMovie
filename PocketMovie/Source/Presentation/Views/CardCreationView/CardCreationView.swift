//
//  CardCreationView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI
import Kingfisher

struct CardCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CardCreationViewModel
    
    @State private var rating: Int = 0
    @State private var review: String = ""
    @FocusState private var isReviewFocused: Bool
    
    init(movie: KMDBMovie) {
        _viewModel = StateObject(wrappedValue: DIContainer.shared.container.resolve(CardCreationViewModel.self, argument: movie)!)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 영화 제목
                Text(viewModel.movie.cleanTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // 개봉일
                if !viewModel.movie.repRlsDate.isEmpty {
                    Text("개봉일: \(viewModel.movie.repRlsDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // 평점 선택 (별 5개)
                VStack(alignment: .leading, spacing: 8) {
                    Text("평점")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .font(.title)
                                .foregroundColor(index <= rating ? .yellow : .gray)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        rating = index
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
                
                // 리뷰 작성
                VStack(alignment: .leading, spacing: 8) {
                    Text("한줄평")
                        .font(.headline)
                    
                    TextField("이 영화에 대한 감상을 남겨보세요", text: $review, axis: .vertical)
                        .lineLimit(5...)
                        .textFieldStyle(.roundedBorder)
                        .focused($isReviewFocused)
                    
                    Text("\(review.count)/100자")
                        .font(.caption)
                        .foregroundColor(review.count > 100 ? .red : .gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)
                
                // 카드 프리뷰 섹션
                VStack(alignment: .leading, spacing: 8) {
                    Text("카드 미리보기")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // 카드 프리뷰
                    CardPreview(
                        movie: viewModel.movie,
                        rating: rating,
                        review: review
                    )
                    .frame(height: 400)
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 40)
                
                // 저장 버튼
                Button(action: saveCard) {
                    Text("저장하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSaveEnabled ? Color.blue : Color.gray)
                        )
                        .padding(.horizontal)
                }
                .disabled(!isSaveEnabled)
                .padding(.bottom, 20)
            }
            .padding(.vertical)
            .onTapGesture {
                isReviewFocused = false
            }
        }
        .navigationTitle("카드 만들기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("취소") {
                    dismiss()
                }
            }
        }
        .alert("저장 완료", isPresented: $viewModel.showSavedAlert) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("영화 카드가 성공적으로 저장되었습니다.")
        }
        .alert("오류", isPresented: $viewModel.showErrorAlert) {
            Button("확인") {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var isSaveEnabled: Bool {
        rating > 0 && !review.isEmpty && review.count <= 100
    }
    
    private func saveCard() {
        viewModel.saveCard(rating: Double(rating), review: review)
    }
}

// 카드 프리뷰 컴포넌트
struct CardPreview: View {
    let movie: KMDBMovie
    let rating: Int
    let review: String
    
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            if isFlipped {
                // 뒷면 (리뷰)
                ZStack {
                    // 배경
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.black.opacity(0.8))
                    
                    // 리뷰 텍스트
                    VStack(spacing: 20) {
                        Text(movie.cleanTitle)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Divider()
                            .background(Color.white)
                        
                        Text("\"\(review.isEmpty ? "리뷰를 입력해주세요" : review)\"")
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        HStack {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.bottom)
                    }
                    .padding()
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0, y: 1, z: 0)
                    )
                }
                .clipShape(.rect(cornerRadius: 30))
                
            } else {
                // 앞면 (포스터)
                ZStack(alignment: .bottom) {
                    // 포스터 이미지
                    if let posterURL = movie.firstPosterURL, let url = URL(string: posterURL) {
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
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Text(movie.cleanTitle)
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            )
                    }
                    
                    // 평점 그라데이션 마스크
                    VStack(alignment: .leading) {
                        Spacer() // 내용을 카드 하단으로 밀어냄
                        
                        Text(movie.cleanTitle)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .padding(.bottom, 4)
                        
                        HStack {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                            
                            Spacer()
                            
                            if !movie.repRlsDate.isEmpty {
                                Text(movie.repRlsDate)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
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
                }
                .clipShape(.rect(cornerRadius: 30))
            }
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(duration: 0.5), value: isFlipped)
        .onTapGesture {
            isFlipped.toggle()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(radius: 5)
    }
}

#Preview {
    //CardCreationView()
}
