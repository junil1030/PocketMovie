//
//  CardCreationView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct CardCreationContent: View {
    let movie: TMDBMovie
    
    @Binding var rating: Int
    @Binding var review: String
    @Binding var isFlipped: Bool
    
    var isReviewFocused: FocusState<Bool>.Binding
    let isSaveEnabled: Bool
    
    @Binding var showSavedAlert: Bool
    @Binding var showErrorAlert: Bool
    let errorMessage: String
    
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    let dismiss: DismissAction
    let saveCard: () -> Void
    
    var body: some View {
        ZStack {
            // 배경색
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // 영화 정보 섹션
                    MovieInfoSection(movie: movie)
                    
                    // 영화 평점 섹션
                    //RatingSelectionSection(rating: $rating)
                    MovieOverviewSection(movie: movie)
                    
                    // 리뷰 섹션
                    CardReviewSection(
                        review: $review,
                        isReviewFocused: isReviewFocused
                    )
                    
                    // 카드 미리보기 섹션
                    CardPreviewSection(
                        movie: movie,
                        rating: rating,
                        review: review,
                        isFlipped: $isFlipped,
                        cardWidth: cardWidth,
                        cardHeight: cardHeight
                    )
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("취소") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("저장") {
                    saveCard()
                }
                .disabled(!isSaveEnabled)
                .opacity(isSaveEnabled ? 1.0 : 0.5)
                .fontWeight(.bold)
            }
        }
        .alert("저장 완료", isPresented: $showSavedAlert) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("영화 카드가 성공적으로 저장되었습니다.")
        }
        .alert("오류", isPresented: $showErrorAlert) {
            Button("확인") {}
        } message: {
            Text(errorMessage)
        }
        .onTapGesture {
            isReviewFocused.wrappedValue = false
        }
    }
}

#Preview {
    let sampleMovie = TMDBMovie(
        id: 87359,
        title: "미션 임파서블: 파이널 레코닝",
        originalTitle: "미션 임파서블: 파이널 레코닝",
        posterPath: "/jPrAjeK4APOhPSrHrLqSmXF2Z8a.jpg",
        backdropPath: "/mroWh717g0Ah2c0rrPGW6f3EWMM.jpg",
        releaseDate: "2025-05-17",
        overview: "디지털상의 모든 정보를 통제할 수 있는 사상 초유의 무기로 인해 전 세계 국가와 조직의 기능이 마비되고, 인류 전체가 위협받는 절체절명의 위기가 찾아온다. 이를 막을 수 있는 건 오직 존재 자체가 기밀인 에단 헌트와 그가 소속된 IMF뿐이다. 무기를 무력화하는 데 반드시 필요한 키를 손에 쥔 에단 헌트. 오랜 동료 루터와 벤지, 그리고 새로운 팀원이 된 그레이스, 파리, 드가와 함께 지금껏 경험했던 그 어떤 상대보다도 강력한 적에 맞서 모두의 운명을 건 불가능한 미션에 뛰어든다.",
        voteAverage: 7.1,
        voteCount: 413
    )
    
    CardCreationView(movie: sampleMovie)
}
